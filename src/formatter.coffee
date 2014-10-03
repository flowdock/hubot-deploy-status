timeago = require('timeago')
sprintf = require('sprintf')

shortMessage = (message) ->
  line = message.split('\n')[0]
  if line.length < 70
    line
  else
    line.substr(0, 67) + '...'

commitLine = (commit, authorMaxLength) ->
  sprintf(
    "%-#{authorMaxLength}s %s %s",
    commit.author?.login || 'unknown',
    commit.sha.substr(0,7),
    shortMessage(commit.commit.message)
  )

commitList = (commits) ->
  authorMaxLength = commits.reduce ((memo, commit) -> Math.max(memo, commit.author?.login.length || 'unknown'.length)), 0
  ("    #{commitLine(commit, authorMaxLength)}" for commit in commits).join('\n')

module.exports =
  formatResponse: (response) ->
    if response.noDeployments()
      "No deployments for #{response.name} in #{response.environment}."
    else if response.isUpToDate()
      """
      App #{response.name} is up to date in #{response.environment}.
      Last deployment was made #{timeago(response.deployment.created_at)}.
      """
    else if response.isBehind()
      """
      App #{response.name} is #{response.commitsBehind()} commits behind #{response.head()} in #{response.environment}.
      The app was deployed #{timeago(response.deployment.created_at)}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits that have not been deployed yet:
      #{commitList(response.commits())}

      Full diff at #{response.compareUrl()}
      """
    else if response.isAhead()
      """
      App #{response.name} is #{response.commitsAhead()} commits ahead #{response.head()} in #{response.environment}.
      The app was deployed #{timeago(response.deployment.created_at)}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits deployed but not in #{response.head()}:
      #{commitList(response.reverseCommits())}

      Full diff at #{response.compareUrl()}
      """
    else if response.isDiverged()
      """
      App #{response.name} is #{response.commitsAhead()} commits ahead and #{response.commitsBehind()} commits behind #{response.head()} in #{response.environment}.
      The app was deployed #{timeago(response.deployment.created_at)}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits that have not been deployed yet:
      #{commitList(response.commits())}

      Full diff at #{response.compareUrl()}

      Commits that have been deployed but are not in #{response.head()}:
      #{commitList(response.reverseCommits())}
      """
    else
      "Something strange is going on, the deployed version is not up to date, behind nor ahead #{response.head()}"

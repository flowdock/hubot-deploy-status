shortMessage = (message) ->
  line = message.split('\n')[0]
  if line.length < 70
    line
  else
    line.substr(0, 67) + '...'

padTo = (string, length = 10) ->
  if string.length >= length
    string.substr(0, length)
  else
    string + Array(length - string.length + 1).join(' ')

commitLine = (commit) ->
  "#{commit.sha.substr(0,7)} #{padTo(commit.author.login, 10)} #{shortMessage(commit.commit.message)}"

commitList = (commits) ->
  ("    #{commitLine(commit)}" for commit in commits).join('\n')

module.exports =
  formatResponse: (response) ->
    if response.noDeployments()
      "No deployments for #{response.name} in #{response.environment}"
    else if response.isUpToDate()
      "App #{response.name} is up to date in #{response.environment}"
    else if response.isBehind()
      """
      App #{response.name} is #{response.commitsBehind()} commits behind #{response.head()} in #{response.environment}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits that have not been deployed yet:
      #{commitList(response.commits())}
      """
    else if response.isAhead()
      """
      App #{response.name} is #{response.commitsAhead()} commits ahead #{response.head()} in #{response.environment}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits deployed but not in #{response.head()}:
      #{commitList(response.reverseCommits())}
      """
    else if response.isDiverged()
      """
      App #{response.name} is #{response.commitsAhead()} commits ahead and #{response.commitsBehind()} commits behind #{response.head()} in #{response.environment}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits that have not been deployed yet:
      #{commitList(response.commits())}

      Commits that have been deployed but are not in #{response.head()}:
      #{commitList(response.reverseCommits())}
      """
    else
      "Something strange is going on, the deployed version is not up to date, behind nor ahead #{response.head()}"

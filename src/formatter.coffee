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
  "#{commit.sha.substr(0,7)} #{padTo(commit.committer.login, 10)} #{shortMessage(commit.commit.message)}"

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
      App #{response.name} is #{response.commitsBehind()} commits behind #{if response.commitsAhead() then "and #{response.commitsAhead()} ahead " else ''}#{response.head()} in #{response.environment}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Pending commits:

      """ + commitList(response.pendingCommits())
    else if response.isAhead()
      """
      App #{response.name} is #{response.commitsAhead()} commits ahead #{response.head()} in #{response.environment}.
      The deployed ref is #{response.deployedRef()} (#{response.deployedSha()}).

      Commits deployed but not in #{response.head()}:

      """ + commitList(response.pendingCommits())
    else
      "Something strange is going on, the deployed version is not up to date, behind nor ahead #{response.head()}"

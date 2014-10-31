request = require 'request'
Url = require 'url'

shortMessage = (message) ->
  line = message.split('\n')[0]
  if line.length < 70
    line
  else
    line.substr(0, 67) + '...'

tagCommitters = (robot, response) ->
  committers = {}
  committers[commit.author.login] = true for commit in response.commits() when commit.author?.login
  committers[commit.author.login] = true for commit in response.reverseCommits() when commit.author?.login if response.reverseCompare?
  githubUsers = Object.keys(committers)
  users = robot.brain.users()
  githubUsers.map((nick) ->
    byGithubLogin = null
    for k of users
      byGithubLogin = users[k] if users[k].githubLogin?.toLowerCase() == nick.toLowerCase()
    byGithubLogin || robot.brain.userForName(nick)
  ).filter((u) ->
    u?
  ).map((u) ->
    ":user:#{u.id}"
  )

commitLine = (commit) ->
  """
  <tr>
    <th>#{commit.author?.login || commit.committer?.login || 'unknown'}</th>
    <td><a href="#{commit.html_url}">#{commit.sha.substr(0,7)}</a></td>
    <td>#{shortMessage(commit.commit.message)}</td>
  </tr>
  """

module.exports =
  message: (response, robot, application, room, done = ->) ->
    token = application.data.check_deploy_status.source_token || process.env.DEPLOY_STATUS_SOURCE_TOKEN

    if response.isBehind()
      title = "App #{response.name} is #{response.commitsBehind()} commits behind #{response.head()} in #{response.environment}."
      status =
        value: 'behind'
        color: 'red'
      body = """
      <p>Commits that have not been deployed yet:</p>
      <table>
      #{(commitLine(commit) for commit in response.commits()).join('\n')}
      </table>
      """
    else if response.isAhead()
      title = "App #{response.name} is #{response.commitsAhead()} commits ahead #{response.head()} in #{response.environment}."
      status =
        value: 'ahead'
        color: 'yellow'
      body = """
      <p>Commits deployed but not in #{response.head()}:</p>
      <table>
      #{(commitLine(commit) for commit in response.reverseCommits()).join('\n')}
      </table>
      """
    else if response.isDiverged()
      title = "App #{response.name} is #{response.commitsAhead()} commits ahead and #{response.commitsBehind()} commits behind #{response.head()} in #{response.environment}."
      status =
        value: 'diverged'
        color: 'orange'
      body = """
      <p>Commits that have not been deployed yet:</p>
      <table>
      #{(commitLine(commit) for commit in response.commits()).join('\n')}
      </table>
      <p>Commits deployed but not in #{response.head()}:</p>
      <table>
      #{(commitLine(commit) for commit in response.reverseCommits()).join('\n')}
      </table>
      """
    repoUrl = response.repository.html_url
    previousDeployment = """
      <a href="#{repoUrl + '/tree/' + response.deployedRef()}">#{response.deployedRef()}</a> @
      <a href="#{repoUrl + '/commits/' + response.deployedSha()}">#{response.deployedSha()}</a> at
      #{response.deployment.created_at}
      """

    thread =
      title: "Deploy status for #{application.name} in #{response.environment}"
      external_url: response.compareUrl()
      status: status
      fields: [
        {label: 'Application', value: application.name}
        {label: 'Repository', value: "<a href='#{repoUrl}'>#{response.repository.full_name}</a>"}
        {label: 'Environment', value: response.environment}
        {label: 'Previous deployment', value: previousDeployment}
      ]
    author =
      name: process.env.DEPLOY_STATUS_AUTHOR_NAME || robot.adapter.bot.userName
      avatar: process.env.DEPLOY_STATUS_AUTHOR_AVATAR
    message =
      flow_token: token
      event: 'activity'
      external_thread_id: "status-check:#{application.name}:#{response.environment}:#{Date.now()}"
      thread: thread
      author: author
      title: title
      body: body
      tags: ['nagger', application.name, response.environment].concat(tagCommitters(robot, response))
    url = Url.parse(process.env.FLOWDOCK_API_URL || 'https://api.flowdock.com')
    url.pathname = '/messages'
    options =
      url: Url.format(url)
      method: 'POST'
      json: message
    request options, (err, res, body) ->
      if err?
        robot.logger.error "Error posting to Flowdock: #{err}"
      else
        if res.statusCode < 400
          robot.logger.info "Posted successfully with status #{res.statusCode}"
        else
          robot.logger.error "Error posting to Flowdock, status #{res.statusCode}: #{JSON.stringify(body)}"
      done(response, body)

  collectResults: (results, robot, room, apps) ->
    pending = (res for res in results when res[0]? && res[1]?.thread_id?)
    return if pending.length == 0
    message = []
    flowUrl = process.env.DEPLOY_STATUS_FLOW_URL || ''
    environments = {}
    for [response, thread] in pending
      environments[response.environment] = true
      message.push "    * #{response.name} - #{flowUrl}/threads/#{thread.thread_id}"
    message.unshift "The following repositories have commits that have not been deployed in #{Object.keys(environments).join(', ')}:"
    robot.messageRoom room, message.join('\n')

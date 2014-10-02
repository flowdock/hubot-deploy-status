# Description
#   Check deployment statuses of repos and compare to master / other branches - https://github.com/flowdock/hubot-deploy-status
#
# Commands:
#   hubot deploy-status for <app> in <environment> - Check which ref of app has been deployed to env

Path = require "path"
patterns = require "../patterns"
formatter = require "../formatter"
Application = require '../application'

module.exports = (robot) ->

  robot.respond patterns.deployStatus, (msg) ->
    [app, env] = msg.match[2...]
    env ?= 'production'
    robot.logger.debug "Checking deploy status of #{app} in #{env}"
    user = robot.brain.userForId msg.envelope.user.id
    token = user.githubDeployToken
    application = Application.build(app, token)
    if !application.isValid()
      msg.send "I don't know about app #{app}"
      return
    if !application.hasEnvironment(env)
      msg.send "App #{app} does not seem to be running in #{env}"
      return
    application.fetchStatus env, (err, res) ->
      if err?
        msg.send err.toString()
        if err.toString().match(/not found/i)
          if !token
            msg.send("This might be because you don't have a stored github token.
              Create a new one with user,repo access in https://github.com/settings/applications#personal-access-tokens
              and private message me 'deploy-token:set newtoken'")
          application.api().get '/user', {}, (err, status, body, headers) ->
            if status == 200 && headers['x-oauth-scopes'] && !headers['x-oauth-scopes'].match(/\brepo\b/i)
              msg.send("This might be because your stored github token does not have the 'repo' OAuth scope.
                Create a new one with user,repo access in https://github.com/settings/applications#personal-access-tokens
                and private message me 'deploy-token:set newtoken'")
      else
        msg.send formatter.formatResponse(res)

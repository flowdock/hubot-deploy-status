# Description
#   Check deployment statuses of repos and compare to master / other branches - https://github.com/flowdock/hubot-deploy-status
#
# Configuration
#   DEPLOY_STATUS_TIMEZONE a blobal setting for cron timezone. See https://www.npmjs.org/package/time for valid values.
#   DEPLOY_STATUS_ADAPTER which adapter to use for automatic naggings
#   DEPLOY_STATUS_ROOM (Default adapter) which room to post to
#   DEPLOY_STATUS_SOURCE_TOKEN (Flowdock adapter) the source token to use for posting to Flowdock
#   DEPLOY_STATUS_AUTHOR_NAME (Flowdock adapter) Name for the author of naggings
#   DEPLOY_STATUS_AUTHOR_AVATAR (Flowdock adapter) Link to an avatar for naggings
#   DEPLOY_STATUS_FLOW_URL (Flowdock adapter) Link to the flow configured with DEPLOY_STATUS_ROOM
# Commands
#   hubot deploy-status:auto toggle|on|off for <app> in <env> - Check status of or toggle automatic nagging if deployments lag behind default_branch. All parameters are optional.

apps = require '../apps'
cron = require '../cron'
patterns = require '../patterns'
formatter = require '../formatter'

module.exports = (robot) ->

  cron.setup(apps(), robot)

  robot.respond patterns.autoDeployStatus, (msg) ->
    [command, name, env] = msg.match[2...]
    allApps = apps()
    app = allApps[name]
    if name? && (!app? || !app.check_deploy_status?)
      msg.send "I don't know about such app."
      return
    try
      switch command
        when "on"
          if name?
            if env?
              cron.enable(name, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now enabled."
            else
              cron.enable(name, env) for env in Object.keys(app.check_deploy_status.environments)
              msg.send "Ok, automatic checks for #{name} are now enabled."
          else
            enabledApps = []
            for name, app of allApps when app.check_deploy_status
              for env in Object.keys(app.check_deploy_status.environments)
                cron.enable(name, env)
              enabledApps.push(name)
            msg.send "Ok, automatic checks for #{enabledApps.join(', ')} are now enabled."
        when "off"
          if name?
            if env?
              cron.disable(name, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now disabled."
            else
              cron.disable(name, env) for env in Object.keys(app.check_deploy_status.environments)
              msg.send "Ok, automatic checks for #{name} are now disabled."
          else
            disabledApps = []
            for name, app of allApps when app.check_deploy_status
              for env in Object.keys(app.check_deploy_status.environments)
                cron.disable(name, env)
              disabledApps.push(name)
            msg.send "Ok, automatic checks for #{disabledApps.join(', ')} are now disabled."
        when "toggle"
          if name? && env?
            if cron.status(name, app)[env]?
              cron.disable(name, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now disabled."
            else
              cron.enable(name, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now enabled."
          else
            msg.send "Cannot do that without an app and env. Use on/off instead."
        else
          data = {}
          if name?
            data[name] = cron.status(name, app)
          else
            data[n] = cron.status(n, config) for n, config of allApps when config.check_deploy_status
          msg.send formatter.formatAutoCheckStatus(data, allApps)
    catch e
      msg.send e.toString()



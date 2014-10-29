# Description
#   Check deployment statuses of repos and compare to master / other branches - https://github.com/flowdock/hubot-deploy-status
#
# Configuration
#   DEPLOY_STATUS_TIMEZONE a blobal setting for cron timezone. See https://www.npmjs.org/package/time for valid values.
#
# Commands
#   hubot deploy-status:auto toggle|on|off for <app> in <env> - Check status of or toggle automatic nagging if deployments lag behind default_branch. All parameters are optional.

apps = require '../apps'
cron = require '../cron'
patterns = require '../patterns'
formatter = require '../formatter'

module.exports = (robot) ->

  for name, app of apps() when app.check_deploy_status
    try
      cron.schedule(robot, name, app)
    catch e
      robot.logger.error "ERROR SCHEDULING DEPLOY-STATUS NAGGER: #{e.toString()}"

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
              cron.scheduleEnv(robot, name, app, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now enabled."
            else
              cron.schedule(robot, name, app)
              msg.send "Ok, automatic checks for #{name} are now enabled."
          else
            enabledApps = (for name, app of allApps when app.check_deploy_status
              cron.schedule(robot, name, app)
              name)
            msg.send "Ok, automatic checks for #{enabledApps.join(', ')} are now enabled."
        when "off"
          if name?
            if env?
              cron.unscheduleEnv(name, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now disabled."
            else
              cron.unschedule(name, app)
              msg.send "Ok, automatic checks for #{name} are now disabled."
          else
            disabledApps = (for name, app of allApps when app.check_deploy_status
              cron.unschedule(name, app)
              name)
            msg.send "Ok, automatic checks for #{disabledApps.join(', ')} are now disabled."
        when "toggle"
          if name? && env?
            if cron.status(name, app)[env]?
              cron.unscheduleEnv(name, env)
              msg.send "Ok, automatic checks for #{name} in #{env} are now disabled."
            else
              cron.scheduleEnv(robot, name, app, env)
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



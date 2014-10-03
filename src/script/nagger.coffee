# Description
#   Check deployment statuses of repos and compare to master / other branches - https://github.com/flowdock/hubot-deploy-status
#
# Commands
#   hubot deploy-status:auto toggle|on|off [for <app>] - Check status of or toggle automatic nagging if deployments lag behind default_branch

apps = require '../apps'
cron = require '../cron'
patterns = require '../patterns'

module.exports = (robot) ->

  for name, app of apps() when app.check_deploy_status
    try
      cron.schedule(robot, name, app)
    catch e
      robot.logger.error "ERROR SCHEDULING DEPLOY-STATUS NAGGER: #{e.toString()}"

  robot.respond patterns.autoDeployStatus, (msg) ->
    [command, app] = msg.match[2...]
    msg.send "TODO: implement command #{command}"

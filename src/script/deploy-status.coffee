# Description
#   Check deployment statuses of repos and compare to master / other branches - https://github.com/flowdock/hubot-deploy-status
#
# Commands:
#   hubot deploy-status for <app> in <environment> - Check which ref of app has been deployed to env

Path = require("path")
patterns = require(Path.join(__dirname, "..", "patterns"))

module.exports = (robot) ->

  robot.respond patterns.deployStatus, (msg) ->
    [app, env] = msg.match[2...]
    app ?= 'all applications'
    env ?= 'production'
    msg.send "Checking for state of #{app} in #{env}"

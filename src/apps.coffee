fs = require "fs"
APPS_FILE = process.env['HUBOT_DEPLOY_APPS_JSON'] or "apps.json"

apps = (file = APPS_FILE) ->
  try
    applications = JSON.parse(fs.readFileSync(file).toString())
  catch
    throw new Error("Unable to parse your apps.json file in hubot-deploy-status")
  applications

module.exports = apps

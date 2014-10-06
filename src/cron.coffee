{CronJob} = require 'cron'
Application = require './application'
formatter = require './formatter'

activeJobs = {}

runNagger = (robot, room, name, env) ->
  application = Application.build(name)
  robot.logger.info "Fetching automatic deployment info #{name} in #{env}"
  application.fetchStatus env, (err, res) ->
    if err?
      robot.messageRoom room,
        """
        Tried to fetch deploy status for app #{name} in #{env} but ran into error:
        #{err.toString()}

        This job has been disabled, you need to restart #{robot.name} or enable the job by telling me "deploy-status:auto on for #{name} in #{env}"
        """
      robot.logger.info "Unscheduling deploy check for app #{name} in #{env} after an error"
      unscheduleEnv(name, env)
    else
      if res.noDeployments()
        robot.logger.info "App #{name} does not have deployments in #{env}."
      else if res.isUpToDate()
        robot.logger.info "App #{name} in #{env} is up to date with #{res.head()}."
        return
      else
        robot.messageRoom room, "Automatic status check:\n\n" + formatter.formatResponse(res)

parseConfig = (config) ->
  config: config.environments
  environments: Object.keys(config.environments)
  room: config.room
  timezone: config.timezone

unscheduleEnv = (name, env) ->
  activeJobs[name]?[env]?.stop()
  activeJobs[name]?[env] = undefined

scheduleEnv = (robot, name, app, env) ->
  {config, room, timezone} = parseConfig(app.check_deploy_status)
  activeJobs[name] ?= {}
  if !config[env]
    throw new Error("No configuration for app #{name} in #{env} environment")
  if !room
    throw new Error("No room specified in configuration for app #{name}")
  robot.logger.info "Scheduling deploy nagger for #{name} in #{env} (#{config[env]})"
  try
    runner = ->
      runNagger(robot, room, name, env)
    activeJobs[name][env] = new CronJob(config[env], runner, undefined, true, timezone)
  catch e
    throw new Error("Invalid cron pattern in configuration for #{name} in #{env}: #{config[env]}")

unschedule = (name, app) ->
  {environments} = parseConfig(app.check_deploy_status)
  for env in environments
    unscheduleEnv(name, env)

schedule = (robot, name, app) ->
  {environments} = parseConfig(app.check_deploy_status)
  for env in environments
    unscheduleEnv(name, env)
    scheduleEnv(robot, name, app, env)

status = (name, app) ->
  {environments} = parseConfig(app.check_deploy_status)
  if !activeJobs[name]
    return {}
  else
    ret = {}
    for env in environments
      ret[env] = activeJobs[name][env]?
    ret

module.exports =
  schedule: schedule
  unschedule: unschedule
  scheduleEnv: scheduleEnv
  unscheduleEnv: unscheduleEnv
  status: status


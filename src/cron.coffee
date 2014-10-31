{CronJob} = require 'cron'
Application = require './application'

adapters = {}
availableAdapters = ['default', 'flowdock']
adapters[name] = require("./adapters/#{name}") for name in availableAdapters

activeJobs = {}
disabledJobs = {}

runNagger = (robot, room, name, env, adapter, done = ->) ->
  return done() if disabledJobs[name]?[env]
  application = Application.build(name)
  robot.logger.info "Fetching automatic deployment info #{name} in #{env}"
  application.fetchStatus env, (err, res) ->
    try
      if err?
        robot.messageRoom room,
          """
          Tried to fetch deploy status for app #{name} in #{env} but ran into error:
          #{err.toString()}

          This job has been disabled, you need to restart #{robot.name} or enable the job by telling me "deploy-status:auto on for #{name} in #{env}"
          """
        robot.logger.info "Unscheduling deploy check for app #{name} in #{env} after an error"
        disable(name, env)
        done()
      else
        if res.noDeployments()
          robot.logger.info "App #{name} does not have deployments in #{env}."
          done()
        else if res.isUpToDate()
          robot.logger.info "App #{name} in #{env} is up to date with #{res.head()}."
          done()
        else
          adapters[adapter].message(res, robot, application, room, done)
    catch e
      robot.logger.error "Error while checking deploy status: #{e.toString()}"
      done()

parseConfig = (config) ->
  config: config.environments
  environments: Object.keys(config.environments)
  room: config.room || process.env.DEPLOY_STATUS_ROOM
  adapter: config.adapter || process.env.DEPLOY_STATUS_ADAPTER || 'default'

disable = (name, env) ->
  disabledJobs[name] ?= {}
  disabledJobs[name][env] = true

enable = (name, env) ->
  disabledJobs[name]?[env] = false

status = (name, app) ->
  {environments} = parseConfig(app.check_deploy_status)
  ret = {}
  for env in environments
    ret[env] = !disabledJobs[name]?[env]
  ret

runJobsAt = (robot, cronSpec, apps) ->
  queue = []
  results = []
  adapter = null
  room = null
  for name, app of apps when app.check_deploy_status?
    config = app.check_deploy_status
    {room, adapter} = parseConfig(config)
    for env, envCronSpec of config.environments when envCronSpec == cronSpec
      queue.push [robot, room, name, env, adapter]
  runNext = (tail) ->
    if tail.length == 0
      adapters[adapter].collectResults(results, robot, room, apps)
      return
    job = tail.shift()
    runNagger(job..., (args...) ->
      results.push args
      runNext(tail)
    )
  runNext(queue)

schedule = (robot, cronSpec, apps) ->
  timezone = process.env.DEPLOY_STATUS_TIMEZONE
  runner = ->
    runJobsAt(robot, cronSpec, apps)
  activeJobs[cronSpec] = new CronJob(cronSpec, runner, undefined, true, timezone)

setup = (apps, robot) ->
  cronSpecifications = {}
  for name, app of apps when app.check_deploy_status?
    for env, cronSpec of app.check_deploy_status.environments
      cronSpecifications[cronSpec] = true
  cronSpecs = Object.keys(cronSpecifications)
  for cronSpec in cronSpecs
    try
      robot.logger.info "Adding deployment nagger watch #{cronSpec}"
      schedule(robot, cronSpec, apps)
    catch e
      robot.logger.error "ERROR SCHEDULING DEPLOY-STATUS NAGGER: #{e.toString()}"

module.exports =
  enable: enable
  disable: disable
  status: status
  setup: setup

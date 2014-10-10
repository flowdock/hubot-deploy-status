apps = require './apps'
Response = require './response'
Octonode = require 'octonode'

class Application

  @build: (name, token) ->
    data = apps()[name]
    new Application(name, token, data)

  constructor: (@name, @token, @data) ->
    @environments = if @data.environments
      @data.environments
    else
      ['production']
    @repository = @data.repository
    @token ||= process.env.HUBOT_GITHUB_TOKEN

  isValid: ->
    @data?

  hasEnvironment: (env) ->
    env in @environments

  fetchStatus: (env, cb) ->
    client = @api()
    res = new Response(@name, env, @data)
    client.get "/repos/#{@repository}", {}, (err, status, repository) =>
      return cb(err) if err?
      res.repository = repository
      @lastSuccessfullDeployment env, (err, deployment) =>
        return cb(err) if err?
        return cb(null, res) unless deployment?
        res.deployment = deployment
        client.get "/repos/#{@repository}/compare/#{deployment.sha}...#{repository.default_branch}", {}, (err, statusCode, compare) =>
          return cb(err) if err?
          res.compare = compare
          if res.isAhead() || res.isDiverged()
            # Compare api does not give commits that are ahead of compare, need to fetch the other way around
            client.get "/repos/#{@repository}/compare/#{repository.default_branch}...#{deployment.sha}", {}, (err, statusCode, reverseCompare) ->
              return cb(err) if err?
              res.reverseCompare = reverseCompare
              cb(null, res)
          else
            cb(null, res)

  api: ->
    api = Octonode.client(@token)
    api.requestDefaults.headers['Accept'] = 'application/vnd.github.cannonball-preview+json'
    api

  # private
  lastSuccessfullDeployment: (env, cb, page = 1) ->
    client = @api()
    params =
      environment: env
      per_page: 10
      page: page
    client.get "/repos/#{@repository}/deployments", params, (err, statusCode, deployments) =>
      return cb(err) if err?
      return cb(null, null) if deployments.length == 0
      @fetchDeploymentStatuses deployments, (err, deployment) =>
        return cb(err) if err?
        return cb(null, deployment) if deployment?
        @lastSuccessfullDeployment(env, cb, page + 1)

  fetchDeploymentStatuses: (deployments, cb) ->
    deployment = deployments.shift()
    return cb(null, null) unless deployment?
    client = @api()
    client.get "/repos/#{@repository}/deployments/#{deployment.id}/statuses", {}, (err, statusCode, statuses) =>
      return cb(err) if err?
      success = false
      for status in statuses
        success = true if status.state == 'success'
      if success
        cb(null, deployment)
      else
        @fetchDeploymentStatuses(deployments, cb)

module.exports = Application

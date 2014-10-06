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
    repoPath = "/repos/#{@repository}"
    client = @api()
    res = new Response(@name, env, @data)
    client.get repoPath, {}, (err, status, repository) ->
      return cb(err) if err?
      res.repository = repository
      params =
        environment: env
        per_page: 1
        page: 1
      client.get repoPath + "/deployments", params, (err, status, deployments) ->
        return cb(err) if err?
        deployment = res.deployment = deployments[0]
        if !deployment?
          cb(null, res)
        else
          client.get repoPath + "/compare/#{deployment.sha}...#{repository.default_branch}", {}, (err, status, compare) ->
            return cb(err) if err?
            res.compare = compare
            if res.isAhead() || res.isDiverged()
              # Compare api does not give commits that are ahead of compare, need to fetch the other way around
              client.get repoPath + "/compare/#{repository.default_branch}...#{deployment.sha}", {}, (err, status, reverseCompare) ->
                res.reverseCompare = reverseCompare
                cb(null, res)
            else
              cb(null, res)

  api: ->
    api = Octonode.client(@token)
    api.requestDefaults.headers['Accept'] = 'application/vnd.github.cannonball-preview+json'
    api

module.exports = Application

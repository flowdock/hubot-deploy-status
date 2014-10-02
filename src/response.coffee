class Response

  constructor: (@name, @environment, @application) ->
    @compare = null
    @repository = null
    @deployment = null

  noDeployments: ->
    !@deployment?

  isUpToDate: ->
    @compare.status == 'identical'

  isBehind: ->
    @compare.status == 'behind'

  isAhead: ->
    @compare.status == 'ahead'

  pendingCommits: ->
    @compare.commits

  commitsAhead: ->
    @compare.ahead_by

  commitsBehind: ->
    @compare.behind_by

  head: ->
    @repository.default_branch

  deployedRef: ->
    @deployment.ref

  deployedSha: ->
    @deployment.sha.substr(0, 7)

module.exports = Response

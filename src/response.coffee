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
    @compare.status == 'ahead'

  isAhead: ->
    @compare.status == 'behind'

  isDiverged: ->
    @compare.status == 'diverged'

  commits: ->
    @compare.commits

  reverseCommits: ->
    @reverseCompare.commits

  commitsAhead: ->
    @compare.behind_by

  commitsBehind: ->
    @compare.ahead_by

  head: ->
    @repository.default_branch

  deployedRef: ->
    @deployment.ref

  deployedSha: ->
    @deployment.sha.substr(0, 7)

module.exports = Response

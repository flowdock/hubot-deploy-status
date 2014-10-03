{expect} = require 'chai'
patterns = require '../src/patterns'

describe 'patterns', ->

  describe 'deployStatus', ->

    beforeEach ->
      @pattern = patterns.deployStatus

    it 'does not match something else', ->
      matches = "deploy-status:auto for hubot".match(@pattern)
      expect(matches, 'matches wrong command').to.be.null

    it 'matches plain "deploy-status"', ->
      matches = "deploy-status".match(@pattern)
      expect(matches[1], 'wrong command').to.equal 'deploy-status'
      expect(matches[2], 'wrong app').to.be.undefined
      expect(matches[3], 'wrong environment').to.be.undefined

    it 'matches "deploy-status for hubot"', ->
      matches = "deploy-status for hubot".match(@pattern)
      expect(matches[1], 'wrong command').to.equal 'deploy-status'
      expect(matches[2], 'wrong app').to.equal 'hubot'
      expect(matches[3], 'wrong environment').to.be.undefined

    it 'matches "deploy-status for hubot in production"', ->
      matches = "deploy-status for hubot in production".match(@pattern)
      expect(matches[1], 'wrong command').to.equal 'deploy-status'
      expect(matches[2], 'wrong app').to.equal 'hubot'
      expect(matches[3], 'wrong environment').to.equal 'production'

    it 'matches "deploy-status in production"', ->
      matches = "deploy-status in production".match(@pattern)
      expect(matches[1], 'wrong command').to.equal 'deploy-status'
      expect(matches[2], 'wrong app').to.be.undefined
      expect(matches[3], 'wrong environment').to.equal 'production'

  describe 'autoDeployStatus', ->

    beforeEach ->
      @pattern = patterns.autoDeployStatus

    it 'does not match something else', ->
      matches = "deploy-status for anna".match(@pattern)
      expect(matches, "matches wrong command").to.be.null

    it 'matches plain "deploy-status:auto', ->
      matches = "deploy-status:auto".match(@pattern)
      expect(matches[1], "wrong command").to.equal "deploy-status:auto"
      expect(matches[2], "wrong action").to.be.undefined
      expect(matches[3], "wrong app").to.be.undefined

    it 'matches "deploy-status:auto toggle', ->
      matches = "deploy-status:auto toggle".match(@pattern)
      expect(matches[1], "wrong command").to.equal "deploy-status:auto"
      expect(matches[2], "wrong action").to.equal "toggle"
      expect(matches[3], "wrong app").to.be.undefined

    it 'matches "deploy-status:auto on', ->
      matches = "deploy-status:auto on".match(@pattern)
      expect(matches[1], "wrong command").to.equal "deploy-status:auto"
      expect(matches[2], "wrong action").to.be.equal "on"
      expect(matches[3], "wrong app").to.be.undefined

    it 'matches "deploy-status:auto off', ->
      matches = "deploy-status:auto off".match(@pattern)
      expect(matches[1], "wrong command").to.equal "deploy-status:auto"
      expect(matches[2], "wrong action").to.equal "off"
      expect(matches[3], "wrong app").to.be.undefined

    it 'matches "deploy-status:auto toggle app', ->
      matches = "deploy-status:auto toggle app".match(@pattern)
      expect(matches[1], "wrong command").to.equal "deploy-status:auto"
      expect(matches[2], "wrong action").to.equal "toggle"
      expect(matches[3], "wrong app").to.equal "app"

    it 'matches "deploy-status:auto on for app', ->
      matches = "deploy-status:auto on for app".match(@pattern)
      expect(matches[1], "wrong command").to.equal "deploy-status:auto"
      expect(matches[2], "wrong action").to.equal "on"
      expect(matches[3], "wrong app").to.equal "app"

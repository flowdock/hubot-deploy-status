{expect} = require 'chai'
patterns = require '../src/patterns'

describe 'patterns', ->

  describe 'deployStatus', ->

    beforeEach ->
      @pattern = patterns.deployStatus

    it 'does not match something else', ->
      matches = "deploy hubot".match(@pattern)
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

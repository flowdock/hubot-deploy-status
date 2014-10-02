{expect} = require 'chai'
apps = require '../src/apps'

describe 'apps', ->

  it 'can read parse an apps.json', ->
    data = apps('test/fixtures/apps.json')
    expect(data, 'no data received').to.be.defined
    expect(data, 'wrong projects').to.have.keys('project1', 'project2')

  it 'raises error if file is not found', ->
    expect(->
      data = apps('foobar')
    ).to.throw(Error)

should = require 'should'
parser = require '../lib/commandParser.js'
util = require 'util'
_ = require 'underscore'

describe 'parsing', ->
  describe 'when parsing an object', ->
    cmd = {
      command: 'mobile create',
      positional: ['mymobileservice', 'sqladmin', 'myP@ssw0rd!'],
      sqlServer: 'VMF1ASD',
      sqlDb: 'mydb',
      flagEmpty: '',
      flagNull: null,
      flagTrue: 'true'
    }

    parsed = parser.parseCommandToString cmd
    params = parsed.split(' ')

    it 'should insert the command', (done) ->
      parsed.indexOf('mobile create').should.equal 0
      done()

    it 'should insert position params first', (done) ->
      params[2].should.equal 'mymobileservice'
      params[3].should.equal 'sqladmin'
      params[4].should.equal 'myP@ssw0rd!'
      done()

    it 'should insert the name of each optional parameter', (done) ->
      params[5].should.equal '--sqlServer'
      params[7].should.equal '--sqlDb'
      done() 

    it 'should insert the value for each optional parameter after the name', (done) ->
      params[6].should.equal 'VMF1ASD'
      params[8].should.equal 'mydb'
      done()

    it 'should insert only the parameter name for flags', (done) ->
      params[9].should.equal '--flagEmpty'
      params[10].should.equal '--flagNull'
      params[11].should.equal '--flagTrue'
      done()

    describe 'and command is not a string', ->
      it 'should fail', (done) ->
      	try
      	  parser.parseCommandToString {command:[]}
      	catch err
      	  done()
      	  return

      	done 'error was not thrown'
    
    describe 'and it is a string', ->
      it 'should return the string', (done) -> 
        cmd = parser.parseCommandToString 'foo'
        cmd.should.equal 'foo'
        done() 
        
   
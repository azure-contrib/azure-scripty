should = require 'should'
transformer = require '../lib/pipeTransformer.js'
_ = require 'underscore'

describe 'piping', ->
  describe 'when calling transform', ->
  	it 'should error if piped object is null', (done) ->
  	  cmd = 'foo'
  	  obj = {name:"site1"}
  	  try
  	  	transformer.transform(cmd, null)
  	  catch e
  	  	done()
  	  	return

  	  done(false)

  	it 'should error if piped object is undefined', (done) ->
  	  cmd = 'foo'
  	  obj = {name:"site1"}
  	  try
  	  	transformer.transform(cmd, undefined)
  	  catch e
  	  	done()
  	  	return

  	  done(false)

  describe 'when a top level property substitution is passed in the command template', ->
  	it 'should error if substitution does not match against the piped object', (done) -> 
      cmd = ':bar'
      obj = {foo:"foobar"}
      try
      	transformer.transform(cmd, obj)
      catch e
      	done()
      	return

      done(false)
  	  
  	it 'should replace the substition with the piped value', (done) ->
      cmd = 'site config add foo :name'
      obj = {name:"site1"}
      result = transformer.transform(cmd, obj)
      result.should.equal 'site config add foo site1'
      done()
      



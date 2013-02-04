should = require 'should'
transformer = require '../lib/pipeTransformer.js'
_ = require 'underscore'

describe 'piping', ->
  describe 'when calling transform', ->
  	it 'should error if piped object is null', (done) ->
  	  cmd = 'prop'
  	  obj = {prop:"value"}
  	  try
  	  	transformer.transform(cmd, null)
  	  catch e
  	  	done()
  	  	return

  	  done(false)

  	it 'should error if piped object is undefined', (done) ->
  	  cmd = 'prop'
  	  obj = {prop:"value"}
  	  try
  	  	transformer.transform(cmd, undefined)
  	  catch e
  	  	done()
  	  	return

  	  done(false)

  describe 'when a top level property substitution is passed in the command template', ->
  	it 'should error if substitution does not match against the piped object', (done) -> 
      cmd = ':prop1'
      obj = {prop:"value"}
      try
      	transformer.transform(cmd, obj)
      catch e
      	done()
      	return

      done(false)
  	  
  	it 'should replace the substitution with the piped value', (done) ->
      cmd = ':prop'
      obj = {prop:"value"}
      result = transformer.transform(cmd, obj)
      result.should.equal 'value'
      done()

  describe 'when a nested property substitution is passed in the command template', ->
  	it 'should replace the substitution with the piped value', (done) ->
      cmd = ':child.value'
      obj = {child:{value:"value"}}
      result = transformer.transform(cmd, obj)
      result.should.equal 'value'
      done()
             
  describe 'when an nested array property substitution is passed in the command template', ->
  	it 'should replace the substitution with the piped value for the index value specified', (done) ->
  	  cmd = ":child.items[1].value"
  	  obj = {child:{items:[{}, {value:"value"}]}}
  	  result = transformer.transform(cmd, obj)
  	  result.should.equal 'value'
  	  done()




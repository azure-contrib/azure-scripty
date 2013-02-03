should = require 'should'
buddy = require '../lib/azure-scripty.js'

results = []
expectedCmds = []
errors = []
calls = 0;
receivedCmds = []

buddy.exec = (cmd, callback) -> 
  calls++;
  receivedCmds.push(cmd);
  cmd.should.include expectedCmds.pop()
  callback errors.pop(), results.pop()
  
describe 'buddy', ->
  # before every test
  beforeEach (done) ->
    calls = 0
    done()

  describe 'when calling invoke with a single command', ->
    it 'should invoke the completion callback', (done) ->
      obj = {
        complete: (err, results) ->
          done()
      }
      results = [null]
      expectedCmds = ['foo bar1']
      buddy.invoke 'foo bar1', obj.complete

    it 'should return the result object', (done) ->
      obj = {
        complete: (err, results) ->
          if err
            done err

          try
            results.should.equal 'foo'
          catch err
            done err
            return

          done()
      }
      results = ['foo']
      expectedCmds = ['foo bar2']
      buddy.invoke 'foo bar2', obj.complete      
 
    describe 'and an error occurs', ->
      it 'should return the error', (done) ->
        obj = {
          complete: (err, results) ->
            try
              err.should.equal 'error'
            catch err
              done err
              return

            done()
        }
        results = ['']
        errors=['error']
        expectedCmds = ['foo bar3']
        buddy.invoke 'foo bar3', obj.complete   
  
  describe 'when calling invoke with multiple commands', ->
    it 'should invoke the completion callback', (done) ->
      obj={
        complete: (err, results) ->
          done()
      }

      results = []
      errors=[]
      expectedCmds = ['foo bar4', 'foo bar5'].reverse()

      cmds = ['foo bar4', 'foo bar5']

      buddy.invoke cmds, obj.complete


  describe 'when calling invoke with multiple command objects', ->
    it 'should invoke each step callback', (done) ->
      invoked=0
      obj = {
        step1: (callback, result) ->
          try
            result.should.equal '1'
          catch err
            done err
            return

          invoked++
          callback null, result
        step2: (callback, result) ->
          try
            result.should.equal '2'
          catch err
            done err
            return

          invoked++
          done();
      }
      results = ['1', '2'].reverse()
      errors=[]
      expectedCmds = ['foo bar4', 'foo bar5'].reverse()

      cmds = [
        {cmd:'foo bar4', callback:obj.step1}
        {cmd:'foo bar5', callback:obj.step2}
      ]

      buddy.invoke cmds, ->  
      

    it 'should invoke the completion callback', (done) ->
      obj={
        complete: (err, results) ->
          done()
      }

      results = []
      errors=[]
      expectedCmds = ['foo bar6', 'foo bar7'].reverse()

      cmds = [
        {cmd:'foo bar6'}
        {cmd:'foo bar7'}
      ]

      buddy.invoke cmds, obj.complete

    it 'should pass all the results to the completion callback', (done) ->
      obj = {
        complete: (err,results) ->
          try
            results.length.should.equal 2
          catch err
            done err
            return

          done()
      }
      results = ['1', '2'].reverse()
      errors=[]
      expectedCmds = ['foo bar8', 'foo bar9'].reverse()

      cmds = [
        {cmd:'foo bar8', callback:obj.step1}
        {cmd:'foo bar9', callback:obj.step2}
      ]

      buddy.invoke cmds, obj.complete

    describe 'and an error occurs', ->
      it 'should stop processing and call the completion callback', (done) ->
        obj = {
          complete: (err, results) ->
            try
              err.should.equal 'error'
              calls.should.equal 2
            catch err
              done(err)
              return
            done()
            return
        }
        calls = 0;
        results=['1', '2','3'].reverse();
        errors=[null,'error',null];
        expectedCmds=['foo bar10', 'foo bar11', 'foo bar12'].reverse()

        cmds = [
          {cmd:'foo bar10'}
          {cmd:'foo bar11'}
        ]

        buddy.invoke cmds, obj.complete
  describe 'when calling invoke with a single command object', ->
    it 'should make the proper call', (done) ->
      cmd = {
        command: 'mobile create',
        positional: ['mymobileservice', 'sqladmin', 'myP@ssw0rd!'],
        sqlServer: 'VMF1ASD',
        sqlDb: 'mydb'
      }
      receivedCmds= [null]
      expectedCmds=['mobile create mymobileservice sqladmin myP@ssw0rd! --sqlServer VMF1ASD --sqlDb mydb']
      buddy.invoke cmd, ->
        #if it succeeds this worked as buddy.exec validates the exepcted cmd against the received cmd
        done()
      

  describe 'when calling invoke with multiple command objects', ->
    it 'should make the proper calls', (done) ->
      cmds = [
        {
          command: 'mobile create',
          positional: ['mymobileservice', 'sqladmin', 'myP@ssw0rd!'],
          sqlServer: 'VMF1ASD',
          sqlDb: 'mydb'
        },
        {
          command: 'site create',
          positional: ['site1'],
          location: '"West US"',
          subscription: 'foobar'
          git:null
        }
      ]

      receivedCmds= [null]
      expectedCmds=[
        'mobile create mymobileservice sqladmin myP@ssw0rd! --sqlServer VMF1ASD --sqlDb mydb',
        'site create site1 --location "West US" --subscription foobar --git'
      ].reverse()
      buddy.invoke cmds, ->
        #if it succeeds this worked as buddy.exec validates the exepcted cmd against the received cmd
        done()

###

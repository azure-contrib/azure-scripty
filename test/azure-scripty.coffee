should = require 'should'
_ = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()

scripty = require '../lib/azure-scripty.js'

results = []
expectedCmds = []
errors = []
calls = 0;
receivedCmds = []

scripty.exec = (cmd, callback) -> 
  calls++;
  receivedCmds.push(cmd);
  if expectedCmds.length > 0
    cmd.should.include expectedCmds.pop()
  callback errors.pop(), results.pop()
  
describe 'scripty', ->
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
      scripty.invoke 'foo bar1', obj.complete

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
      scripty.invoke 'foo bar2', obj.complete      
 
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
        scripty.invoke 'foo bar3', obj.complete   
  
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

      scripty.invoke cmds, obj.complete
      
    describe 'and using piping', ->
      it 'should invoke the piped command for each ', (done) ->
        cmds = [
          'site list',
          'site config add foo :Name'
        ]
        results=[[{Name:"site1"},{Name:"site2"}],null].reverse();
        receivedCmds= []
        expectedCmds=['site list', 'site config add foo site1', 'site config add foo site2'].reverse()
        scripty.invoke cmds, ->
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

      receivedCmds = [null]
      expectedCmds = [
        'mobile create mymobileservice sqladmin myP@ssw0rd! --sqlServer VMF1ASD --sqlDb mydb',
        'site create site1 --location "West US" --subscription foobar --git'
      ].reverse()
      scripty.invoke cmds, ->
        #if it succeeds this worked as scripty.exec validates the exepcted cmd against the received cmd
        done()

    it 'should invoke each step callback', (done) ->
      obj = {
        step1: (callback, result) ->
          try
            result.should.equal '1'
          catch err
            done err
            return

          callback null, result
        step2: (callback, result) ->
          try
            result.should.equal '2'
          catch err
            done err
            return

          done();
      }
      results = ['1', '2'].reverse()
      errors=[]
      expectedCmds = ['foo bar4', 'foo bar5'].reverse()

      cmds = [
        {cmd:'foo bar4', callback:obj.step1}
        {cmd:'foo bar5', callback:obj.step2}
      ]

      scripty.invoke cmds, ->  

    it 'should pass the next command to the step callback', (done) ->
      obj = {
        step1: (callback, result, nextCmd) ->
          try 
            should.exist nextCmd
            nextCmd.should.have.property 'cmd','second'
          catch err
            done err
            return

          done();
      }
      results = ['1', '2'].reverse();
      errors=[]
      expectedCmds = ['first', 'second'].reverse()

      cmds = [
        {cmd:'first', callback:obj.step1}
        {cmd:'second'}
      ]

      scripty.invoke cmds, ->

    it 'should propogate a modified command within the step callback to the next step', (done) ->
      obj = {
        step1: (callback, result, nextCmd) ->
          nextCmd.cmd = 'modified'
          callback null, result
      }
      results = ['1', '2'].reverse();
      errors=[]
      expectedCmds = ['first', 'modified'].reverse()

      cmds = [
        {cmd:'first', callback:obj.step1}
        {cmd:'second'}
      ]

      scripty.invoke cmds, ->
        done()

    
    it 'should propogate modified results in the step callback to the next step', (done) ->
      obj = {
        step1: (callback, result) ->
          results = ['modified', '2'].reverse();
          callback null, 'modified'
        step2: (callback, result) ->
          try
            result.should.equal 'modified'
          catch err
            done err
            return

          done()
      }
      errors=[]
      expectedCmds = ['first', 'second'].reverse()

      cmds = [
        {cmd:'first', callback:obj.step1}
        {cmd:'second', callback:obj.step2}
      ]

      scripty.invoke cmds, ->
    

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

      scripty.invoke cmds, obj.complete

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

      scripty.invoke cmds, obj.complete

    describe 'and using piping', ->
      it 'should invoke the piped command for the result', (done) ->
        cmds = [
          {
            command: 'site list'
          },
          {
            command: 'site config add',
            positional: ['foo =', ':Name']
          }
        ]
        results=[[{Name:"site1"},{Name:"site2"}],null].reverse();
        receivedCmds= []
        expectedCmds=['site list', 'site config add foo = site1', 'site config add foo = site2'].reverse()
        scripty.invoke cmds, ->
          done()

      it 'should only pipe to modified results', (done) ->
        obj = {
          step1: (callback, result) ->
            filtered = result.filter (item) ->
              return _(item.Name).startsWith 'Include'
            callback null, filtered
          step2: (callback, result) ->
            try
              (_(result.Name).startsWith 'Exclude').should.equal true
            catch err
              callback err
              return
            callback null, null    
        }
        cmds = [
          {
            command: 'site list'
            callback: obj.step1
          },
          {
            command: 'site config add',
            positional: ['foo =', ':Name']
            callback: obj.step2
          }
        ]
        results=[[{Name:"Include1"},{Name:"Exclude1"},{Name:"Include2"}],null,null].reverse();
        receivedCmds=[]
        expectedCmds=[]
        #expectedCmds=['site list', 'site config add foo = Include1', 'site config add foo = Include2'].reverse()
        scripty.invoke cmds, ->
          done()

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

        scripty.invoke cmds, obj.complete
  
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
      scripty.invoke cmd, ->
        #if it succeeds this worked as scripty.exec validates the exepcted cmd against the received cmd
        done()
      




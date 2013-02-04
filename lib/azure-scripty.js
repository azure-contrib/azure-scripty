//requires azure and async modules
var util = require('util');
var async = require('async');
var child_process = require('child_process');
var path = require('path');
var cli = require('../node_modules/azure-cli/lib/cli');
var _ = require('underscore');
var parser = require('./commandParser.js');
var pipeTransformer = require('./pipeTransformer.js');

/**
* Invokes one or more commands on the CLI
*
* @param {object} [command]                           Either a command like 'site list' or an array of commands
*                                                     with optional callbacks of the function(err,result)
* @param {function(err, results)} [complete]          Completion callback fired when all commands are complete
*/
exports.invoke = function (command, complete) {  
  if( _.isArray(command)) {
    if (_.isNull(complete) || _.isUndefined(complete)) {
      throw "Completion callback is required";
      return;
    }
    handleArray(command, complete);
  }
  else {
    var cmd = parser.parseCommandToString(command);
    handleSingle(cmd, 
      function(err, result) {
        complete(err, result);
      } 
    );
  }
}

function handleArray(commands,callback, results) {
  commands = Array.prototype.slice.call(commands);
  var results=[];
  var lastResult;

  async.forEachSeries(commands, 
    function(item, callback2) {
      var cmd;

      if (_.isUndefined(item)) 
        callback2()

      cmd = parser.parseCommandToString(item);

      if (pipeTransformer.hasPiping(cmd)) {
        var lastResult = results[results.length-1];
        if (!_.isArray(lastResult))
          lastResult=[lastResult];

        var pipeResults = [];

        async.forEach(lastResult,
          function(pipeItem, callback3) {
            var pipeCmd = pipeTransformer.transform(cmd, pipeItem);
            handleSingleInArray(pipeCmd, item, pipeResults, callback3);
          },
          function(err) {
            results.push(pipeResults);
            callback2(err, pipeResults);
          } 
        );
      }
      else 
        handleSingleInArray(cmd, item, results, callback2)
    },
    function(err) {
      callback(err,results);
    }
  );
}

function handleSingleInArray(command, item, results, callback) {
  handleSingle(command,
    function(err, json) {
      results.push(json);
      if (err) 
        callback(err);
      else {
        if(!_.isString(item) && !_.isUndefined(item.callback) && !_.isNull(item.callback))
          item.callback(callback, json);
        else
          callback();
      }
    }
  );
}

function handleSingle(command, callback) {
  var azurejs = path.resolve(__dirname,'..','node_modules', 'azure-cli', 'bin', 'azure.js');
  var cmd = 'node ' + azurejs + ' ' + command + ' --json';
  if (!_.isFunction(callback)) {
    throw "Callback must be provided";    
  }
  
  exports.exec(cmd, callback);
}

/**
* Calls the CLI and returns a JSON result object
*
* @param {object} [cmd]                               Commands to be passed to the CLI
* @param {function(err,result)}  [callback]           Callback containing either an error or the resulting JSON object
*/
exports.exec = function exec(cmd, callback) {
  child_process.exec(cmd, {encoding:'ascii', cwd:process.cwd()}, function(error, stdout) {
    if(error)
      callback(error)
    else
    {
      var json;

      if (error)
        callback(error, null);

      if (stdout == '')
        json=null;
      else {
        json = JSON.parse(stdout);
      }

      callback(undefined,json);
    }
  });
}






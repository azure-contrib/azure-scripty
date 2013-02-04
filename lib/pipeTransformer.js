var _ = require('underscore');
var util = require('util');

exports.hasPiping = function(command) {
  var results = command.match(/\:([A-z0-9.\[\]]+)/g);
  if (results != null && results.length > 0) {
  	return true;
  }
  return false;
}


exports.transform = function(command, pipeObject) {
  if (_.isUndefined(pipeObject) || _.isNull(pipeObject)) {
  	throw new Error("pipeObject must be a value");
  }
  
  //find substitions i.e. :foo :bar
  var results = command.match(/\:([A-z0-9.\[\]]+)/g);
  results.forEach(function(item) {
    var prop = item.substring(1);
    if (prop.indexOf('.') > -1) {
       command = command.replace(':' + prop, handleNested(prop, pipeObject));
    }
    else {
      if (!_.has(pipeObject, prop))
        throw new Error("property '" + prop + "' is invalid");
 
      command = command.replace(':' + prop, pipeObject[prop]);
    }
  });
  return command;
}

function handleNested(prop, pipeObject) {
  var path = prop.split('.');
  var current = pipeObject;

  path.forEach(function(item) {
    //pull out the array indexer if there is one
    var arrayIndexMatch = item.match(/\[([0-9]+)\]/);
    
    if (!_.isNull(arrayIndexMatch)) {
      var index = Number(arrayIndexMatch[1]);
      item = item.substring(0, item.indexOf('['));

      if (!_.has(current, item))
        throw new Error("property '" + prop + "' is invalid");

      current = current[item][index];
    }
   	else {
      if (!_.has(current, item))
        throw new Error("property '" + prop + "' is invalid");

      current = current[item];
    }
  });
  return current;
}



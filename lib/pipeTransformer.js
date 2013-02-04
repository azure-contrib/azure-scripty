var _ = require('underscore');

exports.transform = function(command, pipeObject) {
  if (_.isUndefined(pipeObject) || _.isNull(pipeObject)) {
  	throw new Error("pipeObject must be a value");
  }
  
  //find substitions i.e. :foo :bar
  var results = command.match(/\:([a-z0-9.]+)/g);
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
    if (!_.has(current, item))
      throw new Error("property '" + prop + "' is invalid");

    current = current[item];
  });
  return current;
}



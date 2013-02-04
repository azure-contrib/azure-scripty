var _ = require('underscore');

exports.transform = function(command, pipeObject) {
  if (_.isUndefined(pipeObject) || _.isNull(pipeObject)) {
  	throw new Error("pipeObject must be a value");
  }
  
  //find substitions i.e. :foo :bar
  var results = command.match(/\:([a-z0-9]+)/g);
  results.forEach(function(item) {
    var prop = item.substring(1);
    if (!_.has(pipeObject, prop))
      throw new Error("property '" + prop + "' is invalid");
    command = command.replace(':' + prop, pipeObject[prop]);
  });
  return command;
}
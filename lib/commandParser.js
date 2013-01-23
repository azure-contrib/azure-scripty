var _ = require('underscore');

exports.parseCommandToString = function(command) {
  if(_.isString(command))
  	return command;

  if(!_.isString(command.command)) {
  	throw new Error("command must be a String");
  }

  cmd = command.command + ' ';
  keys = _.keys(command);
  if (_.contains(keys, 'positional')) {
    cmd = cmd + command['positional'].join(' ');
  }

  keys.forEach(function(key) {
  	keyLower = key.toLowerCase(key);      
  	if (keyLower != 'command' && keyLower != 'positional')
  	  cmd = cmd + ' --' + key + ' ' + command[key];    
  });
  return cmd;
}

exports.parseStringToCommand = function(command) {
	return '';
}
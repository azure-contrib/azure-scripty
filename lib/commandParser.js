var _ = require('underscore');

exports.parseCommandToString = function(command) {
  if(_.isString(command))
  	return command;

  if(!_.isUndefined(command.command) && !_.isString(command.command)) {
  	throw new Error("command must be a String");
  }

  keys = _.keys(command);

  if (_.contains(keys, 'cmd'))
    return command.cmd;

  cmd = command.command + ' ';

  if (_.contains(keys, 'positional')) {
    cmd = cmd + command['positional'].join(' ');
  }

  keys.forEach(function(key) {
  	keyLower = key.toLowerCase(key);      
  	if (keyLower != 'command' && keyLower != 'positional' && keyLower != 'callback') {
  	  cmd = cmd + ' --' + key
      var val = command[key]
      if (!_.isNull(val) && !_.isEmpty(val) && val != 'true')
        cmd = cmd + ' ' + val  
    }  
  });

  return cmd;
}

exports.parseStringToCommand = function(command) {
	return '';
}
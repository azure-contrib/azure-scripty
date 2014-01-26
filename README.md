azure-scripty
===============

Azure automation made easy. 

[![Build Status](https://travis-ci.org/WindowsAzure-Contrib/azure-scripty.png)](https://travis-ci.org/WindowsAzure-Contrib/azure-scripty)


azure-scripty is a little helper library that makes it really easy to create node automation scripts using the azure-cli.

# Features
* Invoke one or more CLI commands easily from within your code.
* Supports all CLI commands, if you know the CLI you know scripty!
* Returns JSON objects from each cmd. Useful for complex scripting scenarios.
* Cross platform, works on Windows, Mac and Linux.

# Getting started

## Install it
```bash
npm install azure-scripty
```

To use scripty, call the invoke method passing in one or more commands. Commands are the arguments that you would normally pass when calling azure-cli from the shell.

## Single command style

You can pass a single command to scripty along with a callback.

```javascript
var scripty = require('azure-scripty');
scripty.invoke('site list', function(err, results) {
  console.log("my sites\n" + results);
});
````

## Increasing the output buffer size

By default scripty uses the standard default buffer size of 204800 bytes. This may be insufficent for some scenarios like listing out hundreds of blobs resulting an error indicating the buffer size is too small. For these cases you can increase the buffer size using by setting maxBuffer.

```
var scripty = require('azure-scripty');
scripty.maxBuffer = 999999999;
```

## Single command object style ##

You can also pass a command object where properties map to different parameters. This is useful for programattic scenarios where a function returns an object that you just pass in.

* The 'Command' property holds the command name. 
* 'Positional' is an array of values that will be added positionally at the beginning. 
* The rest of the properties are optional and will be appended with --[Property Name] and the value i.e. --Foo Bar.
* For quoted values, use a double quotes within the single quotes i.e. {'name':'"foo bar"'}.
* For parameters which are flags i.e. --git, the value can be null, '' or 'true'.

For example passing the command below

```javascript
var scripty = require('azure-scripty');
cmd = {
  command: 'mobile create',
  positional: ['mymobileservice', 'sqladmin', 'myP@ssw0rd!'],
  sqlServer: 'VMF1ASD',
  sqlDb: 'mydb'
};
scripty.invoke(cmd, function() {})
```
will end up with the following resulting command.

```bash
mobile create mymobileserver sqladmin myP@ssw0rd! --sqlServer VMF1ASD --sqlDb myDB
```

## Multi-command style

You can pass a collection of cmds to be called in sequence. Below for example I am create a site and then configuring it.

```javascript
var scripty = require('azure-scripty');
scripty.invoke(['site create mysite --git', 'site config add foo=bar', 'site show mysite'], function(err, results){
  console.log(results[2]) //shows the site details
});
````

The results parameter in the callback will contain an array of all returned objects

## Multi command object style ##

Similar to the single command, you can also pass multiple command objects. See the example below.

```javascript
var scripty = require('azure-scripty');
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
    git:true
  }
]

scripty.invoke(cmds, function() {});
```

When this runs, the following commands will be created.

```bash
mobile create mymobileserver sqladmin myP@ssw0rd! --sqlServer VMF1ASD --sqlDb myDB
site create site1 --location "West US" --subscription foobar --git
```

## Multi-command with step callbacks

An alternative style that is supported is to pass a collection of cmd objects with callbacks. Today this is useful for organizing you script into smaller functions. In the future this may allow you to do pre-processing and feed data to the next step based on the current result.

```javascript
var scripty = require('azure-scripty');
var steps={
  sites:function(callback,result) {
    //contains just sites
    console.log("sites\n" + result;
  },
  vms:function(callback,result) {
    //contains just vms
    console.log("vms\n" + result;
  }
  complete:function(err, results) {
    //contains both
    console.log("results\n" + results;
  }
};
var cmds=[
  {cmd:'site list', callback:steps.sites},
  {cmd:'vm list', callback:steps.vms}
];
scripty.invoke(cmds, steps.complete);
````

This also works with command object style, so you can pass in a full command with a callback.

## Declarative piping

Scripty supports the ability to pipe results between commands. To pipe, the command having results piped in should contain substituion placeholders in the parameters. A placeholder is in the form of ':' + property name ex. ':Name'

### Piping multiple results. 

If a command to be piped into is immediately after a command returning a collection then the command will be called for each item in the collection. 

For example in the example below the :Name property is specified for 'site stop'. Assuming 'site list' returns 2 sites 'foo' and 'bar' then 'site stop foo' and 'site stop bar' will be called.

```javascript
var scripty = require('azure-scripty');
scripty.invoke(['site list', 'site stop :Name'], function(){});
```

### Piping single results

You can also pipe a result which is not a collection to the next call.

Below the first call retrieves the Service Bus namespace myns and then pipes the connection string to a config setting.

```javascript
var scripty = require('azure-scripty')
scripty.invoke(['sb namespace show myns', "site config add \"conn=':ConnectionString'\" mysite"], 
  function(){});
```

# What's next
* Add custom filtering for collections 

# Known issues

* Some commands have required params which the cli will prompt for ex. 'azure site create' will prompt for location. If you call those cmds without passing required params the cli will prompt which causes scripty to freeze as the cli is expecting input. This will be addressed shortly so that cmd will error if this happens. To avoid this make sure all required params are passed. You can find out which params are required by using --help, i.e. "azure site create --help"
* When using piping, parameters currently match case sensitively. Please make sure the names match exactly.

# License

Apache 2: http://www.apache.org/licenses/LICENSE-2.0.html


azure-scripty
===============

Azure automation made easy. 

# Features
* Invoke one or more CLI commands easily from within your code.
* Supports all CLI commands, if you know the CLI you know scripty!
* Returns JSON objects from each cmd. Useful for complex scripting scenarios.

# Getting started

To use scripty, call the invoke method passing in one or more commands. Commands are the arguments that you would normally pass when calling azure-cli from the shell.

## Single command style

You can pass a single command to scripty along with a callback.

```javascript
var scripty = require('azure-scripty');
scripty.invoke('site list', function(err, results) {
  console.log("my sites\n" + results);
});
````

## Multi-command style

You can pass a collection of cmds to be called in sequence. Below for example I am create a site and then configuring it.

```javascript
var scripty = require('azure-scripty');
scripty.invoke('site create mysite --git', 'site config add foo=bar', function(err, results){
  console.log('done')
});
````

The results parameter in the callback will contain an array of all returned objects

## Multi-command with step callbacks

An alternative style that is supported is to pass a collection of cmd objects with callbacks. Today this is useful for organizing you script into smaller functions. In the future this may allow you to do pre-processing and feed data to the next step based on the current result.

````javascript
var script = require('azure-scripty');
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

# What's next
* Add piping syntax to allow piping results, i.e. feeding the results of "site list" into "site config".

# License

Apache 2: http://www.apache.org/licenses/LICENSE-2.0.html


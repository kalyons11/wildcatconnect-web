'use strict';

// This is our main script to run jobs for the WildcatConnect application.

// So, right now we have a directory of jobs - let's parse that.

var path = require("path"),
    https = require("https"),
    http = require("http"),
    schedule = require("node-schedule");

var p = __dirname;

// Create a map from names to configurations.
var jobs = [
  'alertDelete',
  'alertPush',
  'commDelete',
  'dayDelete',
  'dayGenerate',
  'ECUdelete',
  'eventDelete',
  'newsDelete',
  'pollDelete',
  'scholarshipDelete'
];

var mainConfig = {};

for (var i = 0; i < jobs.length; i++) {
  var thisConfig = path.join(__dirname, jobs[i], 'config.js');
  mainConfig[jobs[i]] = require(thisConfig);
}

// Now that we have all configurations, we can schedule our jobs.

function runJob(key) {
  var config = mainConfig[key];
  var postData = JSON.stringify(config.data);
  var options = {
    host: config.host,
    port: config.port,
    path: config.path,
    method: 'POST',
    headers: {
      accept: '*/*',
      'Content-Type': 'application/json',
      'Content-Length': postData.length
    }
  };

  if (config.secure) {
    https.request(options, function(res){
      console.log("Running job with key:", key);
      res.on('data', function(data){
        var result = data.toString("utf-8");
        console.log("Response:", result);
      });
    }).write(postData);
  } else {
    console.log("Running job with key:", key);
    http.request(options, function(res){
      res.on('data', function(data){
        var result = data.toString("utf-8");
        console.log("Response:", result);
      });
    }).write(postData);
  }
}

function scheduleJobs() {
  // Schedule all jobs based on our mapping.
  var result = [];

  Object.keys(mainConfig).forEach(function (key) {
    var config = mainConfig[key];
    var j = schedule.scheduleJob(config.timing, function() {
      runJob(key);
    });
    result.push(j);
  });

  // Return a list of all jobs for reference.
  return result;
}

if (process.argv.length > 2) {
  for (var i = 2; i < process.argv.length; i++) {
    runJob(process.argv[i]);
  }
}

var jobs = scheduleJobs();
console.log(jobs);
console.log('Initialized all jobs!');

var fs = require("fs");
var lazy = require("lazy");

var bannedWords = [];

new lazy(fs.createReadStream(__dirname+'/../banned.txt'))
    .lines
    .forEach(function(line){
        bannedWords.push(line.toString('utf8').replace(/^\s\s*/, '').replace(/\s\s*$/, ''));
    })
    .on('pipe', function() {
        var output = "";
        bannedWords.forEach(function (word, index) {
            output += '@"' + word + '"'; 
            if (index < bannedWords.length-1) {
                output += ",";
            }   
        });
        console.log('#pragma once \n\n#define kBANNED_WORDS @['+output+']');
    });

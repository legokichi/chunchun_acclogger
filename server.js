var express = require('express');
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);
var fs = require('fs');

var filename = 'devicemotion.csv';
var filename2 = 'deviceorientation.csv';
var filename3 = 'state.csv';

fs.writeFile(filename, ["timeStamp","x","y","z","gx","gy","gz"].join(",")+"\n", function (err) {});
fs.writeFile(filename2,["timeStamp","alpha", "beta", "gamma"].join(",")+"\n", function (err) {});

app.use(express.static(__dirname));

server.listen(8080);

io.on('connection', function (socket) {
  var state = "start";
  socket.on('devicemotion', function (arr) {
    var csv = arr.concat(state).join(",")+"\n";
    console.log("mot", csv);
    fs.appendFile(filename, csv, function (err) {});
  });
  socket.on('deviceorientation', function (arr) {
    var csv = arr.concat(state).join(",")+"\n"
    console.log("ori", csv);
    fs.appendFile(filename2, csv, function (err) {});
  });
  socket.on('state', function (arr) {
    state = arr[1];
    console.log("state", state);
  });
});

var express = require('express');
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);
var fs = require('fs');

app.use(express.static(__dirname));

server.listen(8080);

io.on('connection', function (socket) {
  var state = "start";
  var filename = 'devicemotion'+Date.now()+'.csv';
  fs.writeFile(filename, ["timeStamp","alpha", "beta", "gamma","x","y","z","gx","gy","gz","label"].join(",")+"\n", function (err) {});
  socket.on('devicemotion', function (arr) {
    var csv = arr.concat(state).join(",")+"\n";
    console.log("mot", csv);
    fs.appendFile(filename, csv, function (err) {});
  });
  socket.on('state', function (arr) {
    state = arr[1];
    console.log("state", state);
  });
});

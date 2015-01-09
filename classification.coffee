convnetjs = require('convnetjs')
fs = require('fs');

labels =
  "walking": [
    "devicemotion1420784518324.csv"
  ]
  "standing": []
  "lying": [
    "devicemotion1420782943153.csv"
  ]
  "sitting": []
  "running": [
    "devicemotion1420783329176.csv"
    "devicemotion1420783491721.csv"
    #"devicemotion1420783602871.csv"
  ]

dim = 16*3
classes = Object.keys(labels).length

main = ->
  net = createNet()

  console.time("train")
  Object.keys(labels).forEach (dir)->
    files = labels[dir]
    files.forEach (file)->
      labelAndTeachVect = createTeachData(dir, dir+"/"+file)
      trainNet(net, labelAndTeachVect)
  console.timeEnd("train")
  labelAndVect = createTeachData("running", "running/devicemotion1420783602871.csv")
  [expected, data] = labelAndVect[10]
  console.log "expected", expected
  results = calcNet(net, data)
  index = results.indexOf(Math.max.apply(Math, results))
  console.log "detected", Object.keys(labels)[index], index, results
  #console.log getJSON(net)








createTeachData = (label, path)->
  csv = readCSV(path).map (row)->
    row.map (a)->
      if isFinite(Number(a))
      then Number(a)
      else a
  vects = csv.map (row)->
    [timeStamp,alpha,beta,gamma,x,y,z,gx,gy,gz,_label] = row
    [alpha,beta,gamma,gx,gy,gz]
  labelAndTeachVect = []
  for vect,i in vects
    teachVect = vects.slice(i, i+20)# 20sample is 1sec
    .reduce(((a,b)->a.concat(b)), [])
    if teachVect.length is 20*6
      labelAndTeachVect.push [label, teachVect]
  labelAndTeachVect

readCSV = (path)->
  fs.readFileSync(path, {encoding: "utf-8"})
  .split("\n")
  .filter (a)-> a.length > 0
  .map (a)-> a.trim()
  .map (a)-> a.split(",")

createNet = ->
  net = new convnetjs.Net()
  net.makeLayers([
    {type:'input', out_sx:1, out_sy:1, out_depth:dim}
    {type:'svm', num_classes:classes}
  ])
  return net

trainNet = (net, teaches)->
  trainer = new convnetjs.Trainer(net, {learning_rate:0.01, l2_decay:0.001})
  for _ in [1..100]
    for [klass, vect] in teaches
      x = new convnetjs.Vol(1, 1, dim)
      for val, i in vect
        x.w[i] = val
      trainer.train(x, klass)
  return

calcNet = (net, vect)->
  y = new convnetjs.Vol(1, 1, dim)
  for val, i in vect
    y.w[i] = val
  scores = net.forward(y)
  results = (scores.w[i] for i in [0..classes-1])
  results

getJSON = (net)->
  JSON.stringify(net.toJSON(), null, "")

main()

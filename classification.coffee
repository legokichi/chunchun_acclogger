convnetjs = require('convnetjs')
fs = require('fs');

dirs = ["walking","standing","lying","sitting","running"]
dim = 16*3
classes = dirs.length

main = ->
  net = createNet()

  console.time("train")
  datas = []
  for dir in dirs
    csv = readCSV("./"+dir+"/devicemotion.csv").slice(40, 40+100)
    teaches = ([Number(gx),Number(gy),Number(gz)] for [timeStamp,x,y,z,gx,gy,gz,klass] in csv)
    data = []
    for _, i in teaches by 1
      _ = [dir, teaches.slice(i, i+16).reduce(((a,b)->a.concat(b)), [])]
      if _[1].length is 16*3
        data.push _
    console.log dir, data.length#, data.map((a)->a[1].length)
    datas.push [dir, data[0][1]]
    trainNet(net, data)
  console.timeEnd("train")
  console.log "expected: ", datas[2][0]
  results = calcNet(net, datas[2][1])
  index = results.indexOf(Math.max.apply(Math, results))
  console.log "detected", dirs[index], index, results
  #console.log getJSON(net)

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

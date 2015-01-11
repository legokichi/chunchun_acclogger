fs = require('fs')
svm = require('node-svm')

labelAndFile =
  0: "寝ている.csv"
  1: "立っている.csv"
  2: "歩いている.csv"
  3: "走っている.csv"
###
4: "寝転ぶ.csv"
5: "座る.csv"
6: "振り向き右.csv"
7: "正面を向く.csv"
8: "立つ.csv"
9: "起きる.csv"
###


main = ->
  dataSet = Array.prototype.concat.apply [], Object.keys(labelAndFile).map (label)->
    filepath= labelAndFile[label]
    csv = readCSV(filepath, {encoding: "utf-8"})
    csv = csv.map (a)-> a.map (b)-> Number(b)
    csv.map (row)-> [row, Number(label)]


  clf = new svm.CSVC()

  dataSet = shuffule(dataSet)
  sep = dataSet.length/2|0
  trainingSet = dataSet.slice(0, sep)
  predictionSet = dataSet.slice(sep)

  console.time("train")
  clf.train(trainingSet).done ->
    console.timeEnd("train")
    results = Object.keys(labelAndFile).reduce(((o, label)-> o[label] = [0, 0]; o), {})
    predictionSet.forEach ([vect, label])->
      prediction = clf.predictSync(vect)
      if label is prediction
      then results[label][0]++
      else results[label][1]++
    Object.keys(results).forEach (label)->
      [hit, err]= results[label]
      console.log "label:", label, "precision:", hit/(hit+err), "recall:", hit/hit, "raw:", [hit, err]

shuffule = (arr)->
  _arr = []
  while arr.length > 0
    index = arr.length*Math.random()
    _arr.push arr.splice(index, 1)[0]
  _arr

readCSV = (path)->
  fs.readFileSync(path, {encoding: "utf-8"})
  .split("\n")
  .filter (a)-> a.length > 0
  .map (a)-> a.split(",")
  .map (a)-> a.map (b)-> b.trim()

main()

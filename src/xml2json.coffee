fs = require 'fs'
xml2js = require 'xml2js'

inFile = process.argv[2]
if not inFile
  console.error 'specify a file'
  process.exit()

if /\.xml$/.test inFile
  outFile = inFile.replace /\.xml$/, '.json'
else
  outFile = inFile + '.json'

parser = new xml2js.Parser()
xmlData = fs.readFileSync inFile
parser.parseString xmlData, (err, json) ->
  if err
    console.error 'parse error :(', err
  else
    fs.writeFileSync outFile, JSON.stringify(json, null, 2)

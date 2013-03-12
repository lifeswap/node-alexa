should = require 'should'
fs     = require 'fs'
parser = require 'lib/parser'

describe 'parsing top sites XML', () ->

  jsonData = JSON.parse fs.readFileSync('test/data/top_sites.json')
  xmlData = fs.readFileSync('test/data/top_sites.xml').toString()

  it 'should parse the XML into json without error', (done) ->
    parser.parseXML xmlData, (err, json) ->
      should.not.exist err
      json.should.eql jsonData
      done()

  it 'should correctly parse the xml to good json', (done) ->
    parser.parseTopSitesXML xmlData, (err, json) ->
      should.not.exist err
      json.should.have.lengthOf 100
      site = json[0]
      site.should.have.keys ['url', 'rank', 'reach', 'page_views']
      site.reach.should.have.keys ['per_million']
      site.page_views.should.have.keys ['per_million', 'per_user']
      # suprise! google is ranked #1 :)
      site.url.should.eql 'google.com'
      site.rank.should.eql 1
      done()

describe 'parsing big site XML', () ->

  jsonData = JSON.parse fs.readFileSync('test/data/pinterest.json')
  xmlData  = fs.readFileSync('test/data/pinterest.xml').toString()

  it 'should parse the XML into json without error', (done) ->
    parser.parseXML xmlData, (err, json) ->
      should.not.exist err
      json.should.eql jsonData
      done()

  it 'should correctly parse the xml into good json', (done) ->
    parser.parseSiteInfoXML xmlData, (err, json) ->
      should.not.exist err
      json.should.have.keys ['url', 'title', 'description', 'speed', 'links_in_count', 'rank', 'usage_stats', 'subdomains']
      json.speed.should.have.keys ['median_load_time', 'percentile']
      json.rank.should.have.keys ['global', 'countries', 'cities']
      done()

describe 'parsing small site XML', ->

  jsonData = JSON.parse fs.readFileSync('test/data/lifeswap.json')
  xmlData  = fs.readFileSync('test/data/lifeswap.xml').toString()

  it 'should parse the XML into json without error', (done) ->
    parser.parseXML xmlData, (err, json) ->
      should.not.exist err
      json.should.eql jsonData
      done()

  it 'should correctly parse the xml into good json', (done) ->
    parser.parseSiteInfoXML xmlData, (err, json) ->
      should.not.exist err
      json.should.have.keys ['url', 'title', 'description', 'speed', 'links_in_count', 'rank', 'usage_stats', 'subdomains']
      json.speed.should.have.keys ['median_load_time', 'percentile']
      json.rank.should.have.keys ['global', 'countries', 'cities']
      done()

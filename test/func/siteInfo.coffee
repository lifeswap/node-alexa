should = require 'should'
fs     = require 'fs'
alexa  = require 'lib/alexa'

describe 'getting info on a site', () ->

  it 'should correctly get the info for the given url', (done) ->
    url = 'pinterest.com'

    options =
      key: process.env.AWS_KEY
      secret: process.env.AWS_SECRET
      url: url
    alexa.getSiteInfo options, (err, json) ->
      should.not.exist err
      json.should.have.property 'url', url
      json.should.have.keys ['url', 'title', 'description', 'speed', 'links_in_count', 'rank', 'usage_stats', 'subdomains']
      json.speed.should.have.keys ['median_load_time', 'percentile']
      json.rank.should.have.keys ['global', 'countries', 'cities']
      jsonString = JSON.stringify json, null, 2
      #fs.writeFileSync 'test/data/siteInfoOutput.json', jsonString
      done()

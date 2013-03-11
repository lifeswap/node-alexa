# Alexa API
parser = require './parser'
aws = require './aws'

# ### getTopSites
#
# @public
#
# * `@param {Object} options`
# * `@options {String} key`
#   Amazon AWS key
# * `@options {String} secret`
#   Amazon AWS secret
# * `@options {Number} start`
#   where to start getting top sites
# * `@options {Number} count`
#   how many results to return (max 100)
# * `@param {Function} callback`
#   (err, sites)
# * `@callback {[Object]} sites`
#   array of top sites
exports.getTopSites = ({key, secret, start, count}, callback) ->
  start ?= 1
  count ?= 100
  count = 100 if count > 100
  options =
    url: 'http://ats.amazonaws.com/'
    key: key
    secret: secret
    query:
      Start: start
      Count: count
  aws.get options, (err, resp, xml) ->
    return callback err if err
    parser.parseTopSitesXML xml, callback


# ### getSiteInfo
#
# @public
#
# * `@param {Object} options`
# * `@options {String} key`
#   Amazon AWS key
# * `@options {String} secret`
#   Amazon AWS secret
# * `@options {Number} url`
#   which url to get information on
# * `@param {Function} callback`
#   (err, site)
exports.getSiteInfo = ({key, secret, url}, callback) ->
  options =
    url: 'http://awis.amazonaws.com/'
    key: key
    secret: secret
    query:
      Action: 'UrlInfo'
      Url: url
      ResponseGroup: [
        'RelatedLinks'
        'Categories'
        'Rank'
        'RankByCountry'
        'RankByCity'
        'UsageStats'
        'ContactInfo'
        'AdultContent'
        'Speed'
        'Language'
        'Keywords'
        'OwnedDomains'
        'LinksInCount'
        'SiteData'
      ].join ','
  aws.get options, (err, resp, xml) ->
    return callback err if err
    parser.parseSiteInfoXML xml, callback

request = require('request').defaults jar: false
_       = require 'underscore'
qs      = require 'qs'
crypto  = require 'crypto'

process.env.DEBUG='*'
debug = require('debug') 'awis'

hmacSha1 = (message, secret) ->
  crypto
    .createHmac('sha1', secret)
    .update(message)
    .digest('base64')

sortObject = (object) ->
  keys = _.keys(object).sort()
  sorted = {}
  sorted[key] = object[key] for key in keys
  sorted

exports.get = ({url, key, secret, query}, callback) ->
  query = _(query).extend
    AWSAccessKeyId: key
    SignatureMethod: 'HmacSHA1'
    SignatureVersion: 2
    Timestamp: new Date().toISOString()
  # e.g. with url = awis.amazonaws.com, query will have
  #   Action: 'UrlInfo'
  #   ResponseGroup: 'Rank' (?)
  #   Url: 'yahoo.com'
  query = sortObject query
  queryString = qs.stringify query
  urlRegex = /^http[s]?:\/\/(.*\.com)(.*)/
  match = url.match urlRegex
  host = match[1]
  path = match[2] or '/'

  stringToSign = [
    'GET'
    host
    path
    queryString
  ].join '\n'

  query.Signature = hmacSha1 stringToSign, secret
  query = sortObject query
  queryString = qs.stringify query
  fullUrl = url + '?' + queryString

  request.get fullUrl, callback

async = require 'async'
xml2js = require 'xml2js'

# better version of parseFloat
makeFloat = (string) ->
  return string if typeof string is 'number'
  string = string.replace /,/g, ''
  parseFloat string

# better version of parseInt
makeInt = (string) ->
  return string if not string?
  return string if typeof string is 'number'
  string = string.replace /,/g, ''
  parseInt string

# ### parseXML
#
# @param {String} `xml` the XML string to parse into JSON
# @param {Function} `callback` (err, jsonObject)
exports.parseXML = parseXML = (xml, callback) ->
  parser = new xml2js.Parser()
  parser.parseString xml, callback

# ### parseTopSitesXML
#
# @param {String} `xml` XML string of top sites data from Amazon
# @param {Function} `callback` (err, jsonObject)
exports.parseTopSitesXML = (xml, callback) ->
  async.waterfall [
    (next) -> parseXML xml, next
    (json, next) -> next null, parseTopSitesJSON json
  ], callback

# ### drillIn
#
# @private
drillIn = (object, fields) ->
  return undefined if not object?
  root = object
  for field in fields
    root = root[field][0]
  root

# ### parseSiteData
#
# @private
parseSiteData = (badSiteJSON) ->
  url = drillIn badSiteJSON, ['aws:DataUrl']
  rank = drillIn badSiteJSON, ['aws:Country', 'aws:Rank']
  reachPerMillion = drillIn badSiteJSON, ['aws:Country', 'aws:Reach', 'aws:PerMillion']
  pageViews = drillIn badSiteJSON, ['aws:Country', 'aws:PageViews']
  pageViewsPerMillion = drillIn pageViews, ['aws:PerMillion']
  pageViewsPerUser = drillIn pageViews, ['aws:PerUser']
  result =
    url: url
    rank: makeInt rank
    reach:
      per_million: makeInt reachPerMillion
    page_views:
      per_million: makeInt pageViewsPerMillion
      per_user: makeFloat pageViewsPerUser
  result


# ### parseTopSitesJSON
#
# @param {Object} `json` the object of top sites converted XML -> JSON
# @param {Function} `callback` (err, sites)
exports.parseTopSitesJSON = parseTopSitesJSON = (json) ->
  badJSONRoot = json['aws:TopSitesResponse']
  topSitesData = drillIn badJSONRoot, [
    'aws:Response'
    'aws:TopSitesResult'
    'aws:Alexa'
    'aws:TopSites'
    'aws:Country'
  ]
  totalSites = makeInt topSitesData['aws:TotalSites'][0]
  sitesArray = topSitesData['aws:Sites'][0]['aws:Site']
  parseSiteData(site) for site in sitesArray


# ### parseSiteInfoXML
#
# * `@param {String} xml`
#   XML string of site info from Amazon
# * `@param {Function} callback`
#   (err, jsonObject)
exports.parseSiteInfoXML = parseSiteInfoXML = (xml, callback) ->
  async.waterfall [
    (next) -> parseXML xml, next
    (json, next) -> next null, parseSiteInfoJSON json
  ], callback


parseCountryRank = (json) ->
  code: json['$']['Code']
  rank: json['aws:Rank'][0]
  contribution:
    page_views: drillIn(json, ['aws:Contribution', 'aws:PageViews'])
    users: drillIn(json, ['aws:Contribution', 'aws:Users'])

parseCityRank = (json) ->
  code: json['$']['Code']
  name: json['$']['Name']
  rank: json['aws:Rank'][0]
  contribution:
    page_views: drillIn(json, ['aws:Contribution', 'aws:PageViews'])
    users: drillIn(json, ['aws:Contribution', 'aws:Users'])
    per_user:
      average_page_views: drillIn(json, ['aws:Contribution', 'aws:PerUser', 'aws:AveragePageViews'])

parseUsage = (json) ->
  timeRange = json['aws:TimeRange'][0]
  if timeRange['aws:Months']?
    time_range =
      type: 'months'
      value: makeInt(timeRange['aws:Months'][0])
  else
    time_range =
      type: 'days'
      value: makeInt(timeRange['aws:Days'][0])
  rankData     = drillIn json, ['aws:Rank']
  reachData    = drillIn json, ['aws:Reach']
  pageViewData = drillIn json, ['aws:PageViews']

  time_range: time_range
  rank:
    value: makeInt(rankData['aws:Value'][0])
    delta: makeInt(rankData['aws:Delta'][0])
  reach:
    rank:
      value: makeInt(reachData['aws:Rank'][0]['aws:Value'][0])
      delta: makeInt(reachData['aws:Rank'][0]['aws:Delta'][0])
    per_million:
      value: makeInt(reachData['aws:PerMillion'][0]['aws:Value'][0])
      delta: reachData['aws:PerMillion'][0]['aws:Delta'][0]
  page_views:
    rank:
      value: makeInt(pageViewData['aws:Rank'][0]['aws:Value'][0])
      delta: makeInt(pageViewData['aws:Rank'][0]['aws:Delta'][0])
    per_million:
      value: makeFloat(pageViewData['aws:PerMillion'][0]['aws:Value'][0])
      delta: pageViewData['aws:PerMillion'][0]['aws:Delta'][0]
    per_user:
      value: makeFloat(pageViewData['aws:PerUser'][0]['aws:Value'][0])
      delta: pageViewData['aws:PerUser'][0]['aws:Delta'][0]


parseSubdomain = (subdomain) ->
  timeRange = subdomain['aws:TimeRange'][0]
  if timeRange['aws:Months']?
    time_range =
      type: 'months'
      value: makeInt(timeRange['aws:Months'][0])
  else
    time_range =
      type: 'days'
      value: makeInt(timeRange['aws:Days'][0])

  url: subdomain['aws:DataUrl'][0]
  time_range: time_range
  reach: subdomain['aws:Reach'][0]['aws:Percentage'][0]
  page_views:
    percentage: subdomain['aws:PageViews'][0]['aws:Percentage'][0]
    per_user: makeFloat(subdomain['aws:PageViews'][0]['aws:PerUser'][0])


# ### parseSiteInfoJSON
#
# * `@param {Object} json`
#   the object of site info converted XML -> JSON
# * `@param {Function} callback`
#   (err, siteInfo)
exports.parseSiteInfoJSON = parseSiteInfoJSON = (json) ->
  root = json['aws:UrlInfoResponse']
  root = drillIn root, [
    'aws:Response'
    'aws:UrlInfoResult'
    'aws:Alexa'
  ]
  contactInfo = drillIn root, ['aws:ContactInfo']
  contentData = drillIn root, ['aws:ContentData']
  siteData    = drillIn contentData, ['aws:SiteData']
  speedData   = drillIn contentData, ['aws:Speed']
  # @todo: related data?
  trafficData = drillIn root, ['aws:TrafficData']
  countryData = drillIn(trafficData, ['aws:RankByCountry'])['aws:Country']
  cityData    = drillIn(trafficData, ['aws:RankByCity'])['aws:City']
  usageData   = drillIn(trafficData, ['aws:UsageStatistics'])['aws:UsageStatistic']
  subData     = drillIn(trafficData, ['aws:ContributingSubdomains'])['aws:ContributingSubdomain']

  url: contentData?['aws:DataUrl']?[0]?['_']
  title: siteData?['aws:Title']?[0]
  description: siteData?['aws:Description']?[0]
  speed:
    median_load_time: makeInt(speedData?['aws:MedianLoadTime']?[0])
    percentile: makeInt(speedData?['aws:Percentile']?[0])
  links_in_count: makeInt(contentData?['aws:LinksInCount']?[0])
  rank:
    global: makeInt(trafficData?['aws:Rank']?[0])
    countries: (parseCountryRank(country) for country in countryData ? [])
    cities: (parseCityRank(city) for city in cityData ? [])
  usage_stats: (parseUsage(stat) for stat in usageData ? [])
  subdomains: (parseSubdomain(sub) for sub in subData ? [])

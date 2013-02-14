fs = require 'fs'

badJSON = JSON.parse fs.readFileSync('top_sites.json')
topSites = []

drillIn = (object, fields) ->
  root = object
  for field in fields
    root = root[field][0]
  root

parseSiteData = (badSiteJSON) ->
  url = drillIn badSiteJSON, ['aws:DataUrl']
  rank = drillIn badSiteJSON, ['aws:Country', 'aws:Rank']
  reachPerMillion = drillIn badSiteJSON, ['aws:Country', 'aws:Reach', 'aws:PerMillion']
  pageViews = drillIn badSiteJSON, ['aws:Country', 'aws:PageViews']
  pageViewsPerMillion = drillIn pageViews, ['aws:PerMillion']
  pageViewsPerUser = drillIn pageViews, ['aws:PerUser']
  result =
    url: url
    rank: parseInt rank
    reach:
      per_million: parseInt reachPerMillion
    page_views:
      per_million: parseInt pageViewsPerMillion
      per_user: parseFloat pageViewsPerUser
  result

badJSONRoot = badJSON['aws:TopSitesResponse']
topSitesData = drillIn badJSONRoot, [
  'aws:Response'
  'aws:TopSitesResult'
  'aws:Alexa'
  'aws:TopSites'
  'aws:Country'
]
totalSites = parseInt topSitesData['aws:TotalSites']
sitesArray = topSitesData['aws:Sites'][0]['aws:Site']

console.log '# sites', totalSites
console.log 'sitesArray.length', sitesArray.length

sites = (parseSiteData(site) for site in sitesArray)
console.log 'sites', sites

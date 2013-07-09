###
# Here is the search API
###
# Module variables

config = require(__dirname + '/../config.json')
cache = require('memory-cache')
request = require('request')
async = require('async')
core = require(__dirname + '/../core/core')()
b = undefined
app = undefined
bingAccountKey = undefined

module.exports = (a) ->
  app = a
  # We check configuration 
  if !bingAccountKey
    if config
      bingAccountKey = config.bingAccountKey
      if bingAccountKey is "ENTER YOUR KEY HERE"
        throw new Exception("Please make sure to change your key in config.json")
    else
      throw new Exception('Config file doesn\'t exist, please create it from the config.template.json')
  # app.get "/search/", showHelp

  app.get "/search/:domain", search


search = (req, response) ->
  domain = req.params.domain
  if !domain
    response.send(500, 'Please specify a domain (e.g. jplusplus.org)')
  else
    async.waterfall([
      (onFilesFound)->
        searchFiles domain, onFilesFound
      (files, callback)->
        core.collectMetaData files, callback
      ],
      (error, files)->
        if error is null
            response.send(files)
        else
          response.send(500, error)
      )

searchFiles = (domain, complete)->
  files = []
  
  async.series([
    # we try to get the results from the cache
    (fallback)->
      results = cache.get(domain)
      if results
        complete(null, results)
      else
        fallback()
    ,
    # or we call the core
    ()->
      async.waterfall([
        (doQuery)->
          filetypes = core.getSupportedFileTypes()
          doQuery null, domain, type for type in filetypes
        ,
        # doQuery
        (domain, type, handleBingResults)->
          query = buildBingRequest(type, domain)
          bingRequest query, type, domain, handleBingResults
        ,
        # handleBingResults
        (results, type, domain, callback)->
          async.map(results
            , (result, add_to_files)->
                file = {
                  url: result.Url
                  type: type
                  domain: domain
                }
                # can add some validation stuff maybe 
                add_to_files(null, file)
            , callback)
        ],
        (error, files)->
          cache.put(domain, files)
          complete(error, files)
      )
  ])
  
bingRequest = (query, type, domain, complete) ->
  async.waterfall([
    (callback)->
      request query, callback
    ,
    (res, body, callback)->
      # console.log('request cb', body)
      if body
        results = JSON.parse(body).d.results
      else
        retults = []
      callback(null, results)
  ],
  (error, results)->
    # console.log('bingRequest last cb: ', results, type, domain)
    complete(error, results, type, domain)
  )

buildBingRequest = (type, domain) ->
  # Queries that will be passed to bing to retrieve the list of files we want
  queryString = getQueryForType(type, domain)
  encodedKey = new Buffer("#{bingAccountKey}:#{bingAccountKey}").toString('base64')

  options = {
    'method': 'GET', 
    'uri': "https://api.datamarket.azure.com/Bing/Search/#{queryString}"
    'headers': {
      'Authorization': "Basic #{encodedKey}"
      rejectUnauthorized: false 
    }
  }
  return options

getQueryForType = (type, domain) ->
  bingQueryString = undefined
  queries = []
  bingRequestPoint = "Web"
  if type is 'image'
    bingRequestPoint = "Image"
    queries = [
      { site:domain }
    ]
  if type is 'doc'
    queries = [
      { site:domain, filetype: type, ext: type}
    ]
  if type is 'pdf'
    queries = [
      { site:domain, filetype: type}
    ]
  queryStrings = for query in queries
    do(_query=query) ->
      queryString = for key, val of query
        do(_key=key, _val=val)->
          return "#{key}:#{val}"
      return queryString.join('%20')

  queryString = queryStrings.join('%20OR%20')

  GETParams = {
    '$format':'json'
    '$top': 50
    '$skip': 0
    'Query': "%27#{queryString}%27"
  }

  paramsStrings = for paramKey, paramValue of GETParams
    "#{paramKey}=#{paramValue}"
  paramsString = paramsStrings.join('&')
  bingQueryString = "#{bingRequestPoint}?#{paramsString}"

  return bingQueryString



showHelp = (req, res) ->
  res.render('help', {title: "About Documents from domain"})

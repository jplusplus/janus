###
# Here is the search API
###
# Module variables

config = require(__dirname + '/../config.json')

core = require(__dirname + '/../core/core')
request = require('request')
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
    res.respond(500, 'You have to specify a domain')

  params = {
    domain: req.params.domain
    filetypes: ['pdf']
    # filetypes: core.getSupportedFileTypes()
  }
  # b.search "#{req.params.domain} filetype:pdf", (er, res, bod)->
    # response.send(bod)
  bingRequest params, (res) ->
    response.send(res)



getQueryForType = (type, domain) ->
  query = {}
  if ['jpg','pdf'].indexOf(type) != -1
    query.site = domain 
    query.filetype = type
  return query

buildBingRequest = (params) ->
  # Queries that will be passed to bing to retrieve the list of files we want
  queries = []
  domain = params.domain
  for filetype in params.filetypes
    do(type=filetype,_queries=queries,_domain=domain) ->
      query = getQueryForType(type,_domain)
      _queries.push query

  queryStrings = for query in queries
    do(_query=query) ->
      queryString = for key, val of query
        do(_key=key, _val=val)->
          return "#{key}:#{val}"
      return queryString.join('%20')

  queryString = "%27" + queryStrings.join('%20OR%20')  + "%27"

  GETParams = {
    '$format':'json'
    '$top': 50
    '$skip': 0
    'Query': queryString
  }

  paramsStrings = for paramKey, paramValue  of GETParams
    "#{paramKey}=#{paramValue}"
  console.log('paramsStrings: ', paramsStrings)

  paramsString = paramsStrings.join('&')
  encodedKey = new Buffer("#{bingAccountKey}:#{bingAccountKey}").toString('base64')
  console.log('encoded key: ', encodedKey)



  options = {
    'method': 'GET', 
    'uri': "https://api.datamarket.azure.com/Bing/Search/Web?#{paramsString}"
    'headers': {
      'Authorization': "Basic #{encodedKey}",
    }
  }
  console.log('options:', options);
  return options

bingRequest = (params, callback) ->
  options = buildBingRequest(params)
  request options, (error, res, body) ->
    callback(body)

showHelp = (req, res) ->
  res.render('help', {title: "Help about Document from Website"})
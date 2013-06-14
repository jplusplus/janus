###
# Here is the search API
###
# Module variables

config = require(__dirname + '/../config.json')

request = require('request')
core = require(__dirname + '/../core/core')()
b = undefined
app = undefined
bingAccountKey = undefined

module.exports = (a) ->
  # console.log(core.getSupportedFileTypes())
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
    res.respond(500, 'Please specify a domain (e.g. jplusplus.org)')

  params = {
    domain: req.params.domain
    filetypes: core.getSupportedFileTypes()
  }
  # b.search "#{req.params.domain} filetype:pdf", (er, res, bod)->
    # response.send(bod)
  bingRequest params, (results, type, domain) ->
    files = []
    metas = []
    for result in results
      do(_r=result, _f=files, _type=type, _domain=domain)->
        file = {
          url: _r.Url
          type: _type
          domain: _domain
        }
        # console.log('file: ', file);
        _f.push(file)

    for file in files
      do(file,metas=metas) ->
        core.getMetaData file, (error,file, meta, _metas=metas)->
          console.log("getMetaData callback: recieved meta = ", meta)
          if error is undefined
            if meta
              _metas.push(meta)
            else
              console.log("Failed to get #{file.url} meta data")
          else
            console.log('An error occured when retrieving meta data: ', error)

    response.send metas

bingRequest = (params, callback) ->
  # console.log(params)
  domain = params.domain
  for type in params.filetypes
    do(_type=type,_domain=domain)->
      query = buildBingRequest(_type, _domain)
      request query, (error, res, body)->
        results = JSON.parse(body).d.results
        callback results, _type, _domain

buildBingRequest = (type, domain) ->
  # Queries that will be passed to bing to retrieve the list of files we want
  queryString = getQueryForType(type, domain)
  # console.log("buildBingRequest() -  queryString = #{queryString}")
  encodedKey = new Buffer("#{bingAccountKey}:#{bingAccountKey}").toString('base64')

  options = {
    'method': 'GET', 
    'uri': "https://api.datamarket.azure.com/Bing/Search/#{queryString}"
    'headers': {
      'Authorization': "Basic #{encodedKey}",
    }
  }
  # console.log('options:', options);
  return options

getQueryForType = (type, domain) ->
  # console.log('getQueryForType(',type,',',domain, ')')
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

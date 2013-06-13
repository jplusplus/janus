###
# Here is the search API
###
# Module variables
app = undefined
module.exports = (a) ->
  app = a
  # app.get "/search/", showHelp
  app.get "/search/:json", search


search = (req, res) ->
  params = req.params.json
  console.log params
  # we test if the parameters are correct

  # if not we send an error 
  requestURL = buildBingRequest(params)

  ### 
  # This method handle the search and respond as JSON 
  # it accept json params as described below. 
  # It will basicly perform a search on Bing API to retreive of files from a 
  # web site. 
  # @param :json - the json parameters
  # { 
  #   domain: ""    # (JSON String) represents the domain to search documents (e.g: jplusplus.org)
  #   filetypes: [] # (JSON Array) an array containing of filetypes to search
  # }
  # 
  ###
  # jsonParams = req.params('json')
  # do stuff
  # req.param('')
  # then setup the response 
  # extract json etc..
  # res.send(jsonstuff)
  res.send({});


showHelp = (req, res) ->
    res.render('help', {title: "Help about Document from Website"})


buildBingRequest = (params) ->
    return ""

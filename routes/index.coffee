###
# GET home page.
####
# Module variables
app = undefined
module.exports = (a) ->
  app = a
  app.get('/', rootPage)
  # include the search API routes
  require('./search') app

rootPage = (req, res) ->
  res.render('index', { title: 'Document From Website' })

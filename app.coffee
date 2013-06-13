
### 
# Module dependencies.
###

express = require('express')
http = require('http')
path = require('path')

app = express()

app.configure ->
  app.set('port', process.env.PORT || 3000)
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  ### Public assets managers ###
  app.use require("connect-assets")(src: __dirname + "/public")
  app.use express.static(path.join(__dirname, "public"))

  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.json()
  app.use express.methodOverride()
  app.use app.router

  routes = require("./routes/index") app

app.configure 'development', -> 
  app.use express.errorHandler()

http.createServer(app).listen app.get('port'), ->
    console.log "Express server listening on port ", app.get('port')


async = require('async')

class Core

  constructor: ()->
    @SUPPORTED_FILE_TYPES = ['pdf']
    @PROCESSORS = []
    # we create FileProcessors here and store them in an array
    for type in @SUPPORTED_FILE_TYPES
      do(_type=type, me=this)->
        processor = FileProcessorFactory.prototype.newFileProcessor(_type)
        me.PROCESSORS[_type] = processor

  getSupportedFileTypes: () =>
    return @SUPPORTED_FILE_TYPES


  ### 
  Entry point of the core module
  ```
  core require('core/core') 
  core.collectMetaData(file, callback)
  ```
  ###
  collectMetaData:(files, complete) =>
    me = this
    async.waterfall [
      (callback) ->
        me.downloadFiles(files, callback)
      ,
      (downloaded_files, callback)->
        me.checkDownloadedFiles(downloaded_files, callback)
      ,
      (checked_files, callback)->
        me.getMetaData(checked_files, callback)
    ],
    (err, metas)->
      complete(err, metas)

  downloadFiles: (files, complete) =>
    me = this
    async.map(files, me.downloadFile, complete)

  checkDownloadedFiles: (files, complete) =>
    me = this
    async.filter(files, me.checkFile, (res)->
      complete(null, res)
    )

  checkFile:(file, filter)=>
    async.waterfall [
      (callback)->
        fs.stat(file.path, callback)
      , 
      (stats, callback) ->
        callback(null, (stats.size > 0))
      ], 
      (err, accepted)->
        if err
          accepted = false
        if !accepted
          fs.unlinkSync file.path
        filter(accepted)

  downloadFile: (file, callback) =>
    request = require('request')
    url = file.url
    url_splitted = url.split('/')
    file_name = url_splitted[url_splitted.length - 1]
    tmp_path = "#{__dirname}/../tmp/#{file_name}"
    fake_agent = {
      "User-Agent": "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.97 Safari/537.11",
    }
    if !fs.existsSync(tmp_path)
      out = fs.createWriteStream(tmp_path)
      req = request({
        method: 'GET'
        uri: url
        headers: fake_agent
      })
      req.pipe(out)
      req.on 'end', (err,cb=callback)->
        file.path = tmp_path
        cb(null, file)
    else
      file.path = tmp_path
      callback(null, file)

  getMetaData: (files, complete) =>
    me = this 
    async.map files, me.getMetaDataFromFile, complete

  getMetaDataFromFile: (file, callback) =>
    type = file.type
    processor = @PROCESSORS[type]
    if processor is undefined
      error = new Error("Could not find the appropriated for your filetype: #{type}")
      callback(error)
    else
      processor.getMetaData(file, 
        (error, _file, _data) ->
          fs.unlinkSync file.path 
          out = file: _file, meta: _data
          callback(error, out)
      )

  

class FileProcessorFactory
  newFileProcessor: (type) ->
    if type is "pdf"
      return require('./pdf')

# Enter point for the module, returns an instance of Core class. 
fs = undefined
http = undefined
https = undefined
core_instance = undefined
module.exports = ()->
  if !fs
    fs = require('fs')
  if !http
    http = require('http')
  if !https 
    https = require('https')
  if core_instance is undefined
    core_instance = new Core()
  return core_instance


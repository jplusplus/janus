async = require('async')
cache = require('memory-cache')
request = require('request')

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
  @param remote_files

  @usage: 
    core require('core/core') 
    core.collectMetaData(file, callback)
  ###
  collectMetaData:(remote_files, complete) =>
    me = this
    async.parallel([
      (callback)->
        # we get the meta from the files that are present in cache 
        async.filter remote_files, me.checkFromCache, (files_from_cache)->
          console.log('filter from cache cb - nb files_from_cache: ', files_from_cache.length)
          me.getMetaFromCache(files_from_cache, callback)
      ,
      (callback)->
        # and from the files that aren't in cache 
        async.reject remote_files, me.checkFromCache, (files_not_in_cache) ->
          me.getMetaFromRemoteFiles(files_not_in_cache, callback)
      ],
      (err, results)->
        concat_results = results[0].concat(results[1])
        complete(null, concat_results)
      )

  checkFromCache: (file, filter) =>
    filter(cache.get(file.url) != null)

  getMetaFromCache: (files, complete) =>
    me = this
    async.map files, 
      (file, add_to_metas)->
        meta = cache.get(file.url)
        add_to_metas(null, meta)
      , complete

  getMetaFromRemoteFiles: (remote_files, complete) =>
    me = this
    async.waterfall(
      [
        (callback)->
          # we download every remote file
          async.map remote_files, me.downloadFile, callback
        ,
        # check every file to see if file is missing or empty 
        me.checkFiles
      ],
      (files)->
          # we get every meta data from downloaded & checked files
          async.map files, me.getMetaDataFromFile, complete
    )
  checkFiles: (files, complete) =>
    me = this
    async.filter files, me.checkFile, complete

  checkFile:(file, filter)=>
    path = file.path
    async.waterfall([
      (callback)->
        fs.exists path, (exists)-> callback(null, exists)
      ,
      (exists, callback)->
        if !exists
          filter(exists)
        else
          fs.stat path, callback
    ],
      (error, stats)->
        filter((stats.size > 0))
    )

  downloadFile: (file, callback) =>
    url = file.url
    url_splitted = url.split('/')
    # console.log("downloadFile(#{file.url})");

    file_name = url_splitted[url_splitted.length - 1]
    tmp_path = "#{__dirname}/../tmp/#{file_name}"
    fake_agent = {
      "User-Agent": "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.97 Safari/537.11"
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

  getMetaDataFromFile: (file, callback) =>
    type = file.type
    processor = @PROCESSORS[type]
    if processor is undefined
      error = new Error("Could not find the appropriated for your filetype: #{type}")
      callback(error)
    else
      processor.getMetaData(file,
        (error, file, data) ->
          fs.unlinkSync file.path 
          out = file: file, meta: data
          cache.put(file.url, out)
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

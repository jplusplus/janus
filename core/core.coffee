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
  core.getMetaData(file, callback)
  ```
  @param remote_file
    The file object:
    {
       url: the url of the file to extract meta data
       type: the type of the file to analyse
    }
  @param callback
    the callback to call when meta data has been retrieved by the core module
    take 2 parameters: 
      meta: the metadata extracted
      error: if extraction had failed then this variable will be set
  ###  
  getMetaData: (remote_file, callback) =>
    # console.log('getMetaData(',remote_file,')')
    me = this
    if remote_file.url is undefined
      error = new ReferenceError('The file url must be filled')
    if remote_file.type is undefined
      error = new ReferenceError('The file type must be filled')

    if error is undefined 
      me.downloadFile remote_file, (tmp_file, _me=me) ->
        # console.log('downloadFile callback, file:',tmp_file)
        _me.getMetaDataFromFile tmp_file, (meta, error, path=tmp_file.path)=>
          if error is undefined
            fs.unlinkSync(path)
          callback(meta, error)
    else
      callback(undefined, error)

  getMetaDataFromFile: (file, callback)=>
    processor = @PROCESSORS[file.type]
    if processor is undefined
      error = new Error("Could not find the appropriated for your filetype: #{file.type}")
      callback(undefined, error)
    else 
      processor.getMetaData(file, callback)

  downloadFile: (file, callback) =>
    url = file.url
    url_splitted = url.split('/')
    file_name = url_splitted[url_splitted.length - 1]
    tmp_folder = "#{__dirname}/../tmp/"
    tmp_path  = "#{tmp_folder}#{file_name}"
    # console.log(tmp_path)

    stream = fs.createWriteStream(tmp_path)
    request = http.get url, (res,_file=file)->
      res.pipe(stream)
      # _file.path = tmp_path
      callback(_file)


class FileProcessor
  getMetaData: (path, callback)=>
    ###
    # This method is just a signature, have to be implemented in inherited classes
    # @see PdfFileProcessor
    ###



class PdfFileProcessor extends FileProcessor
  getMetaData: (file, callback)=>
    meta = {}    
    error = undefined
    callback(file, meta, error)


class FileProcessorFactory
  newFileProcessor: (type) ->
    if type is "pdf"
      return new PdfFileProcessor()


fs = undefined
http = undefined
core_instance = undefined
module.exports = ()->
  if !fs
    fs =  require('fs')
  if !http
    http =  require('http')
  if core_instance is undefined
    core_instance = new Core()
  return core_instance


SUPPORTED_FILE_TYPES = []
PROCESSORS = []

fs = require('fs')
http = require('http')

module.exports = () ->
  SUPPORTED_FILE_TYPES = ['pdf']
  # we create FileProcessors here and store them in an array
  for type in SUPPORTED_FILE_TYPES
    do(_type=type)->
      processor = FileProcessorFactory.registerFileProcessor(_type)
      PROCESSORS[_type] = processor;

exports.getMetaData = (remote_file, callback)->
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
  
  if file.url is undefined
    error = new Exception('The file url must be filled')
  if file.type is undefined
    error new Exception('The file type must be filled')

  if error is undefined 
    downloadFile remote_file, (tmp_file, _callback=callback)->
      getMetaDataFromFile tmp_file, (meta, error, path=tmp_file.path, _callback=_callback)->
        if error is undefined
          fs.unlinkSync(path)
        _callback(meta, error)
  else
    _callback(undefined, error)


getMetaDataFromFile = (file, callback)->
  processor = PROCESSORS[file.type]
  if processor is undefined
    error = new Exception("Could not find the appropriated for your filetype: #{file.type}")
    callback(undefined, error)
  else 
    processor.getMetaData(file, callback)

downloadFile = (file, callback) ->
  url = file.url
  url_splitted = url.split('/')
  file_name = url_splitted[url_splitted.length - 1]
  tmp_folder = "#{__dirname}/../tmp/"
  tmp_path  = "#{tmp_folder}#{file_name}"
  console.log(tmp_path)

  file = fs.createWriteStream(tmp_path)
  request = http.get url, (res, _cb = callback)->
    res.pipe(file)
    _cb({path: tmp_path, type: file.type, url:url, domain: file.domain })


exports.getSupportedFilesTypes = () ->
  return SUPPORTED_FILE_TYPES

class FileProcessor
  getMetaData: (path, callback)=>
    ###
    # This method is just a signature, have to be implemented in inherited classes
    # @see PdfFileProcessor
    ###



class PdfFileProcessor extends FileProcessor
  getMetaData: (path, callback)=>
    



class FileProcessorFactory 
  newFileProcessor: (type) ->
    if type == "pdf"
      return new PdfFileProcessor()



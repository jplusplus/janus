# Janus

## Extract metadata from PDFs, fast
Janus is a simple tool to extract all meta data from all PDF files on a single domain. Type in a domain name, for instance "gov.uk", and get a list of all PDFs with their metadata (e.g. Author, creation and modification date). Metadata analysis is a great source of information for investigative journalists.
In the future, Janus will include other data types and go further in the analysis, clustering metadata together (like individuals who appear in the metadata).
It was developed by Journalism++' [Pierre Bellon](http://twitter.com/toutenrab) and [Leo Wallentin](http://twitter.com/leo_wallentin), who was an embedded news nerd there in June, 2013.

## How to install it 
- be sure to have nodeJS installed on your computer
- get the sources
  ```git clone https://github.com/jplusplus/documents-from-domains.git```
- install the dependencies

  ```
    cd janus
    npm install
  ```
- copy the configuration file template

  ```
  cp config.template.json config.json 
  ```
- then enter your bing account key 

## Launch the application
You can simply launch it by executing ```coffee app.coffe``` but I recommend you to use nodemon:
```
npm install -g nodemon
nodemon app.coffee
``` 

## Troubleshooting
- I get an error when I run npm install
  | You may have an older version of node, please make sure to have node >= 9.4.1 installed on your system

## TODO
- handle images search
- handle doc & docx search 

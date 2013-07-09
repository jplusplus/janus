# Documents from domains
## How to install it 
- be sure to have nodeJS installed on your computer
- get the sources
  ```git clone https://github.com/jplusplus/documents-from-domains.git```
- install the dependencies

  ```
    cd documents-from-domains
    npm install
  ```
- copy the configuration file template

  ```
  cp config.template.json config.json 
  ```
- then enter your bing account key 

The server will need to have pdfinfo, exiv2 and wv installed. 

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

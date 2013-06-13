# Document from website
## How to install it 
- be sure to have nodeJS installed on your computer
- get the sources
  ```git clone https://github.com/pbellon/documents-from-domains.git```
- install the dependencies

  ```
    cd documents-from-website
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


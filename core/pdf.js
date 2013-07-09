/************************************/
/* PDF File processor for Janus     */
/*                                  */
/* Methods:                         */
/* getMetadata( file [, callback] ) */
/* getFiletype()                    */
/*                                  */
/* Requires lib/pdfinfo.js          */
/*                                  */
/************************************/


/* Tags with a special meaning. All lower case */
var specialTags = {
					'author'					: 'person',
					'creator'					: 'software',
					'producer'					: 'software',
					'xmp:creatortool'			: 'software',
					'dc:publisher'				: 'software',
					'dc:contributor'			: 'person',
				};


/* getMetadata( file [, callback] )             */
/* Will call callback( error, file, data );     */
exports.getMetaData = function (file, callback) {

	var error;

	/* check that file is a file object */
	if( !("type"   in file) 
	  ||!("path"   in file)
 	  ||!("domain" in file)
	  ||!("url"    in file) ) {
	  	error = new Error("First argument to getMetadata should look like this: {type:'pdf', path:'local/path', domain:'domain.com', url:'domain.com/original/url'} " );
		callback(error);
	}

	/* Default callback function: console.log */
	callback = typeof callback !== 'undefined' ? callback : function(data) {console.log(data);};

	/* Check that file exists */
	var fs = require('fs');
	if (!fs.existsSync(file.path)) {
		error = new Error("Could not find file "+ file.path);
		callback(error);
		return;
	}

	/* Get Metadata */
	var PDF = require('./pdfinfo');
	if ( !PDF ){
		error = new Error("Failed to load the pdfinfo library.")
		callback(error);
	}
	var pdf = PDF(file.path);
	pdf.info(function(err, tags){

		if ( err ){
			error = new Error("Failed to read pdf: "+err)
			callback(error);
		}

		/* Collect all tags with a predefined meaning (specialTags) */
		if (tags) {
			var st = {};/* Will hold the special tags for this file */
			for (var key in tags) {

				if ( type = specialTags[key.toLowerCase()] ) {

					/* Create this key if it doesn't exist */
					if(typeof st.type === 'undefined'){
						st[type] = [];
					};
					
					/* Do some cleaning up of the value */
					var val = tags[key];
					val = val.replace('lang=\"x-default\" ','');
					/* Split key. Most of the times , and ; are used to separate values. */
					valarr = val.split("/[,;]/");
					/* Merge arrays. Also removes duplicates*/
					st[type].push.apply(st[type],valarr);

				}//if special tag

			} //for key in tags

		}//if tags
		
		/* Send the result back */
		callback( error, file, {'entities':st,'tags':tags} );
	});

}

/* getFiletype( )    */
/* Returns the filetype this fileprocessor can handle */
exports.getFiletype = function() {
	return('pdf');
}

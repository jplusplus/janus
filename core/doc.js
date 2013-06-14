/************************************/
/* MSWord file processor for Janus  */
/*                                  */
/* Methods:                         */
/* getMetadata( file [, callback] ) */
/* getFiletype()                    */
/*                                  */
/* Requires wvSummary to beinstalled*/
/*                                  */
/************************************/

	
/* Tags with a special meaning. All lower case */
var specialTags = {
					'creator' 				: 'person',
					'last saved by'			: 'person',
					'generator'				: 'software',
					'generator'				: 'software.template',
					'company'				: 'organisation',
				};

/* Wrap strings in stuff */				
String.prototype.wrap = function (char) {
	char = typeof char !== 'undefined' ? char : '"';
    return(char+this+char);
};


/* getMetadata( file [, callback] )             */
/* Will call callback( error, file, data );     */
exports.getMetadata = function (file, callback) {

	var error;

	/* check that file is a file object */
	if( !("type"   in file) 
	  ||!("path"   in file)
 	  ||!("domain" in file)
	  ||!("url"    in file) ) {
	  	error = new Error("First argument to getMetadata should look like this: {type:'doc', path:'local/path/file.doc', domain:'domain.com', url:'domain.com/original/url/file.doc'} " );
		callback(error);
	}

	/* Default callback function: console.log */
	callback = typeof callback !== 'undefined' ? callback : function(data) {console.log(data);};

	/* Get Metadata */
	var sys = require('sys')
	var exec = require('child_process').exec;
	var child;

	if ( !exec ){
		error = new Error("Failed to initiate exec.")
		callback(error);
	}
	
	/* Get metadata via wvSummary */
	child = exec("wvSummary "+file.path.wrap(), function(err, out) {
	
		if ( err ){
			error = new Error("Failed to read image: "+err)
			callback(error);
		}

		/* Create an array of tags */		
		var st = {};/* Will hold the special tags for this file */
		tags = {};/* Will hold all tags */
		arr = out.split("\n");
		arr.forEach( function( row ) {
			pair = row.trim().replace(/\"/g,"").split(" = ");
			
			if ( 'undefined' !== typeof pair[1] ) {
				tags[pair[0]] = pair[1];
			}
			
			if ( type = specialTags[pair[0].toLowerCase()] ) {
				if(typeof st.type === 'undefined'){
					st[type] = [];
				};

				/* Do some cleaning up of the value */
				var val = pair[1];
				val = val.replace('lang=\"x-default\" ','');
				/* Split key. Most of the times , and ; are used to separate values. */
				valarr = val.split("/[,;]/");
				/* Merge arrays. Also removes duplicates*/
				st[type].push.apply(st[type],valarr);

			}//if special tag

		});
		
		/* Send the result back */
		callback( error, file, {'entities':st,'tags':tags} );
	});

}

/* getFiletype( )    */
exports.getFiletype = function() {
	return('doc');
}

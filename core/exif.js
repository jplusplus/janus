/************************************/
/* Image File processor for Janus   */
/* The name is misleading --        */
/* will get way more than just exif */
/*                                  */
/* Methods:                         */
/* getMetadata( file [, callback] ) */
/* getFiletype()                    */
/*                                  */
/* Requires exiv2                   */
/*                                  */
/************************************/

/* Tags with a special meaning. All lower case */
var specialTags = {
					'exif.artist'					: 'person',
					'exif.software'					: 'software',
					'exif.copyright'				: 'person',
					'exif.ownername'				: 'person',
					'exif.lensserialnumber'			: 'camera.lens',
					'exif.serialnumber'				: 'camera',
					'exif.xpauthor'					: 'person',
					'exif.image.software'			: 'software',
					'iptc.application2.writer'		: 'person',
					'xmp.acdsee.author'				: 'person',
					'xmp.aux.ownername'				: 'person',
					'xmp.aux.serialnumber'			: 'camera',
					'xmp.aux.firmware'				: 'camera',
					'xmp.aux.lensid'				: 'camera.lens',
					'xmp.aux.lens'					: 'camera.lens',
					'xmp.cc.attributionname'		: 'person',
					'xmp.cc.attributionurl'			: 'person.url',
					'xmp.dc.contributor'			: 'person',
					'xmp.dc.creator'				: 'person',
					'xmp.dc.rights'					: 'person',
					'xmp.digikam.captionsauthornames': 'person',
					'xmp.extensis.approvedby'		: 'person',
					'xmp.extensis.clientname'		: 'person',
					'xmp.iptc4xmpcore.creatorcontactinfo': 'person',
					'xmp.iptccore.creatorcontactinfo': 'person',
					'xmp.photoshop.captionwriter'	: 'person',
					'xmp.photoshop.credit'			: 'person',
					'xmp.plus.copyrightowner'		: 'person',
					'xmp.plus.imagecreator'			: 'person',
					'xmp.copyrightowner.copyrightownername': 'person',
					'xmp.enduser.endusername'		: 'person',
					'xmp.imagecreator.imagecreator'	: 'person',
					'xmp.prism.corporateentity'		: 'organisation',
					'xmp.tiff.artist'				: 'person',
					'xmp.tiff.copyright'			: 'person',
					'xmp.tiff.software'				: 'software',
					'xmp.xmp.author'				: 'person',
					'xmp.xmp.creatortool'			: 'software',
					'xmp.xmp.toolkit'				: 'software',
					'xmp.xmpdm.artist'				: 'person',
					'xmp.xmpdm.copyright'			: 'person',
					'xmp.version.modifier'			: 'person',
					'xmp.vrae.image.source'			: 'organisation',
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
	  	error = new Error("First argument to getMetadata should look like this: {type:'image', path:'local/path/file.jpg', domain:'domain.com', url:'domain.com/original/url/file.jpg'} " );
		callback(error);
	}

	/* Default callback function: console.log */
	callback = typeof callback !== 'undefined' ? callback : function(data) {console.log(data);};

	/* Get Metadata */
	var exiv = require('exiv2');
	if ( !exiv ){
		error = new Error("Failed to load the exiv library.")
		callback(error);
	}
	
	exiv.getImageTags(file.path, function(err, tags) {
	
		if ( err ){
			error = new Error("Failed to read image: "+err)
			callback(error);
		}
console.log(tags);
		
		/* Collect all tags with a defined meaning (specialTags) */
		if (tags) {
			var st = {};/* Will hold the special tags for this file */
			for (var key in tags) {

				if ( type = specialTags[key.toLowerCase()] ) {
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
exports.getFiletype = function() {
	return(['jpeg','exv','cr2','crw','mrw','tiff','dng','nef','pef','arw','rw2','sr2','srw','orf','png','pgf','raf','eps','xmp','gif','psd','tga','bmp','jp2']);
}

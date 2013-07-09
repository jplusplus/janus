# Namespace configuration for widgets:
window.janus = {}

Widget = window.serious.Widget



class janus.SearchWidget extends Widget
	constructor: ->
		@ACTIONS = [
			'search'
		]

		@UIS = {
			'searchFormInput': '.form-search input',
			'resultsHolder': '.search-results table',
			'resultTemplate': '.search-results .template.result'
			'emptyResultTemplate': '.search-results .template.empty-results'
		}

		@options = {
			searchAPI: '/search'
		}
		@cache = {
		}

	bindUI: (ui) =>
		super
		# bind the submit event of the search input field to the @search function
		@uis.searchFormInput.submit @search

	search: (e) =>
		me = this 
		e.preventDefault();
		domain = me.uis.searchFormInput.val();
		api_url = "#{@options.searchAPI}/#{domain}/"
		me.uis.resultsHolder.addClass('js-loading')
		me.uis.resultsHolder.find('tr.actual').remove()
		$.ajax
			type: 'GET'
			url: api_url
			success: (data) =>
				me.uis.resultsHolder.removeClass('js-loading')
				if (data == null) || (data.length == 0) || !data
					me.showEmptyResults()
				else
					me.addResult result for result in data

	showEmptyResults: ()=>
		me = this
		template = me.cloneTemplate(me.uis.emptyResultTemplate)
		template.insertBefore(me.uis.resultTemplate)

	addResult: (result)=>
		me = this
		file = result.file
		entities = result.meta.entities
		fn = me.getFilename(file.url)
		fn = decodeURI(fn)

		template = me.cloneTemplate(me.uis.resultTemplate, 
		{
			'filename': fn || "",
			'type': 		result.file.type  || "",
			'person': 	entities.person   || "",
			'tags': 		entities.tags     || "",
			'software': entities.software || ""
		}, false)

		template.find('.link a').attr('href', file.url)
		template.insertBefore(me.uis.resultTemplate)						
		
	getFilename: (url)=>
		url_splitted = url.split('/')
		return url_splitted[url_splitted.length - 1] 

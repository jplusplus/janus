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
			'resultsHolder': '.search-results pre'
		}

		@options = {
			searchAPI: '/search'
		}
		@cache = {
		}

	bindUI: (ui) =>
		super
		@uis.searchFormInput.submit @search

	search: (e) =>
		e.preventDefault();
		domain = @uis.searchFormInput.val();
		api_url = "#{@options.searchAPI}/#{domain}/"  
		$.ajax
			type: 'GET'
			url: api_url
			success: (data) =>
				str = JSON.stringify(data)
				@uis.resultsHolder.text str 

# Namespace configuration for widgets:
window.dfw = {}

Widget = window.serious.Widget



class dfw.SearchWidget extends Widget
	constructor: ->
		@ACTIONS = [
			'search'
		]

		@UIS = {
			'searchFormInput': '.form-search input'
		}

		@options = {
			searchAPI: '/search/'
		}
		@cache = {
		}

	bindUI: (ui) =>
		super

	search: (e) =>
		params = {
			domain: @uis.searchFormInput.text(),
			filetype: ["pdf"]
		}
		$.ajax
			type: 'GET'
			url: @options.searchAPI
			data: JSON.stringify(params)
			success: (data) ->
				@uis.resultsHolder.append(data)

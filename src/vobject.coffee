
format  = require('util').format

_ 		= require 'underscore'
moment 	= require 'moment'

class vProperty
	constructor: (@key, @value) ->

	escape: (str) ->
		str.replace(/\r\n/g, '\\n')
		   .replace(/;/g, '\\;')
		   .replace(/\r/g, '\\n')
		   .replace(/\n/g, '\\n')
		   .replace(/,/g, '\\,')

	wrap: (line) ->
		lines = []
		number_of_lines = Math.ceil(line.length / 75) - 1

		for i in [0..number_of_lines]
			part = line.substring(i * 75, Math.min((i + 1) * 75, line.length))
			lines.push part

		lines.join "\r\n "

	stringifyValue: () ->
		@value

	stringifyKey: () ->
		@key

	toICS: () =>
		line = @stringifyKey().toUpperCase() + ":" + @escape(@stringifyValue())
		@wrap(line) + "\r\n"

class vStringProperty extends vProperty
	constructor: (@key, @value) ->

class vDateProperty extends vProperty
	constructor: (@key, @value, @allday=false) ->

	stringifyValue: () ->
		# let moment handle the parsing
		if @allday
			return moment(@value).format 'YYYYMMDD'
		else
			return moment(@value).utc().format('YYYYMMDDTHHmmss') + 'Z'

	stringifyKey: () ->
		if @allday
			return @key + ";VALUE=DATE"
		else
			return @key


class vObject
	constructor: (@type) ->
		@properties = []
		@components = []
		@type = @type.toUpperCase()

	addProperty: (prop) =>
		@properties.push prop

	addComponent: (comp) =>
		@components.push comp

	set: (key, value) =>
		value = +value if _.isNumber(value)
		prop = null

		if _.isString(value)
			prop = new vStringProperty(key, value)
		else if _.isObject(value)
			prop = new vDateProperty(key, value, false)

		@addProperty prop

	setDate: (key, value, allday=false) ->
		@addProperty new vDateProperty(key, value, allday)

	toICS: () =>
		props = @properties.map (x) -> x.toICS()
		comps = @components.map (x) -> x.toICS()
		"BEGIN:#{@type}\r\n" + props.join("") + comps.join('') + "END:#{@type}\r\n"

class vEvent extends vObject
	constructor: () ->
		super 'VEVENT'

class vCalendar extends vObject
	constructor: (generator='Fast vCalendar for node.js', calscale='GREGORIAN') ->
		super 'VCALENDAR'

		@set "version", "2.0"
		@set "calscale", calscale
		@set "prodid", "-//#{generator}//EN"

	addEvent: (event) =>
		@addComponent event
	
module.exports = exports = 
	vCalendar: vCalendar
	vEvent: vEvent
	vDateProperty: vDateProperty
	vStringProperty: vStringProperty
	vProperty: vProperty

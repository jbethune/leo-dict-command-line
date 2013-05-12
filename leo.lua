module( "leo", package.seeall )

local http = require "socket.http"
local flow = require "ltn12"

function get_document( url )
	local tab = {}
	local response = http.request{
		url = url,
		sink = flow.sink.table( tab )
	}
	return table.concat( tab )
end

function ansi_format( s, code )
	local escape = string.char( 27 ) .. "["
	local reset = escape .. "0m"
	return escape .. code .. "m" .. s .. reset
end

function invert( s )
	return ansi_format( s, 7 )
end

function underline( s )
	return ansi_format( s, 4 )
end

function render_html( code )
	for i, junk in ipairs{ "&bsp", "</?small>", "</?sup>" } do
		code = string.gsub( code, junk, "" )
	end
	code = string.gsub( code, "<i>(.-)</i>?", invert )
	return string.gsub( code, "<b>(.-)</b>", underline )
end

function print_section( section )
	local _, name_end, section_name = string.find(
		section,
		'<h2>(.-)</h2>' )
	local tbody_start, _ = string.find(
		section,
		'<tbody>',
		name_end,
		true )
	local row_area = string.sub( section, tbody_start )

	print( invert( '== ' .. section_name .. ' ==' ) )
	for row in string.gmatch( row_area, '<tr>(.-)</tr>' ) do
		row = row.gsub( row, "\n", "" )
		local i = 1
		local first, second = "", ""
		for cell in string.gmatch( row, '<td[^>]*>(.-)</td>' ) do
			if i == 5 then
				first = render_html( cell )
			elseif i == 8 then
				second = render_html( cell )
				break
			end
			i = i + 1
		end
		print( first, "\t", second ) --I'm still thinking about nicer output strategies
	end
end

local url = "http://dict.leo.org/ende/?lang=%s&search=%s" 
local languages = arg[ 2 ] or "en" --language conversion parameter
local term = arg[ 1 ] --term to look up

if not term then
	print "Please supply a term for translation"
	return -1
end

local page = get_document( string.format( url, languages, term ) )
for section in string.gmatch( page, 'id="section%-%d+".-</tbody>' ) do
	print_section( section )
end

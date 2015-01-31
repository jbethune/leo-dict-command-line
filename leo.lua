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
	for i, junk in ipairs{ '&bsp', '&#160;', '</?small>', '</?sup>' } do
		code = string.gsub( code, junk, "" )
	end
	code = string.gsub( code, "<i>(.-)</i>?", invert )
	return string.gsub( code, "<b>(.-)</b>", underline )
end

function print_section( section )
	local _, _, section_name = string.find(
		section,
		'sctTitle="(.-)"' )

	print( invert( '== ' .. section_name .. ' ==' ) )
	for a, b in string.gmatch( section, '<entry[^>]*>.-<repr>(.-)</repr>.-<repr>(.-)</repr>.-</entry>' ) do
		print( render_html( a ), '\t', render_html( b ) ) -- Output format may change in the future
	end
end

local url = 'https://dict.leo.org/dictQuery/m-vocab/%sde/query.xml?tolerMode=nof&lp=%sde&lang=de&rmWords=off&rmSearch=on&directN=0&search=%s&searchLoc=0&resultOrder=basic&multiwordShowSingle=on&sectLenMax=16'
local language = arg[ 2 ] or "en"
local term = arg[ 1 ] --term to look up

if not term then
	print "Please supply a term for translation"
	return -1
end

local page = get_document( string.format( url, language,language, term ) )

for section in string.gmatch( page, '<section.->.-</section>' ) do
	print_section( section )
end

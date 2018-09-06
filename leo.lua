module( "leo", package.seeall )

local https = require "ssl.https"

function get_document( url )
	local tab = {}
	local response, code, headers, status = https.request( url )
	if code ~= 200 then
		print( "Error: ", status )
	end
	return response
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

function get_h2_text( table )
	local match = table:match "<h2.->(.-)</h2>"
	if match:find "Mögliche Grundformen" then --ignore basic forms
		return nil
	else
		return match
	end
end

function get_words( tab ) 
	local result = {}
	for expr in tab:gmatch "<samp>(.-)</samp>" do
		local without_tags = expr:gsub( "<[^>]->", "" ):gsub( "|.*", "" )
		table.insert( result, without_tags )
	end
	return result
end

local url = 'https://dict.leo.org/%s-deutsch/%s'
local language = arg[ 2 ] or "englisch"
local term = arg[ 1 ] --term to look up

local short_language_names = {
	de = "deutsch",
	en = "englisch",
	fr = "französisch",
	es = "spanisch",
	it = "italienisch",
	ch = "chinesisch",
	ru = "russisch",
	pt = "portugiesisch",
	pl = "polnisch"
}

if not term then
	print "Please supply a term for translation"
	return -1
end

if short_language_names[ language ] then
	language = short_language_names[ language ] -- replace with longer name
end

local page = get_document( string.format( url, language, term ) )

for table in string.gmatch( page, '<h2 class="ta%-c.-</tbody>' ) do
	local header = get_h2_text( table )
	if header then
		print( invert( header ) )
		local words = get_words( table )
		local left_word = nil
		for i, word in ipairs( words ) do
			if i % 2 == 1 then
				left_word = word
			else
				print( left_word, word )
			end
		end
	end
end

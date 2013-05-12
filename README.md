leo-dict-command-line
=====================

A simple command line client for www.leo.org

Usage:

	lua leo.lua searchterm

This will look up *searchterm* as an English or German word and will print
related translations.

If you want to select a different language than English for translation to/from
German, you can provide a second command line argument:

	lua leo.lua searchterm fr

Now *searchterm* will be regarded as a french word or it will be attempted to
translate *searchterm* to French.

The output format may still change in the future.


Dependencies
------------

This Lua module depends on
[LuaSocket](http://www.cs.princeton.edu/~diego/professional/luasocket/)

Installation
------------

It's just one Lua file that you can download and place at a convenient location.
You can write a small shell script that executes the file.

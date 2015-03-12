--[[
	The MIT License (MIT)

	Copyright (c) 2015 Socialz (+ soc-i-alz GitHub organization)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local listeners = { }

function add( name, target )
	remove( name, target )

	listeners[ name ] = { target: target }

	addEvent( name, true )
	addEventHandler( name, target, function( ) end )

	return true
end

function remove( name, target )
	if ( listeners[ name ] ) and ( listeners[ name ].target == target ) then
		removeEventHandler( name, target )
		listeners[ name ] = nil

		return true
	end

	return false
end

function trigger( name, target, ... )
	triggerEvent( name, target, ... )
end

addEvent( "listeners:add", true )
addEventHandler( "listeners:add", root,
	function( name, target )
		add( name, target )
	end
)

addEvent( "listeners:remove", true )
addEventHandler( "listeners:remove", root,
	function( name, target )
		remove( name, target )
	end
)
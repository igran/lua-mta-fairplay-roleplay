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

local threadQueue = { }
local thread = { }

function cancel( threadName )
	for index, data in pairs( threadQueue ) do
		if ( data.name == threadName ) then
			return true
		end
	end

	return false
end

function create( threadName, threadFunction, yieldsCount )
	table.insert( threadQueue, { name = threadName, func = threadFunction, yieldsCount = yieldsCount } )

	if ( not thread ) then
		next( )
	end
end

function next( )
	stop( )

	if ( exports.common:count( threadQueue ) > 0 ) then
		for i, data in pairs( threadQueue ) do
			thread = data
			break
		end

		thread.coroutine = coroutine.create( thread.func )
		thread.lastTickCount = getTickCount( )

		coroutine.resume( thread.coroutine )

		thread.timer = setTimer( function( )
			if ( coroutine.status( thread.coroutine ) == "suspended" ) then
				for i = 1, thread.yieldsCount, 1 do
					thread.yieldsDone = not thread.yieldsDone and 1 or thread.yieldsDone + 1
					coroutine.resume( thread.coroutine )
				end
			elseif ( coroutine.status( thread.coroutine ) == "dead" ) then
				stop( )
				next( )
			end
		end, thread.speed or 50, thread.yieldsCount )

		return thread
	end

	return false
end

function stop( )
	if ( thread ) then
		if ( isTimer( thread.timer ) ) then
			killTimer( thread.timer )
		end

		thread = nil
	end
end
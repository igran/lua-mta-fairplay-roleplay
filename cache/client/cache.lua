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

local cache = { }

local function getCacheNames( )
	local cacheNames = { }
	
	for cacheName in pairs( cache ) do
		table.insert( cacheNames, cacheName )
	end
	
	return cacheNames
end

function retrieve( caches, filters )
	local retrievedCaches = { }
	local caches = not caches and getCacheNames( ) or ( type( caches ) == "table" and caches or { caches } )
	
	for _, cacheName in ipairs( caches ) do
		local thisCache = cache[ cacheName ]
		
		if ( thisCache ) then
			if ( filters ) then
				local failed
				
				for _, data in ipairs( thisCache ) do
					for key, value in pairs( data ) do
						for filterKey, filterValue in pairs( filters ) do
							if ( key == filterKey ) and ( value ~= filterValue ) then
								failed = true
								
								break
							end
						end
					end
				end
				
				if ( not failed ) then
					retrievedCaches[ cacheName ] = thisCache
				end
			else
				retrievedCaches[ cacheName ] = thisCache
			end
		end
	end
	
	return retrievedCaches
end

addEvent( "cache:push", true )
addEventHandler( "cache:push", root,
	function( caches )
		for cacheName, cacheData in pairs( caches ) do
			cache[ cacheName ] = cacheData
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "cache:retrieve", localPlayer )
	end
)
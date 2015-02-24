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

local ignoreCachedData = {
	accounts = {
		"password", "salt"
	}
}

local cache = {
	accounts = { },
	characters = { },
	languages = { }
}

local function getCacheNames( )
	local cacheNames = { }
	
	for cacheName in pairs( cache ) do
		table.insert( cacheNames, cacheName )
	end
	
	return cacheNames
end

function retrieve( caches, filters )
	local retrievedCaches = { }
	local isSingleCache = type( caches ) == "string"
	local caches = not caches and getCacheNames( ) or ( type( caches ) == "table" and caches or { caches } )
	
	for _, cacheName in ipairs( caches ) do
		local thisCache = cache[ cacheName ]
		
		if ( thisCache ) then
			if ( filters ) then
				local failed
				
				for _, data in ipairs( thisCache ) do
					for key, value in pairs( data ) do
						for filterKey, filterValue in pairs( isSingleCache and filters or filters[ cacheName ] ) do
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

function flush( caches )
	local retrievedCaches = { }
	local caches = not caches and getCacheNames( ) or ( type( caches ) == "table" and caches or { caches } )
	
	for _, cacheName in ipairs( caches ) do
		local thisCache = cache[ cacheName ]
		
		if ( thisCache ) then
			local result = exports.database:query( "SELECT * FROM `??`", cacheName )
			
			if ( result ) then
				if ( ignoreCachedData[ cacheName ] ) then
					for i, data in ipairs( result ) do
						for key, value in ipairs( data ) do
							if ( ignoreCachedData[ cacheName ][ key ] ) then
								result[ i ][ key ] = nil
								
								break
							end
						end
					end
				end
				
				cache[ cacheName ] = result
				
				outputDebugString( "Cache flush for " .. cacheName .. " successful! Replaced old cache with new cache." )
			else
				outputDebugString( "Cache flush for " .. cacheName .. " failed! Falling back to last good cache.", 1 )
			end
		end
	end
	
	return true
end

function add( cacheName, data )
	if ( cache[ cacheName ] ) then
		for key, value in ipairs( data ) do
			if ( ignoreCachedData[ cacheName ][ key ] ) then
				data[ key ] = nil
				
				break
			end
		end
		
		table.insert( cache[ cacheName ], data )
		
		for _, player in ipairs( getElementsByType( "player" ) ) do
			triggerClientEvent( player, "cache:push", player, retrieve( cacheName ) )
		end
		
		return true
	end
	
	return false
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		for cacheName in pairs( cache ) do
			flush( cacheName )
		end
	end
)

addEvent( "cache:retrieve", true )
addEventHandler( "cache:retrieve", root,
	function( cacheName )
		if ( source ~= client ) then
			return
		end
		
		triggerClientEvent( client, "cache:push", client, retrieve( cacheName ) )
	end
)

addEvent( "cache:request:flush", true )
addEventHandler( "cache:request:flush", root,
	function( cacheName )
		if ( source ~= client ) then
			return
		end
		
		local result = "\"OK\" at 200"
		
		if ( not exports.admin:isServerOverloaded( ) ) then
			flush( cacheName )
		else
			result = "\"Service Unavailable\" at 503"
		end
		
		outputDebugString( getPlayerName( client ) .. " [" .. getPlayerIP( client ) .. "] requested for cache flush [" .. result .. "]." )
	end
)
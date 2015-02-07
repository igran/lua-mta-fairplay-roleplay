--[[
	The MIT License (MIT)

	Copyright (c) 2014 Socialz (+ soc-i-alz GitHub organization)

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

local interiors = { }
local threads = { }

local loadingInteriorsGlobalID
local interiorsToLoadCount = 0

_get = get
function get( id )
	return interiors[ id ] or false
end

function create( startX, startY, startZ, startInterior, startDimension, targetX, targetY, targetZ, targetInterior, name, type, price, ownerID, createdBy )
	local id = exports.database:insert_id( "INSERT INTO `interiors` (`pos_x`, `pos_y`, `pos_z`, `interior`, `dimension`, `target_pos_x`, `target_pos_y`, `target_pos_z`, `target_interior`, `name`, `type`, `price`, `owner_id`, `created_by`, `created`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", startX or 0, startY or 0, startZ or 0, startInterior or 0, startDimension or 0, targetX or 0, targetY or 0, targetZ or 0, targetInterior or 0, name or "", type or 1, price or 0, ownerID or 0, createdBy or 0 )

	if ( id ) then
		load( id, true )
		
		return id
	end
end

function delete( id )
	if ( get( id ) ) then
		if ( unload( id ) ) then
			if ( exports.database:execute( "UPDATE `interiors` SET `is_deleted` = '1' WHERE `id` = ?", id ) ) then
				interiors[ id ] = nil
				
				return true
			else
				load( id )
			end
		end
	end

	return false
end

function load( data, loadFromDatabase, ignoreSync )
	local data = type( data ) == "table" and data or ( loadFromDatabase and exports.database:query_single( "SELECT * FROM `interiors` WHERE `id` = ? LIMIT 1", data ) or get( data ) )

	if ( data ) then
		interiors[ data.id ] = data
		interiors[ data.id ].loaded = true
		
		if ( interiors[ data.id ].type ~= 3 ) then
			if ( not interiors[ data.id ].owner or interiors[ data.id ].owner == 0 ) then
				interiors[ data.id ].owner_name = "None"
			elseif ( interiors[ data.id ].owner > 0 ) then
				local character = exports.accounts:getCharacter( interiors[ data.id ].owner )
				
				if ( character ) then
					interiors[ data.id ].owner_name = character.name
				else
					interiors[ data.id ].owner_name = "Unknown person"
				end
			elseif ( interiors[ data.id ].owner < 0 ) then
				local faction = exports.factions:get( interiors[ data.id ].owner )
				
				if ( faction ) then
					interiors[ data.id ].owner_name = faction.name
				else
					interiors[ data.id ].owner_name = "Unknown faction"
				end
			else
				interiors[ data.id ].owner_name = "Unknown"
			end
		else
			interiors[ data.id ].owner_name = "Government"
		end
		
		if ( not ignoreSync ) then
			for _, player in ipairs( getElementsByType( "player" ) ) do
				triggerClientEvent( player, "interiors:load", player, { interiors[ data.id ] } )
			end
		end
		
		return true
	end

	return false
end

function unload( id, ignoreSync )
	local interior = get( id )

	if ( interior ) then
		interior.loaded = false
		
		if ( not ignoreSync ) then
			for _, player in ipairs( getElementsByType( "player" ) ) do
				triggerClientEvent( player, "interiors:unload", player, { id } )
			end
		end

		return true
	end

	return false
end

function loadAll( )
	loadingInteriorsGlobalID = exports.messages:createGlobalMessage( "Loading interiors. Please wait.", "interiors-loading", true, false )
	
	for _, interior in pairs( interiors ) do
		unload( interior.id )
	end
	
	local query = exports.database:query( "SELECT * FROM `interiors` WHERE `is_deleted` = '0' ORDER BY `id`" )
	
	if ( query ) then
		interiorsToLoadCount = #query
		
		for _, interior in ipairs( query ) do
			local loadCoroutine = coroutine.create( load )
			coroutine.resume( loadCoroutine, interior, false, true )
			table.insert( threads, loadCoroutine )
		end
		
		setTimer( resumeCoroutines, 1000, 4 )
	end
end
addEventHandler( "onResourceStart", resourceRoot, loadAll )

function resumeCoroutines( )
	for _, loadCoroutine in ipairs( threads ) do
		coroutine.resume( loadCoroutine )
	end
	
	if ( exports.common:count( interiors ) >= interiorsToLoadCount ) then
		exports.messages:destroyGlobalMessage( loadingInteriorsGlobalID )
		
		for _, player in ipairs( getElementsByType( "player" ) ) do
			triggerClientEvent( player, "interiors:load", player, interiors )
		end
	end
end
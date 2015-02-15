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

cctvs = { }
local threads = { }

local loadingTimer, loadingCount = nil, 0

_get = get
function get( id )
	return cctvs[ id ] or false
end

function create( x, y, z, interior, dimension, rotX, rotY, rotZ, name, modelID, createdBy )
	local id = exports.database:insert_id( "INSERT INTO `cctv_cameras` (`pos_x`, `pos_y`, `pos_z`, `interior`, `dimension`, `rot_x`, `rot_y`, `rot_z`, `name`, `model_id`, `created_by`, `created`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)", x or 0, y or 0, z or 0, interior or 0, dimension or 0, rotX or 0, rotY or 0, rotZ or 0, name or "", modelID or 2921, createdBy or 0 )

	if ( id ) then
		return id, load( id, true )
	end
end

function delete( id )
	if ( get( id ) ) then
		if ( unload( id, true ) ) then
			if ( exports.database:execute( "DELETE FROM `cctv_cameras` WHERE `id` = ?", id ) ) then
				cctvs[ id ] = nil
				
				synchronizeCCTVs( )
				
				return true
			else
				load( id )
			end
		end
	end

	return false
end

function load( data, loadFromDatabase, ignoreSync, hasCoroutine )
	local data = type( data ) == "table" and data or ( loadFromDatabase and exports.database:query_single( "SELECT * FROM `cctv_cameras` WHERE `id` = ? LIMIT 1", data ) or get( data ) )
	
	if ( hasCoroutine ) then
		coroutine.yield( )
	end

	if ( data ) then
		unload( data.id )
		
		local object = createObject( data.model_id, data.pos_x, data.pos_y, data.pos_z, data.rot_x, data.rot_y, data.rot_z )

		if ( isElement( object ) ) then
			setElementInterior( object, data.interior )
			setElementDimension( object, data.dimension )
			setElementCollisionsEnabled( object, false )

			exports.security:modifyElementData( object, "cctv:id", data.id, true )

			cctvs[ data.id ] = data
			cctvs[ data.id ].object = object
			cctvs[ data.id ].is_disabled = data.is_disabled == 1
			cctvs[ data.id ].location = getElementZoneName( object ) .. ", " .. getElementZoneName( object, true )
			
			if ( not ignoreSync ) then
				synchronizeCCTVs( )
			end

			return object
		end
		
		return true
	end

	return false
end

function unload( id, ignoreSync )
	local cctv = get( id )

	if ( cctv ) then
		if ( isElement( cctv.object ) ) then
			destroyElement( cctv.object )
		end
		
		cctv.loaded = false
		
		if ( not ignoreSync ) then
			synchronizeCCTVs( )
		end
		
		return true
	end

	return false
end

function save( id, x, y, z, interior, dimension, rotX, rotY, rotZ, name, modelID )
	local cctv = get( id )
	
	if ( cctv ) then
		if ( exports.database:execute( "UPDATE `cctv_cameras` SET `pos_x` = ?, `pos_y` = ?, `pos_z` = ?, `interior` = ?, `dimension` = ?, `rot_x` = ?, `rot_y` = ?, `rot_z` = ?, `name` = ?, `model_id` = ? WHERE `id` = ?", x, y, z, interior, dimension, rotX, rotY, rotZ, name, modelID, id ) ) then
			cctv.pos_x, cctv.pos_y, cctv.pos_z = x, y, z
			cctv.interior, cctv.dimension = interior, dimension
			cctv.rot_x, cctv.rot_y, cctv.rots_z = rotX, rotY, rotZ
			cctv.name, cctv.model_id = name, modelID
			
			return load( cctv )
		end
	end
	
	return false
end

function loadAll( )
	for _, cctv in pairs( cctvs ) do
		unload( cctv.id )
	end
	
	local query = exports.database:query( "SELECT * FROM `cctv_cameras` ORDER BY `id`" )
	
	if ( query ) then
		loadingCount = #query
		
		for _, cctv in ipairs( query ) do
			local loadCoroutine = coroutine.create( load )
			coroutine.resume( loadCoroutine, cctv, false, true, true )
			table.insert( threads, loadCoroutine )
		end
		
		loadingTimer = setTimer( resumeCoroutines, 1000, 4 )
	end
end
addEventHandler( "onResourceStart", resourceRoot, loadAll )

function resumeCoroutines( )
	for _, loadCoroutine in ipairs( threads ) do
		coroutine.resume( loadCoroutine )
	end
	
	if ( exports.common:count( cctvs ) >= loadingCount ) then
		loadingCount = nil
		
		if ( isTimer( loadingTimer ) ) then
			killTimer( loadingTimer )
		end
		
		synchronizeCCTVs( )
	end
end

function synchronizeCCTVs( player )
	for _, player in ipairs( type( player ) == "table" and player or exports.common:getPriorityPlayers( ) ) do
		if ( isElement( player ) ) then
			triggerClientEvent( player, "cctv:sync", player, cctvs )
		end
	end
end

addEvent( "cctv:ready", true )
addEventHandler( "cctv:ready", root,
	function( )
		if ( source ~= client ) or ( not exports.common:isPlayerServerAdmin( client ) ) then
			return
		end
		
		if ( not loadingCount ) then
			synchronizeCCTVs( { client } )
		end
	end
)

addEvent( "cctv:edit", true )
addEventHandler( "cctv:edit", root,
	function( id, data )
		if ( source ~= client ) or ( not exports.common:isPlayerServerAdmin( client ) ) then
			return
		end
		
		if ( type( data ) == "table" ) then
			for name, value in pairs( data ) do
				if ( name ~= "name" ) then
					if ( not tonumber( value ) ) then
						outputChatBox( "Some fields have invalid values. Please check your inputs.", client, 230, 95, 95 )
						return
					end
				end
			end
		end
		
		local result = false
		
		if ( data == false ) then
			result = delete( id )
		else
			if ( not get( id ) ) then
				result = create( data.x, data.y, data.z, data.interior, data.dimension, data.rx, data.ry, data.rz, data.name, data.model, exports.common:getCharacterID( client ) )
			else
				result = save( id, data.x, data.y, data.z, data.interior, data.dimension, data.rx, data.ry, data.rz, data.name, data.model )
			end
		end
		
		if ( result ) then
			triggerClientEvent( client, "cctv:success", client )
		else
			outputChatBox( "Something went wrong when saving CCTV data. Please retry.", client, 230, 95, 95 )
		end
	end
)
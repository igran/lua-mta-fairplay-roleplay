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

local vehicles = { }
local threads = { }

--local loadingVehiclesGlobalID
local loadingTimer
local vehiclesToLoadCount = 0

_get = get
function get( id )
	return exports.database:query_single( "SELECT * FROM `vehicles` WHERE `id` = ? AND `is_deleted` = '0'", id )
end

function getVehicle( id )
	local data = getVehicleData( id )

	if ( data ) and ( isElement( data.vehicle ) ) then
		return data.vehicle
	end

	return false
end

function getVehicleData( id )
	return vehicles[ id ] or false
end

function create( modelID, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, variantA, variantB, ownerID, faction, color, isLocked, isBulletproof, modelSetID )
	rotX, rotY, rotZ = rotX or 0, rotY or 0, rotZ or 0
	interior, dimension = interior or 0, dimension or 0
	variantA, variantB = variantA or 255, variantB or 255
	ownerID = ownerID and ( faction and -ownerID or ownerID ) or 0
	color = color or "[ [ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ] ]"
	isLocked = isLocked or true
	engineOn = engineOn or false
	isBulletproof = isBulletproof or false
	modelSetID = modelSetID or 0
	
	local numberplate = makeNumberPlate( )
	local vehicleID = exports.database:insert_id( "INSERT INTO `vehicles` (`model_id`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `interior`, `dimension`, `respawn_pos_x`, `respawn_pos_y`, `respawn_pos_z`, `respawn_rot_x`, `respawn_rot_y`, `respawn_rot_z`, `respawn_interior`, `respawn_dimension`, `numberplate`, `variant_1`, `variant_2`, `owner_id`, `color`, `is_locked`, `is_bulletproof`, `model_set_id`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", modelID, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, numberplate, variantA, variantB, ownerID, color, isLocked, isBulletproof, modelSetID )
	
	if ( vehicleID ) and ( not faction ) then
		exports.items:give( exports.common:getPlayerByCharacterID( ownerID ) or ownerID, 7, vehicleID, nil, nil, nil, true )
	end
	
	return vehicleID, load( vehicleID, true )
end

function load( vehicleID, respawnVehicle, hasCoroutine )
	local data = type( vehicleID ) == "table" and vehicleID or get( vehicleID )
	
	if ( hasCoroutine ) then
		coroutine.yield( )
	end
	
	if ( data ) then
		local vehicle = getVehicle( vehicleID )
		
		if ( isElement( vehicle ) ) then
			destroyElement( vehicle )
		end

		vehicles[ data.id ] = data
		vehicles[ data.id ].panel_states = fromJSON( vehicles[ data.id ].panel_states )
		vehicles[ data.id ].door_states = fromJSON( vehicles[ data.id ].door_states )
		
		local posX, posY, posZ = data[ ( respawnVehicle and "respawn_" or "" ) .. "pos_x" ], data[ ( respawnVehicle and "respawn_" or "" ) .. "pos_y" ], data[ ( respawnVehicle and "respawn_" or "" ) .. "pos_z" ]
		local rotX, rotY, rotZ = data[ ( respawnVehicle and "respawn_" or "" ) .. "rot_x" ], data[ ( respawnVehicle and "respawn_" or "" ) .. "rot_y" ], data[ ( respawnVehicle and "respawn_" or "" ) .. "rot_z" ]
		vehicles[ data.id ].vehicle = createVehicle( data.model_id, posX, posY, posZ, rotX, rotY, rotZ, data.numberplate, false, data.variant_1, data.variant_2 )

		local vehicle = vehicles[ data.id ].vehicle

		if ( vehicle ) then
			setElementInterior( vehicle, data.respawn_interior )
			setElementDimension( vehicle, data.respawn_dimension )
			setElementHealth( vehicle, data.health )
			
			setVehicleLocked( vehicle, data.is_locked == 1 )
			setVehicleDoorsUndamageable( vehicle, data.is_bulletproof == 1 )
			setVehicleDamageProof( vehicle, data.is_bulletproof == 1 )
			setVehicleOverrideLights( vehicle, data.headlight_state == 1 and 2 or 1 )
			setVehicleEngineState( vehicle, data.is_engine_on == 1 )
			setVehicleRespawnPosition( vehicle, data.respawn_pos_x, data.respawn_pos_y, data.respawn_pos_z, data.respawn_rot_x, data.respawn_rot_y, data.respawn_rot_z )
			toggleVehicleRespawn( vehicle, false )
			
			exports.security:modifyElementData( vehicle, "vehicle:id", data.id, true )
			exports.security:modifyElementData( vehicle, "vehicle:model_set_id", data.model_set_id, true )
			exports.security:modifyElementData( vehicle, "vehicle:engine", data.is_engine_on == 1, true )
			exports.security:modifyElementData( vehicle, "vehicle:broken", data.is_broken == 1, true )
			exports.security:modifyElementData( vehicle, "vehicle:owner", data.owner_id, true )
			
			local colors = fromJSON( data.color )
			
			setVehicleColor( vehicle,
				colors[ 1 ][ 1 ], colors[ 1 ][ 2 ], colors[ 1 ][ 3 ],
				colors[ 2 ][ 1 ], colors[ 2 ][ 2 ], colors[ 2 ][ 3 ],
				colors[ 3 ][ 1 ], colors[ 3 ][ 2 ], colors[ 3 ][ 3 ],
				colors[ 4 ][ 1 ], colors[ 4 ][ 2 ], colors[ 4 ][ 3 ] )
			
			local panels = data.panel_states
			
			for panelID, panelState in pairs( panels ) do
				setVehiclePanelState( vehicle, panelID, panelState )
			end
			
			local doors = data.door_states
			
			for doorID, doorState in pairs( doors ) do
				setVehicleDoorState( vehicle, doorID, doorState )
			end
			
			return vehicle
		end
	end
	
	return false
end

function delete( vehicle )
	local vehicleID = exports.common:getRealVehicleID( vehicle )
	
	if ( unload( vehicle ) ) then
		if ( exports.database:execute( "UPDATE `vehicles` SET `is_deleted` = '1' WHERE `id` = ?", vehicleID ) ) then
			vehicles[ vehicleID ] = nil
			
			return true
		else
			load( getVehicleData( vehicleID ) )
		end
	end

	return false
end

function unload( vehicle )
	if ( save( vehicle ) ) then
		local vehicleID = exports.common:getRealVehicleID( vehicle )

		if ( vehicleID ) then
			vehicles[ vehicleID ].vehicle = nil
		end

		destroyElement( vehicle )
		
		return true
	end
	
	return false
end

function reload( vehicle )
	local vehicleID = exports.common:getRealVehicleID( vehicle )
	
	unload( vehicle )
	load( getVehicleData( vehicleID ) )
end

function save( vehicle )
	local vehicleID = exports.common:getRealVehicleID( vehicle )
	
	if ( vehicleID ) then
		local vehicleData = getVehicleData( vehicleID ) or { }
		local posX, posY, posZ = getElementPosition( vehicle )
		local rotX, rotY, rotZ = getElementRotation( vehicle )
		local interior, dimension = getElementInterior( vehicle ), getElementDimension( vehicle )
		
		local panels = { }
		
		for i = 0, 6 do
			panels[ i ] = getVehiclePanelState( vehicle, i )
		end
		
		local doors = { }
		
		for i = 0, 5 do
			doors[ i ] = getVehicleDoorState( vehicle, i )
		end
		
		return exports.database:execute( "UPDATE `vehicles` SET `pos_x` = ?, `pos_y` = ?, `pos_z` = ?, `rot_x` = ?, `rot_y` = ?, `rot_z` = ?, `interior` = ?, `dimension` = ?, `panel_states` = ?, `door_states` = ?, `is_locked` = ?, `is_engine_on` = ?, `is_broken` = ?, `headlight_state` = ?, `model_set_id` = ? WHERE `id` = ?", posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, toJSON( panels ), toJSON( doors ), isVehicleLocked( vehicle ), getVehicleEngineState( vehicle ), exports.common:isVehicleBroken( vehicle ), getVehicleOverrideLights( vehicle ) == 2, vehicleData.model_set_id or 0, vehicleID )
	end
end

function saveAll( )
	for _, vehicle in ipairs( getElementsByType( "vehicle" ) ) do
		if ( exports.common:getRealVehicleID( vehicle ) ) then
			save( vehicle )
		end
	end
end

function loadAll( )
	--loadingVehiclesGlobalID = exports.messages:createGlobalMessage( "Loading vehicles. Please wait.", "vehicles-loading", true, false )
	
	for _, vehicle in ipairs( getElementsByType( "vehicle" ) ) do
		if ( exports.common:getRealVehicleID( vehicle ) ) then
			destroyElement( vehicle )
		end
	end
	
	local query = exports.database:query( "SELECT * FROM `vehicles` WHERE `is_deleted` = '0' ORDER BY `id`" )
	
	if ( query ) then
		vehiclesToLoadCount = #query
		
		for _, vehicle in ipairs( query ) do
			local loadCoroutine = coroutine.create( load )
			coroutine.resume( loadCoroutine, vehicle, false, true )
			table.insert( threads, loadCoroutine )
		end
		
		loadingTimer = setTimer( resumeCoroutines, 1000, 4 )
	end
end

function resumeCoroutines( )
	for _, loadCoroutine in ipairs( threads ) do
		coroutine.resume( loadCoroutine )
	end
	
	if ( vehiclesToLoadCount ) and ( exports.common:count( vehicles ) >= vehiclesToLoadCount ) then
		--exports.messages:destroyGlobalMessage( loadingVehiclesGlobalID )
		vehiclesToLoadCount = nil
		
		if ( isTimer( loadingTimer ) ) then
			killTimer( loadingTimer )
		end
	end
end

function makeNumberPlate( )
	local numberplate

	local function generate( )
		math.randomseed( getTickCount( ) )

		numberplate = exports.common:getRandomString( 2 ) .. math.random( 0, 9 ) .. "-"
		numberplate = numberplate .. exports.common:getRandomString( 1 ) .. math.random( 0, 9 ) .. exports.common:getRandomString( 1 ) .. math.random( 0, 9 )
	end

	while ( not numberplate ) or ( isNumberPlateInUse( numberplate ) ) do
		generate( )
	end

	return numberplate
end

function isNumberPlateInUse( numberplate )
	local query = exports.database:query_single( "SELECT `id` FROM `vehicles` WHERE `numberplate` = ? LIMIT 1", numberplate )
	
	return query and query.id or false
end

function toggleEngine( player )
	local player = player or source
	local vehicle = ( getPedOccupiedVehicle( player ) and getPedOccupiedVehicleSeat( player ) == 0 ) and getPedOccupiedVehicle( player ) or nil
	
	if ( isElement( player ) ) and ( exports.common:isPlayerPlaying( player ) ) and ( vehicle ) then
		if ( getVehicleEngineState( vehicle ) ) then
			setVehicleEngineState( vehicle, false )
		else
			if ( ( exports.items:has( player, 7, exports.common:getRealVehicleID( vehicle ) ) ) or ( exports.common:isOnDuty( player ) ) ) then
				setVehicleEngineState( vehicle, true )
			else
				outputChatBox( "You require a key to turn on the engine of this vehicle.", player, 230, 95, 95 )
				return
			end
		end
		
		exports.security:modifyElementData( vehicle, "vehicle:engine", getVehicleEngineState( vehicle ), true )
	end
end

function toggleLock( player )
	local player = player or source
	
	if ( isElement( player ) ) and ( exports.common:isPlayerPlaying( player ) ) then
		local x, y, z = getElementPosition( player )
		local vehicle = ( getPedOccupiedVehicle( player ) and getPedOccupiedVehicleSeat( player ) < 2 ) and getPedOccupiedVehicle( player ) or nil
		
		if ( not vehicle ) then
			local foundVehicle, foundDistance = nil, 15
			
			for _, nearbyVehicle in ipairs( getElementsByType( "vehicle", getResourceDynamicElementRoot( resource ) ) ) do
				local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( nearbyVehicle ) )
				
				if ( distance < foundDistance ) and ( ( exports.items:has( player, 7, exports.common:getRealVehicleID( nearbyVehicle ) ) ) or ( exports.common:isOnDuty( player ) ) ) then
					foundVehicle = nearbyVehicle
					foundDistance = distance
				end
			end
			
			if ( not foundVehicle ) then
				return
			end
			
			vehicle = foundVehicle
		end
		
		if ( vehicle ) then
			setVehicleLocked( vehicle, not isVehicleLocked( vehicle ) )
			exports.chat:outputLocalActionMe( player, ( isVehicleLocked( vehicle ) and "" or "un" ) .. "locks the " .. exports.common:getVehicleName( vehicle ) .. "." )
		else
			outputChatBox( "You require a key to toggle the locks of this vehicle.", player, 230, 95, 95 )
		end
	end
end

function toggleLights( player )
	local player = player or source
	local vehicle = ( getPedOccupiedVehicle( player ) and getPedOccupiedVehicleSeat( player ) == 0 ) and getPedOccupiedVehicle( player ) or nil
	
	if ( isElement( player ) ) and ( exports.common:isPlayerPlaying( player ) ) and ( vehicle ) then
		setVehicleOverrideLights( vehicle, getVehicleOverrideLights( vehicle ) == 2 and 1 or 2 )
	end
end

function bindKeys( player, state )
	local player = player or source
	local fn = state and bindKey or unbindKey

	fn( player, "J", "down", toggleEngine )
	fn( player, "K", "down", toggleLock )
	fn( player, "L", "down", toggleLights )
end

addEventHandler( "onPlayerJoin", root,
	function( )
		bindKeys( source )
	end
)

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		loadAll( )
		
		for _, player in ipairs( getElementsByType( "player" ) ) do
			bindKeys( player )
		end
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		saveAll( )
	end
)

addEventHandler( "onVehicleEnter", root,
	function( player )
		local vehicleID = exports.common:getRealVehicleID( source )

		if ( vehicleID ) then
			setVehicleEngineState( source, exports.common:getRealVehicleEngineState( source ) )

			if ( exports.common:isPlayerServerTrialAdmin( player ) ) then
				local isFactionVehicle = exports.common:isFactionVehicle( source )
				local ownerID = exports.common:getVehicleOwner( source )
				local owner = isFactionVehicle and exports.factions:get( ownerID ) or exports.accounts:getCharacter( ownerID )

				if ( owner ) and ( owner.name ) then
					outputChatBox( "(( This " .. exports.common:getVehicleName( vehicle ) .. " belongs to " .. owner.name .. ". ))", player, 230, 180, 95 )
				end
			end
		end
	end
)

addEventHandler( "onVehicleExit", root,
	function( )
		if ( exports.common:getRealVehicleID( source ) ) then
			save( source )
		end
	end
)

addEventHandler( "onVehicleStartExit", root,
	function( player )
		if ( exports.common:getRealVehicleID( source ) ) and ( isVehicleLocked( source ) ) then
			cancelEvent( )
			outputChatBox( "The door is locked.", player, 230, 95, 95 )
		end
	end
)
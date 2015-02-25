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

local factions = { }
local threads = { }

--local loadingFactionsGlobalID
local loadingTimer
local factionsToLoadCount = 0

function getFactions( )
	return factions
end

_get = get
function get( id )
	for index, faction in pairs( getFactions( ) ) do
		if ( faction.id == id ) then
			return faction, index
		end
	end
	
	return false
end

function getByName( name )
	for index, faction in pairs( getFactions( ) ) do
		if ( faction.name == name ) then
			return faction, index
		end
	end
	
	return false
end

function create( name, type )
	local type = type or 1
	local ranks = { }

	for i = 1, factionRankCount do
		table.insert( ranks, {
			name = "Rank #" .. i,
			wage = 0
		} )
	end

	local id = exports.database:insert_id( "INSERT INTO `factions` (`name`, `type`, `ranks`) VALUES (?, ?, ?)", name, type, toJSON( ranks ) )

	return id and load( id ) or false
end

function delete( id )
	local found, index = get( id )

	if ( found ) then
		if ( exports.database:execute( "UPDATE `factions` SET `is_deleted` = '1' WHERE `id` = ?", id ) ) then
			factions[ index ] = nil

			exports.database:execute( "DELETE FROM `factions_characters` WHERE `faction_id` = ?", id )

			return true
		end
	end

	return false
end

function addCharacter( characterID, id, rank, isLeader )
	rank = tonumber( rank ) or 1
	isLeader = type( isLeader ) == "boolean" and isLeader or false
	
	if ( not isCharacter( characterID, id ) ) and ( exports.database:execute( "INSERT INTO `factions_characters` (`character_id`, `faction_id`, `rank`, `is_leader`) VALUES (?, ?, ?, ?)", characterID, id, rank, isLeader ) ) then
		local faction = get( id )

		table.insert( faction.players, { id = characterID, rank = rank, leader = isLeader } )

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, { faction } )
			end
		end

		return true
	end

	return false
end

function addPlayer( player, id )
	return addCharacter( exports.common:getCharacterID( player ), id )
end

function removeCharacter( characterID, id )
	local index = isCharacter( characterID, id )

	if ( index ) and ( exports.database:execute( "DELETE FROM `factions_characters` WHERE `character_id` = ? AND `faction_id` = ?", characterID, id ) ) then
		local faction = get( id )

		table.remove( faction.players, index )

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, { faction } )
			end
		end

		return true
	end

	return false
end

function removePlayer( player, id )
	return removeCharacter( exports.common:getCharacterID( player ), id )
end

function isCharacter( characterID, id, checkForLeadership )
	local faction = get( id )

	if ( faction ) then
		for index, data in pairs( faction.players ) do
			if ( data.id == characterID ) and ( ( not checkForLeadership ) or ( data.leader ) ) then
				return index
			end
		end
	end

	return false
end

function isPlayer( player, id, checkForLeadership )
	return isCharacter( exports.common:getCharacterID( player ), id, checkForLeadership )
end

function getCharacterFactions( characterID )
	local query = exports.database:query( "SELECT `faction_id` FROM `factions_characters` WHERE `character_id` = ?", id )

	if ( query ) then
		local playerFactions = { }

		for _, data in ipairs( query ) do
			table.insert( playerFactions, data.faction_id )
		end

		return playerFactions
	end

	return { }
end

function getPlayerFactions( player )
	return getCharacterFactions( exports.common:getCharacterID( player ) )
end

function setCharacterRank( characterID, id, rank )
	rank = tonumber( rank ) or 1
	rank = math.max( 1, math.min( factionRankCount, rank ) )
	local index = isCharacter( characterID, id )

	if ( index ) and ( rank ) and ( exports.database:execute( "UPDATE `factions_characters` SET `rank` = ? WHERE `character_id` = ? AND `faction_id` = ?", rank, characterID, id ) ) then
		local faction = get( id )
		
		
		faction.players[ index ].rank = rank

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, { faction } )
			end
		end

		return true, rank
	end

	return false
end

function setPlayerRank( player, id, rank )
	return setCharacterRank( exports.common:getCharacterID( player ), id, rank )
end

function setCharacterLeader( characterID, id, isLeader )
	isLeader = type( isLeader ) == "boolean" and isLeader or false
	local index = isCharacter( characterID, id )

	if ( index ) and ( exports.database:execute( "UPDATE `factions_characters` SET `is_leader` = ? WHERE `character_id` = ? AND `faction_id` = ?", isLeader, characterID, id ) ) then
		local faction = get( id )
		
		faction.players[ index ].leader = isLeader

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, { faction } )
			end
		end

		return true
	end

	return false
end

function setPlayerLeader( player, id, isLeader )
	return setCharacterLeader( exports.common:getCharacterID( player ), id, isLeader )
end

function load( id, hasCoroutine )
	local _, index = get( id )

	if ( factions[ index ] ) then
		factions[ index ] = nil
	end

	local query = exports.database:query_single( "SELECT * FROM `factions` WHERE `id` = ? LIMIT 1", id )

	if ( query ) then
		local ranks = fromJSON( query.ranks )
		local faction = {
			id = query.id,
			name = query.name,
			type = query.type,
			motd = query.motd,
			note = query.note,
			leader_note = query.leader_note,
			ranks = ranks,
			players = { }
		}

		for i = 1, factionRankCount do
			if ( not faction.ranks[ i ] ) then
				faction.ranks[ i ] = {
					name = "Rank #" .. i,
					wage = 0
				}
			end
		end

		if ( exports.common:count( faction.ranks ) ~= exports.common:count( ranks ) ) then
			exports.database:execute( "UPDATE `factions` SET `ranks` = ? WHERE `id` = ?", toJSON( faction.ranks ) )
		end

		local players = exports.database:query( "SELECT `character_id` FROM `factions_characters` WHERE `faction_id` = ?", query.id )

		if ( players ) then
			for _, data in ipairs( players ) do
				local rank = tonumber( data.rank ) or 1

				if ( not faction.ranks[ rank ] ) then
					rank = math.min( factionRankCount, math.max( 1, rank ) )

					exports.database:execute( "UPDATE `faction_characters` SET `rank` = ? WHERE `character_id` = ?", rank, data.character_id )
				end

				table.insert( faction.players, { id = data.character_id, rank = data.rank, leader = data.is_leader == 1 } )

				local player = exports.common:getPlayerByCharacterID( data.character_id )

				if ( player ) then
					triggerClientEvent( player, "factions:update", player, { faction } )
				end
			end
		end

		table.insert( factions, faction )

		if ( hasCoroutine ) then
			coroutine.yield( )
		end

		return get( id )
	else
		if ( hasCoroutine ) then
			coroutine.yield( )
		end
	end

	return false
end

function loadAll( )
	--loadingVehiclesGlobalID = exports.messages:createGlobalMessage( "Loading factions. Please wait.", "factions-loading", true, false )

	local query = exports.database:query( "SELECT * FROM `factions` ORDER BY `id`" )

	if ( query ) then
		factionsToLoadCount = #query

		for _, data in ipairs( query ) do
			local loadCoroutine = coroutine.create( load )
			coroutine.resume( loadCoroutine, data.id, true )
			table.insert( threads, loadCoroutine )
		end
		
		loadingTimer = setTimer( resumeCoroutines, 1000, 4 )

		return true
	end

	return false
end

function resumeCoroutines( )
	for _, loadCoroutine in ipairs( threads ) do
		coroutine.resume( loadCoroutine )
	end
	
	if ( factionsToLoadCount ) and ( exports.common:count( factions ) >= factionsToLoadCount ) then
		--exports.messages:destroyGlobalMessage( loadingFactionsGlobalID )
		factionsToLoadCount = 0
		threads = { }

		if ( isTimer( loadingTimer ) ) then
			killTimer( loadingTimer )
		end
	end
end

function loadPlayer( player )
	local playerFactions = { }
	
	for _, factionID in ipairs( getPlayerFactions( player ) ) do
		local faction = get( factionID )
		
		if ( faction ) then
			table.insert( playerFactions, faction )
		end
	end
	
	triggerClientEvent( player, "factions:update", player, factions )
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setTimer( loadAll, 100, 1 )
	end
)

addEvent( "factions:set_as_main", true )
addEventHandler( "factions:set_as_main", root,
	function( factionID )
		if ( client ~= source ) then
			return
		end
		
		local faction = get( factionID )
		
		if ( faction ) and ( isInFaction( client, factionID ) ) then
			if ( exports.common:getPlayerDefaultFaction( client ) ~= factionID ) then
				if ( exports.database:execute( "UPDATE `characters` SET `default_faction` = ? WHERE `id` = ?", factionID, exports.common:getCharacterID( client ) ) ) then
					outputChatBox( "You set " .. faction.name .. " as your default faction.", client, 230, 180, 95 )
					exports.security:modifyElementData( client, "character:default_faction", factionID, true )
					triggerClientEvent( client, "factions:update", client, { faction } )
				end
			end
		end
	end
)
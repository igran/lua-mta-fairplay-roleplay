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

local defaultSpawnX, defaultSpawnY, defaultSpawnZ = 1731.03, -1912.05, 13.56
local defaultSpawnRotation = 90
local defaultSpawnInterior, defaultSpawnDimension = 0, 0
local defaultCash, defaultBank = 250, 3250

function getCharacter( id )
	return exports.database:query_single( "SELECT * FROM `characters` WHERE `id` = ?", id )
end

function getCharacterByName( name, null )
	return exports.database:query_single( "SELECT " .. ( null and "NULL" or "*" ) .. " FROM `characters` WHERE `name` = ?", name )
end

function verifyCharacterName( name )
	name = name:gsub( "%c%d\!\?\=\)\(\\\/\"\#\&\%\[\]\{\}\*\^\~\:\;\>\<", "" ):gsub( "_", " " )
	local nameParts = split( name, " " )
	
	if ( #nameParts >= 2 ) then
		for i, v in ipairs( nameParts ) do
			if ( v:len( ) > 1 ) then
				local firstLetter = v:sub( 1, 1 )
				
				if ( firstLetter < 'A' ) or ( firstLetter > 'Z' ) then
					return -3, i
				end
			else
				return -2, i
			end
		end
		
		if ( name:len( ) >= minimumNameLength ) then
			if ( name:len( ) <= maximumNameLength ) then
				return true
			else
				return -5
			end
		else
			return -4
		end
	else
		return -1
	end
end

addEvent( "characters:create", true )
addEventHandler( "characters:create", root,
	function( characterSkinModel, characterName, characterDateOfBirth, characterGender, characterSkinColor, characterOrigin, characterLook, characterLanguage )
		if ( source ~= client ) then
			return
		end
		
		if ( characterName ) and ( characterDateOfBirth ) and ( characterGender ) and ( characterSkinColor ) and ( characterOrigin ) and ( characterLook ) then
			local verified, namePart = verifyCharacterName( characterName )
			
			if ( verified == true ) then
				characterName = characterName:gsub( "%s", "_" )
				
				if ( not getCharacterByName( characterName ) ) then
					local characterID = exports.database:insert_id( "INSERT INTO `characters` (`account`, `skin_id`, `name`, `pos_x`, `pos_y`, `pos_z`, `rotation`, `interior`, `dimension`, `cash`, `bank`, `date_of_birth`, `gender`, `skin_color`, `origin`, `look`, `created`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)", exports.common:getAccountID( client ), characterSkinModel, characterName, defaultSpawnX, defaultSpawnY, defaultSpawnZ, defaultSpawnRotation, defaultSpawnInterior, defaultSpawnDimension, defaultCash, defaultBank, characterDateOfBirth, characterGender, characterSkinColor, characterOrigin, characterLook )
					
					if ( characterID ) then
						exports.database:execute( "INSERT INTO `languages` (`character_id`, `language_1`, `created`) VALUES (?, ?, CURRENT_TIMESTAMP)", characterID, characterLanguage or 1 )
						
						exports.messages:destroyMessage( client, "selection" )
						
						triggerClientEvent( client, "characters:closeGUI", client )
						
						spawnCharacter( client, characterID, true )
					else
						triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "selection" )
					end
				else
					triggerClientEvent( client, "messages:create", client, "A character with this name already exists. Please try another name.", "selection" )
				end
			else
				if ( verified == -1 ) then
					triggerClientEvent( client, "messages:create", client, "Please enter your first and lastname (e.g. John Doe).", "selection" )
				elseif ( verified == -2 ) then
					local part = namePart == 1 and "firstname" or "lastname"
					triggerClientEvent( client, "messages:create", client, "Please enter a longer " .. part .. ".", "selection" )
				elseif ( verified == -3 ) then
					local part = namePart == 1 and "firstname" or "lastname"
					triggerClientEvent( client, "messages:create", client, "Please enter your " .. part .. " with the starting letter in capital.", "selection" )
				elseif ( verified == -4 ) then
					triggerClientEvent( client, "messages:create", client, "Character name must be at least " .. minimumNameLength .. " characters long.", "selection" )
				elseif ( verified == -5 ) then
					triggerClientEvent( client, "messages:create", client, "Character name must be at most " .. maximumNameLength .. " characters long.", "selection" )
				end
			end
		else
			triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "selection" )
		end
	end
)

addEvent( "characters:selection", true )
addEventHandler( "characters:selection", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		characterSelection( client )
	end
)

addEvent( "characters:play", true )
addEventHandler( "characters:play", root,
	function( characterName )
		if ( source ~= client ) then
			return
		end
		
		exports.messages:destroyMessage( client, "selection" )
		
		local accountID = exports.common:getAccountID( client )
		
		if ( not accountID ) then
			triggerClientEvent( client, "accounts:showLogin", client )
		else
			characterName = characterName:gsub( " ", "_" )
			local character = exports.database:query_single( "SELECT * FROM `characters` WHERE `name` = ? AND `account` = ?", characterName, accountID )
			
			if ( character ) then
				if ( character.is_dead == 0 ) then
					triggerClientEvent( client, "characters:closeGUI", client, true )
					spawnCharacter( client, character, true )
				else
					outputChatBox( "That character is dead, you cannot play on it anymore.", client, 230, 95, 95 )
				end
			else
				exports.messages:createMessage( client, "Unable to retrieve information for this character. Please try again.", "selection" )
			end
		end
	end
)

function saveCharacter( player )
	if ( not isElement( player ) ) then
		return
	end
	
	if ( exports.common:isPlayerPlaying( player ) ) then
		local x, y, z = getElementPosition( player )
		local rotation = getPedRotation( player )
		local interior = getElementInterior( player )
		local dimension = getElementDimension( player )
		local skinModel = getElementModel( player )
		local characterID = exports.common:getCharacterID( player )
		
		return exports.database:execute( "UPDATE `characters` SET `pos_x` = ?, `pos_y` = ?, `pos_z` = ?, `rotation` = ?, `interior` = ?, `dimension` = ?, `skin_id` = ?, `health` = ?, `armor` = ?, `cash` = ?, `bank` = ?, `last_played` = CURRENT_TIMESTAMP WHERE `id` = ?", x, y, z, rotation, interior, dimension, skinModel, getElementHealth( player ), getPedArmor( player ), exports.bank:getPlayerMoney( player ), exports.bank:getPlayerBankMoney( player ), characterID )
	end
end

addCommandHandler( "saveme",
	function( player )
		if ( saveCharacter( player ) ) then
			outputChatBox( "Your character has been successfully saved.", player, 95, 230, 95 )
		end
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for _, player in ipairs( getElementsByType( "player" ) ) do
			saveCharacter( player )
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		saveCharacter( source )
	end
)

function characterSelection( player )
	if ( not isElement( player ) ) then
		return
	end
	
	saveCharacter( player )
	
	triggerEvent( "admin:ticket_left", player )
	
	removeElementData( player, "player:playing" )
	removeElementData( player, "player:waiting" )
	
	removeElementData( player, "character:id" )
	removeElementData( player, "character:name" )
	removeElementData( player, "character:gender" )
	removeElementData( player, "character:skin_color" )
	removeElementData( player, "character:origin" )
	removeElementData( player, "character:look" )
	removeElementData( player, "character:date_of_birth" )
	removeElementData( player, "character:default_faction" )
	removeElementData( player, "character:cash" )
	removeElementData( player, "character:bank" )
	
	removeElementData( player, "character:weight" )
	removeElementData( player, "character:max_weight" )
	
	for slot = 1, exports.chat:getMaxLanguages( ) do
		removeElementData( player, "character:language_" .. slot )
		removeElementData( player, "character:language_" .. slot .. "_skill" )
	end
	
	triggerClientEvent( player, "superman:stop", player )
	triggerClientEvent( player, "scoreboard:hideHUD", player )
	
	spawnPlayer( player, 0, 0, 0 )
	setElementDimension( player, 6000 )
	
	setCameraMatrix( player, 0, 0, 100, 100, 100, 100 )
	
	triggerClientEvent( player, "messages:destroy", player, "selection" )
	triggerClientEvent( player, "accounts:showCharacterSelection", player )
	
	updateCharacters( player )
	
	exports.messages:destroyMessage( player, "wait-for-admin" )
end

function spawnCharacter( player, character, fade )
	if ( not isElement( player ) ) then
		return
	end
	
	local character = type( character ) == "number" and getCharacter( character ) or ( type( character ) == "table" and character or nil )
	
	if ( character ) then
		if ( not exports.cache:retrieve( "characters", { id = character.id } ) ) then
			exports.cache:add( "characters", character )
		end
		
		function play( player, character )
			if ( isElement( player ) ) then
				exports.security:modifyElementData( player, "player:playing", true, true )
				
				exports.security:modifyElementData( player, "character:id", character.id, true )
				--temporarily took off these synced datas, who needs these anyway atm
				--exports.security:modifyElementData( player, "character:name", character.name, true )
				--exports.security:modifyElementData( player, "character:gender", character.gender, true )
				--exports.security:modifyElementData( player, "character:skin_color", character.skin_color, true )
				--exports.security:modifyElementData( player, "character:origin", character.origin, true )
				--exports.security:modifyElementData( player, "character:look", character.look, true )
				--exports.security:modifyElementData( player, "character:date_of_birth", character.date_of_birth, true )
				exports.security:modifyElementData( player, "character:default_faction", character.default_faction, true )
				exports.security:modifyElementData( player, "character:cash", character.cash, false )
				exports.security:modifyElementData( player, "character:bank", character.bank, false )
				
				local languages = exports.database:query_single( "SELECT * FROM `languages` WHERE `character_id` = ?", character.id )
				
				if ( languages ) then
					for slot = 1, exports.chat:getMaxLanguages( ) do
						exports.security:modifyElementData( player, "character:language_" .. slot, languages[ "language_" .. slot ] or 0, true )
						exports.security:modifyElementData( player, "character:language_" .. slot .. "_skill", languages[ "skill_" .. slot ] or 0, true )
					end
				end
				
				exports.database:query( "UPDATE `characters` SET `last_played` = CURRENT_TIMESTAMP WHERE `id` = ?", character.id )
				
				triggerClientEvent( player, "accounts:hideView", player )
				triggerClientEvent( player, "scoreboard:showHUD", player )
				triggerClientEvent( player, "scoreboard:updateHUD", player )
				
				spawnPlayer( player, character.pos_x, character.pos_y, character.pos_z )
				
				setPedRotation( player, character.rotation )
				
				setElementModel( player, character.skin_id )
				setElementInterior( player, character.interior )
				setElementDimension( player, character.dimension )
				
				if ( character.health > 0 ) then
					setElementHealth( player, character.health )
				else
					killPed( player )
				end
				
				setPedArmor( player, character.armor )
				setPlayerName( player, character.name )
				
				exports.items:load( player )
				exports.factions:loadPlayer( player )
				
				triggerClientEvent( player, "characters:onSpawn", player )
				
				if ( not isPedDead( player ) ) then
					setCameraTarget( player, player )
				end
				
				local pendingTutorial = get( exports.common:getAccountID( player ) ).tutorial == 0
				
				if ( pendingTutorial ) then
					triggerClientEvent( player, "accounts:showTutorial", player )
				end
				
				fadeCamera( player, true, 2.0 )
				
				outputChatBox( "Welcome" .. ( not character.last_played:find( "0000" ) and " back" or "" ) .. ", " .. character.name:gsub( "_", " " ) .. "!", player, 230, 180, 95 )
				
				if ( pendingTutorial ) then
					showChat( player, false )
				else
					if ( not character.last_played:find( "0000" ) ) then
						outputChatBox( "You were last seen on this character on " .. exports.common:formatDate( character.last_played, true ) .. ".", player, 230, 180, 95 )
					end
				end
				
				exports.admin:updateTickets( player )
			end
		end
		
		if ( fade ) then
			fadeCamera( player, false, 2.725 )
			setTimer( play, 2725, 1, player, character )
		else
			play( )
		end
	end
end

function updateCharacters( player )
	local accountID = exports.common:getAccountID( player )
	
	if ( accountID ) then
		local characters = exports.database:query( "SELECT * FROM `characters` WHERE `account` = ?", accountID )
		
		if ( characters ) then
			triggerClientEvent( player, "accounts:addCharacters", player, characters )
		end
	end
end
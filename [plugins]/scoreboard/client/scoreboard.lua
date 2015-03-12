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

local screenWidth, screenHeight = guiGetScreenSize( )

local showHUD = false
local players = { }
local colors = { online = tocolor( 80, 80, 80, 0.425 * 255 ), offline = tocolor( 40, 40, 40, 0.425 * 255 ), myself = tocolor( 150, 150, 150, 0.425 * 255 ) }
	  colors.default = colors.offline
local hudShowing = false
local showAdminSign = false

function updateScoreboardHUD( )
	showHUD = exports.common:isPlayerPlaying( localPlayer )
	
	if ( showHUD ) then
		players = getElementsByType( "player" )
		
		for index, player in ipairs( players ) do
			if ( player == localPlayer ) then
				players[ index ] = players[ 1 ]
				players[ 1 ] = localPlayer
			end
		end
		
		--[[
		--testing purposes
		for i = 1, 100 do
			table.insert( players, { custom_id = i, custom_name = "Player." .. math.random( 10000, 100000 ), custom_color = math.random( 0, 1 ) == 0 and colors.offline or colors.online } )
		end]]
	end
end
addEvent( "scoreboard:updateHUD", true )
addEventHandler( "scoreboard:updateHUD", root, updateScoreboardHUD )
addEventHandler( "onClientPlayerJoin", root, updateScoreboardHUD )
addEventHandler( "onClientPlayerQuit", root, updateScoreboardHUD )

function showScoreboardHUD( )
	updateScoreboardHUD( )
	
	if ( not hudShowing ) then
		addEventHandler( "onClientRender", root, scoreboardHUD )
		hudShowing = true
	end
end
addEvent( "scoreboard:showHUD", true )
addEventHandler( "scoreboard:showHUD", root, showScoreboardHUD )
addEventHandler( "onClientResourceStart", resourceRoot, showScoreboardHUD )

function hideScoreboardHUD( )
	if ( hudShowing ) then
		removeEventHandler( "onClientRender", root, scoreboardHUD )
		hudShowing = false
	end
end
addEvent( "scoreboard:hideHUD", true )
addEventHandler( "scoreboard:hideHUD", root, hideScoreboardHUD )

function scoreboardHUD( )
	if ( not showHUD ) or ( not hudShowing ) or ( not getKeyState( "tab" ) ) or ( isMTAWindowActive( ) ) or ( isCursorShowing( ) ) then
		return
	end
	
	local screenHeight = screenHeight
	
	-- background
	local scoreboardWidth, scoreboardHeight = screenWidth / 4, screenHeight / 2 - 6 -- - 6 is custom
	local scoreboardX, scoreboardY = ( screenWidth - scoreboardWidth ) / 2, ( screenHeight - scoreboardHeight ) / 2
	
	dxDrawRectangle( scoreboardX, scoreboardY, scoreboardWidth, scoreboardHeight, tocolor( 0, 0, 0, 0.825 * 255 ), true )
	
	-- players
	local playerBoxHeight = 27
	local playerBoxMarginX, playerBoxMarginY = 4, 4
	local playerBoxWidth, playerBoxHeight = scoreboardWidth - ( playerBoxMarginX * 2 ), playerBoxHeight - playerBoxMarginY
	local playerBoxX, playerBoxY = scoreboardX + playerBoxMarginX, scoreboardY + playerBoxMarginY
	
	--// TEMPORARY BEGIN //
	local playerIDText = "ID"
	local playerNameText = "Character name"
	local playerBoxColor = colors.default
	
	-- player box
	local playerBoxY = playerBoxY + ( ( playerBoxHeight + ( playerBoxMarginY / 2 ) ) * 0 )
	
	dxDrawRectangle( playerBoxX, playerBoxY, playerBoxWidth, playerBoxHeight, playerBoxColor, true )
	
	-- player id
	local playerTextMarginX, playerTextMarginY = 4, 4
	local playerTextX, playerTextY = playerBoxX + playerTextMarginX, playerBoxY + playerTextMarginY
	local playerTextWidth, playerTextHeight = playerTextX + playerBoxWidth - ( playerTextMarginX * 2 ), playerTextY + playerBoxHeight - playerTextMarginY
	
	dxDrawText( playerIDText, playerTextX, playerTextY, playerTextWidth, playerTextHeight, tocolor( 255, 255, 255, 0.775 * 255 ), 1.0, "default-bold", "left", "top", true, false, true, false, false, 0, 0, 0 )
	
	-- player name
	local playerTextMarginX, playerTextMarginY = 4, 4
	local playerTextX, playerTextY = playerBoxX + playerTextMarginX + 100, playerBoxY + playerTextMarginY
	local playerTextWidth, playerTextHeight = playerTextX + playerBoxWidth - ( playerTextMarginX * 2 ) - 100, playerTextY + playerBoxHeight - playerTextMarginY
	
	dxDrawText( playerNameText, playerTextX, playerTextY, playerTextWidth, playerTextHeight, tocolor( 255, 255, 255, 0.775 * 255 ), 1.0, "default-bold", "left", "top", true, false, true, false, false, 0, 0, 0 )
	--// TEMPORARY END //
	
	local index = 1
	
	for _, player in ipairs( players ) do
		if ( isElement( player ) ) then
			local playerIDText = "?"
			local playerNameText = "Unknown Player"
			local playerBoxColor = colors.default
			
			if ( isElement( player ) ) then
				playerBoxColor = exports.common:isPlayerPlaying( player ) and "online" or "offline"
				playerBoxColor = player == localPlayer and "myself" or playerBoxColor
				playerBoxColor = colors[ playerBoxColor ]
				
				playerIDText = exports.common:getPlayerID( player ) or ""
				playerNameText = exports.common:getPlayerName( player )
				
				if ( exports.common:isPlayerServerTrialAdmin( player ) ) and ( showAdminSign ) then
					playerNameText = "+ " .. playerNameText
				end
			elseif ( player.custom_id ) or ( player.custom_name ) then
				if ( player.custom_color ) then
					playerBoxColor = player.custom_color
				end
				
				if ( player.custom_id ) then
					playerIDText = tostring( player.custom_id )
				else
					playerIDText = index
				end
				
				if ( player.custom_name ) then
					playerNameText = tostring( player.custom_name )
				end
			end
			
			-- player box
			local playerBoxY = playerBoxY + ( ( playerBoxHeight + ( playerBoxMarginY / 2 ) ) * index )
			
			if ( playerBoxY + playerBoxHeight < scoreboardY + scoreboardHeight ) then
				dxDrawRectangle( playerBoxX, playerBoxY, playerBoxWidth, playerBoxHeight, playerBoxColor, true )
				
				-- player id
				local playerTextMarginX, playerTextMarginY = 4, 4
				local playerTextX, playerTextY = playerBoxX + playerTextMarginX, playerBoxY + playerTextMarginY
				local playerTextWidth, playerTextHeight = playerTextX + playerBoxWidth - ( playerTextMarginX * 2 ), playerTextY + playerBoxHeight - playerTextMarginY
				
				dxDrawText( playerIDText, playerTextX, playerTextY, playerTextWidth, playerTextHeight, tocolor( 255, 255, 255, 0.775 * 255 ), 1.0, "clear", "left", "top", true, false, true, false, false, 0, 0, 0 )
				
				-- player name
				local playerTextMarginX, playerTextMarginY = 4, 4
				local playerTextX, playerTextY = playerBoxX + playerTextMarginX + 100, playerBoxY + playerTextMarginY
				local playerTextWidth, playerTextHeight = playerTextX + playerBoxWidth - ( playerTextMarginX * 2 ) - 100, playerTextY + playerBoxHeight - playerTextMarginY
				
				dxDrawText( playerNameText, playerTextX, playerTextY, playerTextWidth, playerTextHeight, tocolor( 255, 255, 255, 0.775 * 255 ), 1.0, "clear", "left", "top", true, false, true, false, false, 0, 0, 0 )
				
				-- additionals
				index = index + 1
			end
		end
	end
end

local startingIndex = 1
local scrollStep = 5

addEventHandler( "onClientKey", root,
	function( button, pressOrRelease )
		if ( showHUD ) and ( hudShowing ) then
			if ( button == "mouse_wheel_up" ) then
				if ( startingIndex - scrollStep >= 1 ) then
					startingIndex = startingIndex - scrollStep
					
					updateScoreboardHUD( )
					
					local newPlayers = { }
					
					for index, player in pairs( players ) do
						if ( index < startingIndex ) then
							players[ index ] = nil
						else
							table.insert( newPlayers, player )
						end
					end
					
					players = newPlayers
				end
			elseif ( button == "mouse_wheel_down" ) then
				if ( players[ scrollStep ] ) then
					startingIndex = startingIndex + scrollStep
					
					updateScoreboardHUD( )
					
					local newPlayers = { }
					
					for index, player in pairs( players ) do
						if ( index < startingIndex ) then
							players[ index ] = nil
						else
							table.insert( newPlayers, player )
						end
					end
					
					players = newPlayers
				end
			end
		end
	end
)
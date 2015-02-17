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

local monitorWatchers = { }
local monitorSpots = {
	{ x = 1545.15, y = -1675.52, z = 13.55, interior = 0, dimension = 0, radius = 5 }
}

function isWatching( player )
	return monitorWatchers[ player ] or false
end

function stopWatching( player, ignoreSync )
	if ( client ) and ( client ~= source ) then
		return
	end
	
	local player = player or source
	
	if ( player ) then
		monitorWatchers[ player ] = nil
		setElementFrozen( player, false )
		setCameraTarget( player, player )
		toggleAllControls( player, true, true, false )
		
		if ( not ignoreSync ) then
			triggerClientEvent( player, "cctv:monitor", player, true )
		end
	end
end
addEvent( "cctv:watch:stop", true )
addEventHandler( "cctv:watch:stop", root, stopWatching )

function startWatching( player, spotID, cameraID )
	if ( client ) and ( client ~= source ) then
		return
	end
	
	local player = source or player
	
	monitorWatchers[ player ] = spotID or -1
	setElementFrozen( player, true )
	toggleAllControls( player, false, true, false )
	triggerClientEvent( player, "cctv:monitor", player, cameraID )
end
addEvent( "cctv:watch", true )
addEventHandler( "cctv:watch", root, startWatching )

function getPlayersWatching( spotID )
	local players = { }
	
	for player, _spotID in pairs( monitorWatchers ) do
		if ( not spotID ) or ( _spotID == spotID ) then
			table.insert( players, player )
		end
	end
	
	return players
end

addCommandHandler( "cctvmonitor",
	function( player, cmd )
		if ( exports.common:isPlayerPlaying( player ) ) then
			if ( not isWatching( player ) ) then
				if ( exports.common:count( cctvs ) > 0 ) then
					local x, y, z = getElementPosition( player )
					local closest, closestSpot = 10000, false
					
					if ( exports.common:isOnDuty( player ) ) then
						closestSpot = 1
					else
						for index, spot in ipairs( monitorSpots ) do
							local distance = getDistanceBetweenPoints3D( x, y, z, spot.x, spot.y, spot.z )
							
							if ( getElementInterior( player ) == spot.interior ) and ( getElementDimension( player ) == spot.dimension ) and ( distance <= spot.radius ) and ( distance < closest ) then
								closest = distance
								closestSpot = index
							end
						end
					end
					
					if ( closestSpot ) then
						startWatching( player, closestSpot )
						outputChatBox( "You are now monitoring CCTVs.", player, 95, 230, 95 )
					else
						outputChatBox( "There are no CCTV monitors nearby.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "There are no CCTVs to monitor.", player, 230, 95, 95 )
				end
			else
				stopWatching( player )
				outputChatBox( "You are no longer monitoring CCTVs.", player, 95, 230, 95 )
			end
		end
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for _, player in ipairs( getPlayersWatching( ) ) do
			stopWatching( player, true )
		end
	end
)
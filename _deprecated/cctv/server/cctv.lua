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

local defaultFoV = 85
local viewers = { }

function watchCCTV( player, id )
	local worldItem = exports.database:query_single( "SELECT * FROM `worlditems` WHERE `id` = ? AND `item_id` = ? LIMIT 1", id, 15 )
	
	if ( worldItem ) then
		local _ = exports.items:getWorldItem( worldItem.id )
		
		if ( _ ) and ( _.object ) then
			local x, y, z = worldItem.pos_x, worldItem.pos_y, worldItem.pos_z
			local rotation = worldItem.rot_z + 140
				  rotation = rotation > 360 and rotation - 360 or ( rotation < 0 and rotation + 360 or rotation )
			local aimX, aimY, aimZ = exports.common:nextToPosition( x, y, z, rotation, 0.1 )
			local cctvData = split( worldItem.item_value, ";" )
			
			setCameraMatrix( player, x, y, z, aimX, aimY, aimZ, cctvData[ 2 ] or 0, cctvData[ 3 ] or defaultFoV )
			
			outputChatBox( "You are now watching " .. ( cctvData[ 1 ] or tostring( cctvData ) ) .. ".", player, 230, 180, 95 )
			
			return true
		end
	end
	
	return false
end

function watchMonitor( player, data )
	local item = type( data ) == "table" and data or exports.database:query_single( "SELECT * FROM `inventory` WHERE `id` = ? AND `item_id` = ? LIMIT 1", data, 16 )
	
	if ( item ) then
		local value = type( data ) == "table" and item.itemValue or item.item_value
		local cctvCameras = split( value, ";" )
		
		if ( ( cctvCameras ) and ( exports.common:count( cctvCameras ) > 0 ) ) or ( tonumber( value ) ) then
			if ( watchCCTV( player, type( cctvCameras ) == "table" and cctvCameras[ 1 ].id or value ) ) then
				viewers[ player ] = item.id
				
				return true
			end
		end
	end
	
	return false
end

function isWatching( player, id )
	return isElement( player ) and ( id and viewers[ player ] == id or viewers[ player ] ) or false
end

function stopWatching( player )
	local player = player or source
	
	setCameraTarget( player, player )
	setElementFrozen( player, false )
	
	viewers[ player ] = nil
end
addEventHandler( "onPlayerQuit", root, stopWatching )
addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for player in pairs( viewers ) do
			stopWatching( player )
		end
	end
)
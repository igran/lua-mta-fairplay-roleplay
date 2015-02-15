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

addCommandHandler( { "createshop", "makeshop", "newshop", "createstore", "makestore", "newstore" },
	function( player, cmd, name, shopType, modelID )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			shopType = tonumber( shopType )
			modelID = tonumber( modelID )

			if ( name ) and ( name:len( ) > 1 ) and ( shopType ) then
				local shopTypeData = exports.shops:getShopList( )[ shopType ]
				
				if ( shopTypeData ) then
					modelID = modelID or shopTypeData.skins[ math.random( #shopTypeData.skins ) ]
					
					local x, y, z = getElementPosition( player )
					local rotation = getPedRotation( player )
					local interior, dimension = getElementInterior( player ), getElementDimension( player )
					
					local shopID, shop = exports.shops:create( x, y, z, interior, dimension, rotation, name, shopType, modelID, exports.common:getCharacterID( player ) )
					
					if ( shopID ) then
						outputChatBox( "You created a " .. shopTypeData.name .. " shop with ID " .. shopID .. ".", player, 95, 230, 95 )
					else
						outputChatBox( "Could not create a shop with type " .. shopTypeData.name .. " (" .. shopType .. "). Please try again.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "This shop type is not valid.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [name] [shop type] <[model id]>", player, 230, 180, 95 )
			end
		end
	end
)

addCommandHandler( { "deleteshop", "removeshop", "delshop", "deletestore", "removestore", "delstore" },
	function( player, cmd, shopID )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local shopID = tonumber( shopID )
			
			if ( shopID ) then
				local shop = exports.shops:get( shopID )
				
				if ( shop ) then
					if ( exports.shops:delete( shopID ) ) then
						outputChatBox( "You deleted a shop with ID " .. shopID .. ".", player, 95, 230, 95 )
					else
						outputChatBox( "Something went wrong when deleting the shop. Please retry.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "Could not find a shop with that identifier.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [shop id]", player, 230, 180, 95 )
			end
		end
	end
)
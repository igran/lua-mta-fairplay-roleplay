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

addCommandHandler( { "createinterior", "makeinterior", "newinterior", "createint", "makeint", "newint" },
	function( player, cmd, insideID, typeID, price, ... )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			insideID = tonumber( insideID )
			typeID = tonumber( typeID )
			price = tonumber( price )
			name = table.concat( { ... }, " " )

			if ( insideID ) and ( typeID ) and ( price ) and ( price >= 0 ) and ( name ) and ( name:len( ) > 0 ) then
				local configuration = exports.interiors:getInteriorConfiguration( )
				local inside = configuration.inside[ insideID ]
				
				if ( inside ) then
					if ( configuration.type[ typeID ] ) then
						local x, y, z = getElementPosition( player )
						
						local interiorID = exports.interiors:create( x, y, z, getElementInterior( player ), getElementDimension( player ), inside.x, inside.y, inside.z, inside.interior, name, typeID, price, 0, exports.common:getCharacterID( player ) )
						
						if ( interiorID ) then
							outputChatBox( "You created an interior with ID " .. interiorID .. ".", player, 95, 230, 95 )
						else
							outputChatBox( "Could not create an interior. Please retry.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Invalid interior type of ID " .. typeID .. ".", player, 230, 95, 95 )
					end
				else
					outputChatBox( "Invalid interior inside of ID " .. insideID .. ".", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [inside id] [type: 1=house, 2=rentable, 3=government, 4=business] [price] [name]", player, 230, 180, 95 )
			end
		end
	end
)

addCommandHandler( { "deleteinterior", "removeinterior", "delshop", "deleteint", "removeint", "delint" },
	function( player, cmd, interiorID )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local interiorID = tonumber( interiorID )
			
			if ( interiorID ) then
				local interior = exports.interiors:get( interiorID )
				
				if ( interior ) then
					if ( exports.interiors:delete( interiorID ) ) then
						outputChatBox( "You deleted an interior with ID " .. interiorID .. ".", player, 95, 230, 95 )
					else
						outputChatBox( "Something went wrong when deleting the interior. Please retry.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "Could not find an interior with that identifier.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [interior id]", player, 230, 180, 95 )
			end
		end
	end
)
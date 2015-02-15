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
local interiors = { }

local currentInteriorMarker, isCurrentInteriorMarkerEntrance

function enter( )
	local interior = interiors[ currentInteriorMarker ]
	
	if ( currentInteriorMarker ) and ( interior ) then
		if ( ( interior.is_disabled ) or ( interior.is_deleted ) ) and ( not exports.common:isOnDuty( localPlayer ) ) then
			return false
		end
		
		if ( ( interior.owner_id ~= 0 ) or ( interior.type == 3 ) ) and ( interior.is_locked ) then
			outputChatBox( "That door appears to be locked.", 230, 95, 95 )
			return false
		end
		
		local interiorMarker = isCurrentInteriorMarkerEntrance and interior.entrance or interior.exit
		
		if ( isElement( interiorMarker ) ) then
			local x, y, z = getElementPosition( interiorMarker )
			
			if ( getDistanceBetweenPoints3D( x, y, z, getElementPosition( localPlayer ) ) <= 1 ) and 
			   ( getElementInterior( localPlayer ) == getElementInterior( interiorMarker ) ) and 
			   ( getElementDimension( localPlayer ) == getElementDimension( interiorMarker ) ) then
				if ( interior.owner_id ~= 0 ) or ( interior.type == 3 ) then
					triggerServerEvent( "interiors:enter", localPlayer, currentInteriorMarker, isCurrentInteriorMarkerEntrance )
					currentInteriorMarker, isCurrentInteriorMarkerEntrance = nil, nil
					removeEventHandler( "onClientHUDRender", root, renderInteriorMarkerText )
				else
					-- show some payment options here ok
				end
				
				return true
			end
		end
	end
	
	return false
end

function toggleLock( )
	local interior = interiors[ currentInteriorMarker ]
	
	if ( currentInteriorMarker ) and ( interior ) then
		if ( ( interior.is_disabled ) or ( interior.is_deleted ) ) and ( not exports.common:isOnDuty( localPlayer ) ) then
			return false
		end
		
		local interiorMarker = isCurrentInteriorMarkerEntrance and interior.entrance or interior.exit
		
		if ( isElement( interiorMarker ) ) then
			local x, y, z = getElementPosition( interiorMarker )
			
			if ( getDistanceBetweenPoints3D( x, y, z, getElementPosition( localPlayer ) ) <= 1 ) and 
			   ( getElementInterior( localPlayer ) == getElementInterior( interiorMarker ) ) and 
			   ( getElementDimension( localPlayer ) == getElementDimension( interiorMarker ) ) then
				triggerServerEvent( "interiors:lock", localPlayer, currentInteriorMarker, isCurrentInteriorMarkerEntrance )
				
				return true
			end
		end
	end
	
	return false
end

addEvent( "interiors:load", true )
addEventHandler( "interiors:load", root,
	function( loadInteriors, softUnload )
		for index, interior in pairs( loadInteriors ) do
			triggerEvent( "interiors:unload", localPlayer, { interior.id }, softUnload )
			
			interiors[ interior.id ] = interior
			
			local pickupIcon = interior.is_disabled == 1 and 1314 or ( interior.owner_id ~= 0 or interior.type == 3 and 1318 or ( interior.type == 4 and 1272 or 1273 ) )
			local entranceInterior = createPickup( interior.pos_x, interior.pos_y, interior.pos_z, 3, pickupIcon )
			setElementInterior( entranceInterior, interior.interior )
			setElementDimension( entranceInterior, interior.dimension )

			if ( isElement( entranceInterior ) ) then
				setElementData( entranceInterior, "interior:id", interior.id, false )
				setElementData( entranceInterior, "interior:entrance", true, false )

				local exitInterior = createPickup( interior.target_pos_x, interior.target_pos_y, interior.target_pos_z, 3, pickupIcon )
				setElementInterior( exitInterior, interior.target_interior )
				setElementDimension( exitInterior, interior.id )

				if ( isElement( exitInterior ) ) then
					setElementData( exitInterior, "interior:id", interior.id, false )

					interiors[ interior.id ].entrance = entranceInterior
					interiors[ interior.id ].exit = exitInterior
				else
					destroyElement( entranceInterior )
				end
			end
		end
	end
)

addEvent( "interiors:unload", true )
addEventHandler( "interiors:unload", root,
	function( unloadInteriors, softUnload )
		for index, id in pairs( unloadInteriors ) do
			if ( interiors[ id ] ) then
				if ( isElement( interiors[ id ].entrance ) ) then
					destroyElement( interiors[ id ].entrance )
				end
				
				if ( isElement( interiors[ id ].exit ) ) then
					destroyElement( interiors[ id ].exit )
				end
				
				interiors[ id ] = nil
				
				if ( not softUnload ) and ( currentInteriorMarker == id ) then
					currentInteriorMarker, isCurrentInteriorMarkerEntrance = nil, nil
				end
			end
		end
	end
)

addEventHandler( "onClientPickupHit", getResourceDynamicElementRoot( resource ),
	function( thePlayer, matchingDimension )
		if ( exports.common:isPlayerPlaying( thePlayer ) ) and ( matchingDimension ) then
			local id = exports.common:getInteriorID( source )
			
			if ( id ) and ( currentInteriorMarker ~= id ) then
				currentInteriorMarker, isCurrentInteriorMarkerEntrance = id, getElementData( source, "interior:entrance" )
				addEventHandler( "onClientHUDRender", root, renderInteriorMarkerText )
			end
		end
	end
)

addEventHandler( "onClientPickupLeave", getResourceDynamicElementRoot( resource ),
	function( thePlayer, matchingDimension )
		if ( exports.common:isPlayerPlaying( thePlayer ) ) and ( matchingDimension ) then
			local id = exports.common:getInteriorID( source )
			
			if ( id ) and ( currentInteriorMarker == id ) then
				currentInteriorMarker, isCurrentInteriorMarkerEntrance = nil, nil
				removeEventHandler( "onClientHUDRender", root, renderInteriorMarkerText )
			end
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "interiors:ready", localPlayer )
		
		bindKey( "enter", "down", enter )
		bindKey( "f", "down", enter )
		bindKey( "k", "down", toggleLock )
	end
)

local minimumWidth = 300
local baseYOffset = 250

function renderInteriorMarkerText( )
	if ( not currentInteriorMarker ) then
		currentInteriorMarker, isCurrentInteriorMarkerEntrance = nil, nil
		removeEventHandler( "onClientHUDRender", root, renderInteriorMarkerText )
		return
	end
	
	local interior = interiors[ currentInteriorMarker ]
	
	if ( not interior ) then
		return
	end
	
	-- Interior info text
	local text = interior.name
	
	local scale = 1.25
	local font = "pricedown"
	local length = 50
	
	while ( dxGetTextWidth( text, scale, font ) > screenWidth / 3 ) do
		length = length - 1
		text = text:sub( 0, length )
	end
	
	text = text:sub( -1, -1 ) == " " and text:sub( 0, -2 ) or text
	
	if ( interiors[ currentInteriorMarker ].name:len( ) > length ) then
		text = text .. "..."
	end
	
	local width = math.max( minimumWidth, dxGetTextWidth( text, scale, font ) )
	local height = dxGetFontHeight( scale, font )
	
	local x = ( screenWidth - width ) / 2
	local y = screenHeight - baseYOffset

	local boxPadding = 10
	local boxX = x - boxPadding * 2
	local boxY = y - boxPadding
	local boxWidth = width + boxPadding * 4
	local boxHeight = height + boxPadding * 2
	
	dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 5, 5, 5, 200 ), false )
	dxDrawText( text, x, y, x + width, y + height, tocolor( 255, 255, 255, 255 ), scale, font, "center", "center", true, false, false, false, false, 0, 0, 0 )
	
	-- Owner name text
	if ( exports.common:isOnDuty( localPlayer ) ) then
		text = "Owner: " .. interior.owner_name
		
		scale = 1
		font = "default"
		--width = math.max( width, dxGetTextWidth( text, scale, font ) )
		width = dxGetTextWidth( text, scale, font )
		height = dxGetFontHeight( scale, font )
		
		x = ( screenWidth - width ) / 2
		y = screenHeight - baseYOffset + boxHeight + 2

		boxPadding = 7
		boxPadding = 10
		boxX = x - boxPadding * 2
		boxY = y - boxPadding
		boxWidth = width + boxPadding * 4
		boxHeight = height + boxPadding * 2
		
		dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 5, 5, 5, 200 ), false )
		dxDrawText( text, x, y, x + width, y + height, tocolor( 255, 255, 255, 255 ), scale, font, "center", "center", true, false, false, false, false, 0, 0, 0 )
	end
	
	-- Enter text
	if ( interior.is_disabled ) and ( interior.is_deleted ) then
		return
	else
		if ( interior.owner_id == 0 ) and ( interior.type ~= 3 ) then
			text = "Press 'F' or 'Enter' to show payment options"
		else
			text = "Press 'F' or 'Enter' to enter the interior"
		end
	end
	
	local scale = 1
	local font = "default"
	--local width = math.max( width, dxGetTextWidth( text, scale, font ) )
	local width = dxGetTextWidth( text, scale, font )
	local height = dxGetFontHeight( scale, font )
	
	local x = ( screenWidth - width ) / 2
	local y = y + boxHeight + 2

	local boxPadding = 7
	local boxPadding = 10
	local boxX = x - boxPadding * 2
	local boxY = y - boxPadding
	local boxWidth = width + boxPadding * 4
	local boxHeight = height + boxPadding * 2
	
	dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 5, 5, 5, 200 ), false )
	dxDrawText( text, x, y, x + width, y + height, tocolor( 255, 255, 255, 255 ), scale, font, "center", "center", true, false, false, false, false, 0, 0, 0 )
end
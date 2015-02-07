--[[
	The MIT License (MIT)

	Copyright (c) 2014 Socialz (+ soc-i-alz GitHub organization)

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

addEvent( "interiors:load", true )
addEventHandler( "interiors:load", root,
	function( loadInteriors )
		for index, interior in pairs( loadInteriors ) do
			triggerEvent( "interiors:unload", localPlayer, { interior.id } )
			
			interiors[ interior.id ] = interior
			
			local pickupIcon = interior.is_disabled and 1314 or ( interior.owner_id ~= 0 or interior.type == 3 and 1318 or ( interior.type == 4 and 1272 or 1273 ) )
			local entranceInterior = createPickup( interior.pos_x, interior.pos_y, interior.pos_z, 3, pickupIcon )
			setElementInterior( entranceInterior, interior.interior )
			setElementDimension( entranceInterior, interior.dimension )

			if ( isElement( entranceInterior ) ) then
				setElementData( entranceInterior, "interior:id", interior.id, false )
				setElementData( entranceInterior, "interior:entrance", true, false )

				local exitInterior = createPickup( interior.pos_x, interior.pos_y, interior.pos_z, 3, pickupIcon )
				setElementInterior( exitInterior, interior.interior )
				setElementDimension( exitInterior, interior.id )

				if ( isElement( exitInterior ) ) then
					setElementData( exitInterior, "interior:id", interior.id, false )

					setElementParent( exitInterior, entranceInterior )

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
	function( unloadInteriors )
		for index, id in pairs( unloadInteriors ) do
			if ( interiors[ id ] ) then
				if ( isElement( interiors[ id ].entrance ) ) then
					destroyElement( interiors[ id ].entrance )
				end
				
				if ( isElement( interiors[ id ].exit ) ) then
					destroyElement( interiors[ id ].exit )
				end
				
				interiors[ id ] = nil
				
				if ( currentInteriorMarker == id ) then
					currentInteriorMarker = nil
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
				currentInteriorMarker = id
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
				currentInteriorMarker = nil
				removeEventHandler( "onClientHUDRender", root, renderInteriorMarkerText )
			end
		end
	end
)

local minimumWidth = 300
local baseYOffset = 250

function renderInteriorMarkerText( )
	if ( not currentInteriorMarker ) then
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
	local text = "Press 'F' or 'Enter' to enter the interior"
	
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
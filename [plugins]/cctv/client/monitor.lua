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

local x, y = screenWidth * 0.15, screenHeight * 0.1
local scale = 100
local monitorTick, showRec, isMonitoring
local cameraEffect = 1
local scanlinesY = 0
local cameraEffects = { "normal", "nightvision", "thermalvision" }

local minFov, maxFov = 1, 90
local posX, posY, posZ = 0, 0, 0
local aimX, aimY, aimZ = 0, 0, 0
local roll, fov = 0, maxFov
local aimRotation = 0
local oAimX, oAimY, oAimZ, oAimRotation

local tiltSensitivity, panSensitivity = 0.00085, 0.5
local tiltMultiplier, panMultiplier = 0, 0
local digitalFont, currentCameraIndex

local function goToCamera( index )
	local cctv = indexedCCTVs[ index ]
	
	if ( cctv ) then
		currentCameraIndex = index
		
		posX, posY, posZ = cctv.pos_x, cctv.pos_y, cctv.pos_z
		aimRotation = math.random( 80, 160 )
		aimX, aimY, aimZ = exports.common:nextToPosition( cctv.pos_x, cctv.pos_y, cctv.pos_z - 0.05, aimRotation, 0.1 )
		oAimRotation = aimRotation
		oAimX, oAimY, oAimZ = aimX, aimY, aimZ
		
		setCameraMatrix( posX, posY, posZ, aimX, aimY, aimZ, roll, fov )
		
		return true
	end
	
	return false
end

local function goToRandomCamera( )
	return goToCamera( math.random( #indexedCCTVs ) )
end

local function monitorHUD( )
	if ( not isMonitoring ) then
		return
	end
	
	scanlinesY = scanlinesY < -screenHeight and 0 or scanlinesY - 0.25
	
	dxDrawImage( 0, scanlinesY, screenWidth, screenHeight, "assets/scanlines.png", 0, 0, 0, tocolor( 255, 255, 255, 12 ), false )
	dxDrawImage( 0, scanlinesY + screenHeight, screenWidth, screenHeight, "assets/scanlines.png", 0, 0, 0, tocolor( 255, 255, 255, 12 ), false )
	
	if ( getTickCount( ) >= monitorTick + 1000 ) then
		monitorTick = getTickCount( )
		showRec = not showRec
	end
	
	if ( showRec ) then
		dxDrawImage( x, y, scale, scale, "assets/rec.png", 0, 0, 0, tocolor( 255, 255, 255, 255 ), false )
	end
	
	if ( digitalFont ) then
		local text = "REC"
		local left, top, right, bottom = x + 125, y, x + 125 + dxGetTextWidth( text, 1, digitalFont ), y + dxGetFontHeight( 1, digitalFont )
		
		dxDrawText( text, left + 2, top + 2, right + 2, bottom + 2, tocolor( 0, 0, 0, 127 ), 1, digitalFont, "left", "top", true, false, false, false, false, 0, 0, 0 )
		dxDrawText( text, left, top, right, bottom, tocolor( 255, 255, 255, 255 ), 1, digitalFont, "left", "top", true, false, false, false, false, 0, 0, 0 )
		
		local fontHeight = dxGetFontHeight( 0.45, digitalFont )
		local text = ( indexedCCTVs[ currentCameraIndex ] and tostring( indexedCCTVs[ currentCameraIndex ].name ) or "Unknown" ) .. " at " .. getZoneName( posX, posY, posZ ) .. ", " .. getZoneName( posX, posY, posZ, true )
		local left, top, right, bottom = x + 125, screenHeight - ( ( screenHeight * 0.1 ) * 2 ), x + 125 + dxGetTextWidth( text, 1, digitalFont ), screenHeight - ( ( screenHeight * 0.1 ) * 2 ) + fontHeight
		
		dxDrawText( text, left + 2, top + 2, right + 2, bottom + 2, tocolor( 0, 0, 0, 127 ), 0.45, digitalFont, "left", "top", true, false, false, false, false, 0, 0, 0 )
		dxDrawText( text, left, top, right, bottom, tocolor( 255, 255, 255, 255 ), 0.45, digitalFont, "left", "top", true, false, false, false, false, 0, 0, 0 )
		
		local hour, minute = getTime( )
		local text = ( getRealTime( ).hour < 10 and "0" .. getRealTime( ).hour or getRealTime( ).hour ) .. ":" .. ( getRealTime( ).minute < 10 and "0" .. getRealTime( ).minute or getRealTime( ).minute ) .. ":" .. ( getRealTime( ).second < 10 and "0" .. getRealTime( ).second or getRealTime( ).second )
		local left, top, right, bottom = x + 125, screenHeight - ( ( screenHeight * 0.1 ) * 2 ) + fontHeight, x + 125 + dxGetTextWidth( text, 1, digitalFont ), screenHeight - ( ( screenHeight * 0.1 ) * 2 ) + ( fontHeight * 2 )
		
		dxDrawText( text, left + 2, top + 2, right + 2, bottom + 2, tocolor( 0, 0, 0, 127 ), 0.45, digitalFont, "left", "top", true, false, false, false, false, 0, 0, 0 )
		dxDrawText( text, left, top, right, bottom, tocolor( 255, 255, 255, 255 ), 0.45, digitalFont, "left", "top", true, false, false, false, false, 0, 0, 0 )
	else
		dxDrawImage( x + 125 + 2, y + 2, scale, scale, "assets/rec_text.png", 0, 0, 0, tocolor( 0, 0, 0, 127 ), false )
		dxDrawImage( x + 125, y, scale, scale, "assets/rec_text.png", 0, 0, 0, tocolor( 255, 255, 255, 255 ), false )
	end
	
	if ( not isMTAWindowActive( ) ) and ( not getKeyState( "lalt" ) ) and ( not getKeyState( "ralt" ) ) then
		local multiplierActivated, slowerSpeed
		
		if ( getKeyState( "lctrl" ) ) or ( getKeyState( "rctrl" ) ) then
			slowerSpeed = true
			tiltMultiplier, panMultiplier = 0.001, 0.6
		end
		
		if ( getKeyState( "lshift" ) ) or ( getKeyState( "rshift" ) ) then
			multiplierActivated = true
			tiltMultiplier, panMultiplier = 0.0025, 0.85
		end
		
		if ( not multiplierActivated ) and ( not slowerSpeed ) then
			tiltMultiplier, panMultiplier = 0, 0
		end
		
		if ( getKeyState( "arrow_u" ) ) then
			if ( aimZ - oAimZ < 0.18 ) then
				aimZ = aimZ + ( slowerSpeed and tiltMultiplier - tiltSensitivity or tiltSensitivity + tiltMultiplier )
			end
		elseif ( getKeyState( "arrow_d" ) ) then
			if ( oAimZ - aimZ < 0.18 ) then
				aimZ = aimZ - ( slowerSpeed and tiltMultiplier - tiltSensitivity or tiltSensitivity + tiltMultiplier )
			end
		end
		
		if ( getKeyState( "arrow_l" ) ) then
			--if ( aimRotation - oAimRotation < 180 ) then
				aimRotation = aimRotation + ( slowerSpeed and panMultiplier - panSensitivity or panSensitivity + panMultiplier )
			--end
		elseif ( getKeyState( "arrow_r" ) ) then
			--if ( oAimRotation - aimRotation < 180 ) then
				aimRotation = aimRotation - ( slowerSpeed and panMultiplier - panSensitivity or panSensitivity + panMultiplier )
			--end
		end
		
		aimX, aimY = exports.common:nextToPosition( posX, posY, posZ - 0.05, aimRotation, 0.1 )
		
		setCameraMatrix( posX, posY, posZ, aimX, aimY, aimZ, roll, fov )
	end
end

addEvent( "cctv:monitor", true )
addEventHandler( "cctv:monitor", root,
	function( stopWatching )
		if ( stopWatching ) then
			setCameraGoggleEffect( "normal" )
			
			if ( isMonitoring ) then
				removeEventHandler( "onClientHUDRender", root, monitorHUD )
				isMonitoring = false
			end
		else
			if ( goToRandomCamera( ) ) then
				if ( not isMonitoring ) then
					addEventHandler( "onClientHUDRender", root, monitorHUD )
					isMonitoring = true
					monitorTick = getTickCount( )
				end
			end
		end
	end
)

addEventHandler( "onClientKey", root,
	function( button, pressOrRelease )
		if ( isMonitoring ) then
			if ( pressOrRelease ) then
				if ( getKeyState( "lalt" ) ) or ( getKeyState( "ralt" ) ) then
					local index = currentCameraIndex
					local cameraEffectChanged
					
					if ( button == "arrow_u" ) then
						if ( cameraEffect == #cameraEffects ) then
							cameraEffect = 1
						else
							cameraEffect = cameraEffect + 1
						end
						
						cameraEffectChanged = true
					elseif ( button == "arrow_d" ) then
						if ( cameraEffect == 1 ) then
							cameraEffect = #cameraEffects
						else
							cameraEffect = cameraEffect - 1
						end
						
						cameraEffectChanged = true
					end
					
					if ( not cameraEffectChanged ) then
						if ( button == "arrow_l" ) then
							if ( index == 1 ) then
								index = #indexedCCTVs
							else
								index = index - 1
							end
						elseif ( button == "arrow_r" ) then
							if ( index == #indexedCCTVs ) then
								index = 1
							else
								index = index + 1
							end
						else
							return
						end
						
						if ( index ) then
							return goToCamera( index )
						end
					end
					
					setCameraGoggleEffect( cameraEffects[ cameraEffect ] )
				else
					if ( button == "mouse_wheel_up" ) then
						fov = math.max( minFov, fov - 2.5 )
					elseif ( button == "mouse_wheel_down" ) then
						fov = math.min( maxFov, fov + 2.5 )
					end
				end
			end
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		digitalFont = dxCreateFont( "assets/ds-digib.ttf", 58, true )
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		if ( isMonitoring ) then
			setCameraGoggleEffect( "normal" )
		end
	end
)
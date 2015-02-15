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
local selectedCCTV, cctvObject
cctvs, indexedCCTVs = { }, { }

local cctvManager = {
	button = { }
}

local cctvEdit = {
    button = { },
    edit = { },
    label = { }
}

local options = {
	defaultModel = 2921,
	multiplier = {
		small = 0.1,
		normal = 1,
		big = 5
	}
}

local function loadCCTVsToGridList( cctvs )
	if ( isElement( cctvManager.window ) ) then
		guiGridListClear( cctvManager.cctvs )
		
		for _, cctv in ipairs( indexedCCTVs ) do
			local row = guiGridListAddRow( cctvManager.cctvs )
			
			guiGridListSetItemText( cctvManager.cctvs, row, 1, cctv.id or "-1", false, true )
			guiGridListSetItemText( cctvManager.cctvs, row, 2, cctv.name or "Unknown", false, false )
			guiGridListSetItemText( cctvManager.cctvs, row, 3, cctv.location or "Unknown", false, false )
			
			if ( cctv.is_disabled ) then
				guiGridListSetItemColor( cctvManager.cctvs, row, 1, 230, 95, 95, 255 )
				guiGridListSetItemColor( cctvManager.cctvs, row, 2, 230, 95, 95, 255 )
				guiGridListSetItemColor( cctvManager.cctvs, row, 3, 230, 95, 95, 255 )
			end
		end
		
		return true
	end
	
	return false
end

function showCCTVManager( forceClose, forceEnd )
	if ( isElement( cctvManager.window ) ) then
		destroyElement( cctvManager.window )
		
		showCursor( false )
		
		showCCTVEdit( true, true )
		
		if ( forceClose ) then
			return
		end
	end
	
	if ( forceEnd ) then
		return
	end
	
	if ( not exports.common:isPlayerServerAdmin( localPlayer ) ) then
		return
	end
	
	showCursor( true )
	
	cctvManager.window = guiCreateWindow( ( screenWidth - 493 ) / 2, ( screenHeight - 470 ) / 2, 493, 470, "CCTV Manager", false )
	guiWindowSetSizable( cctvManager.window, false )
	
	cctvManager.cctvs = guiCreateGridList( 10, 26, 473, 315, false, cctvManager.window )
	guiGridListAddColumn( cctvManager.cctvs, "ID", 0.1 )
	guiGridListAddColumn( cctvManager.cctvs, "Name", 0.4 )
	guiGridListAddColumn( cctvManager.cctvs, "Location", 0.4 )
	
	loadCCTVsToGridList( cctvs )
	
	cctvManager.button.edit = guiCreateButton( 10, 351, 473, 29, "Edit Camera", false, cctvManager.window )
	guiSetEnabled( cctvManager.button.edit, false )
	cctvManager.button.create = guiCreateButton( 10, 390, 473, 29, "Create Camera", false, cctvManager.window )
	cctvManager.button.close = guiCreateButton( 10, 429, 473, 29, "Close Window", false, cctvManager.window )
	
	local function cctvEditHandler( )
		local row, column = guiGridListGetSelectedItem( cctvManager.cctvs )
		
		if ( row ~= -1 ) and ( column ~= -1 ) then
			local id = tonumber( guiGridListGetItemText( cctvManager.cctvs, row, 1 ) )
			
			selectedCCTV = id
			
			showCCTVEdit( )
		end
	end
	addEventHandler( "onClientGUIDoubleClick", cctvManager.cctvs, cctvEditHandler, false )
	addEventHandler( "onClientGUIClick", cctvManager.button.edit, cctvEditHandler, false )
	
	addEventHandler( "onClientGUIClick", cctvManager.button.create,
		function( )
			showCCTVEdit( )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", cctvManager.button.close,
		function( )
			showCCTVManager( true )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", cctvManager.cctvs,
		function( )
			local row, column = guiGridListGetSelectedItem( cctvManager.cctvs )
			
			if ( row ~= -1 ) and ( column ~= -1 ) then
				guiSetEnabled( cctvManager.button.edit, true )
			else
				guiSetEnabled( cctvManager.button.edit, false )
			end
		end, false
	)
end

function showCCTVEdit( forceClose, forceEnd )
	if ( isElement( cctvEdit.window ) ) then
		destroyElement( cctvEdit.window )
		
		if ( isElement( cctvManager.window ) ) then
			guiSetVisible( cctvManager.window, true )
			showCursor( true )
		end
		
		if ( isElement( cctvObject ) ) then
			destroyElement( cctvObject )
		end
		
		if ( selectedCCTV ) and ( cctvs[ selectedCCTV ] ) and ( isElement( cctvs[ selectedCCTV ].object ) ) then
			setElementAlpha( cctvs[ selectedCCTV ].object, 255 )
		end
		
		selectedCCTV = nil
		
		guiSetInputEnabled( false )
		
		if ( forceClose ) then
			return
		end
	end
	
	if ( forceEnd ) then
		return
	end
	
	if ( not exports.common:isPlayerServerAdmin( localPlayer ) ) then
		return
	end
	
	local cctv = { }
	
	if ( selectedCCTV ) then
		cctv = cctvs[ selectedCCTV ]
		
		if ( not cctv ) then
			return
		end
	else
		local x, y, z = getElementPosition( localPlayer )
		local interior, dimension = getElementInterior( localPlayer ), getElementDimension( localPlayer )
		
		cctv.pos_x, cctv.pos_y, cctv.pos_z = x, y, z
		cctv.rot_x, cctv.rot_y, cctv.rot_z = 0, 0, getPedRotation( localPlayer )
		cctv.interior, cctv.dimension = interior, dimension
	end
	
	cctv.rot_x = cctv.rot_x == -0 and 0 or cctv.rot_x
	cctv.rot_y = cctv.rot_y == -0 and 0 or cctv.rot_y
	cctv.rot_z = cctv.rot_z == -0 and 0 or cctv.rot_z
	
	cctv.pos_x = math.floor( cctv.pos_x * 100 ) / 100
	cctv.pos_y = math.floor( cctv.pos_y * 100 ) / 100
	cctv.pos_z = math.floor( cctv.pos_z * 100 ) / 100
	cctv.rot_x = math.floor( cctv.rot_x * 100 ) / 100
	cctv.rot_y = math.floor( cctv.rot_y * 100 ) / 100
	cctv.rot_z = math.floor( cctv.rot_z * 100 ) / 100
	
	if ( isElement( cctvManager.window ) ) then
		guiSetVisible( cctvManager.window, false )
		showCursor( false )
	end
	
	guiSetInputEnabled( true )
	
	cctvEdit.window = guiCreateWindow( ( screenWidth - 306 ) / 2, ( screenHeight - 422 ) / 2, 306, 431, "CCTV Editor", false)
	guiWindowSetSizable( cctvEdit.window, false )
	
	cctvEdit.label.name = guiCreateLabel( 10, 31, 226, 15, "Name", false, cctvEdit.window )
	cctvEdit.edit.name = guiCreateEdit( 10, 56, 286, 27, cctv.name or "", false, cctvEdit.window )
	cctvEdit.label.position = guiCreateLabel( 10, 93, 226, 15, "Position", false, cctvEdit.window )
	cctvEdit.edit.x = guiCreateEdit( 10, 118, 89, 27, cctv.pos_x, false, cctvEdit.window )
	setElementData( cctvEdit.edit.x, "cctv:gui:numberonly", true, false )
	cctvEdit.edit.y = guiCreateEdit( 109, 118, 89, 27, cctv.pos_y, false, cctvEdit.window )
	setElementData( cctvEdit.edit.y, "cctv:gui:numberonly", true, false )
	cctvEdit.edit.z = guiCreateEdit( 208, 118, 89, 27, cctv.pos_z, false, cctvEdit.window )
	setElementData( cctvEdit.edit.z, "cctv:gui:numberonly", true, false )
	cctvEdit.label.rotation = guiCreateLabel( 10, 155, 226, 15, "Rotation", false, cctvEdit.window )
	cctvEdit.edit.rx = guiCreateEdit( 10, 180, 89, 27, cctv.rot_x, false, cctvEdit.window )
	setElementData( cctvEdit.edit.rx, "cctv:gui:numberonly", true, false )
	cctvEdit.edit.ry = guiCreateEdit( 109, 180, 89, 27, cctv.rot_y, false, cctvEdit.window )
	setElementData( cctvEdit.edit.ry, "cctv:gui:numberonly", true, false )
	cctvEdit.edit.rz = guiCreateEdit( 208, 180, 89, 27, cctv.rot_z, false, cctvEdit.window )
	setElementData( cctvEdit.edit.rz, "cctv:gui:numberonly", true, false )
	cctvEdit.label.interior = guiCreateLabel( 10, 217, 89, 15, "Interior", false, cctvEdit.window )
	cctvEdit.edit.interior = guiCreateEdit( 10, 242, 89, 27, cctv.interior, false, cctvEdit.window )
	setElementData( cctvEdit.edit.interior, "cctv:gui:numberonly", true, false )
	cctvEdit.label.dimension = guiCreateLabel( 109, 217, 89, 15, "Dimension", false, cctvEdit.window )
	cctvEdit.edit.dimension = guiCreateEdit( 109, 242, 89, 27, cctv.dimension, false, cctvEdit.window )
	setElementData( cctvEdit.edit.dimension, "cctv:gui:numberonly", true, false )
	cctvEdit.label.model = guiCreateLabel( 208, 217, 89, 15, "Model ID", false, cctvEdit.window )
	cctvEdit.edit.model = guiCreateEdit( 208, 242, 89, 27, cctv.model_id or options.defaultModel, false, cctvEdit.window )
	setElementData( cctvEdit.edit.model, "cctv:gui:numberonly", true, false )
	cctvEdit.button.proceed = guiCreateButton( 10, 279, 287, 28, ( cctv.name and "Update" or "Create" ) .. " Camera", false, cctvEdit.window )
	cctvEdit.button.delete = guiCreateButton( 10, 317, 287, 28, "Delete Camera", false, cctvEdit.window )
	cctvEdit.button.toggle = guiCreateButton( 10, 355, 287, 28, "Toggle Input", false, cctvEdit.window )
	cctvEdit.button.cancel = guiCreateButton( 10, 393, 287, 28, "Cancel", false, cctvEdit.window )
	
	if ( not cctv.name ) then
		guiSetEnabled( cctvEdit.button.delete, false )
		
		cctvObject = createObject( options.defaultModel, cctv.pos_x, cctv.pos_y, cctv.pos_z, cctv.rot_x, cctv.rot_y, cctv.rot_z )
		setElementInterior( cctvObject, cctv.interior )
		setElementDimension( cctvObject, cctv.dimension )
		setElementAlpha( cctvObject, 125 )
		setElementCollisionsEnabled( cctvObject, false )
	else
		cctvObject = createObject( cctv.model_id, cctv.pos_x, cctv.pos_y, cctv.pos_z, cctv.rot_x, cctv.rot_y, cctv.rot_z )
		setElementInterior( cctvObject, cctv.interior )
		setElementDimension( cctvObject, cctv.dimension )
		setElementAlpha( cctvObject, 125 )
		setElementCollisionsEnabled( cctvObject, false )
		
		if ( isElement( cctvs[ selectedCCTV ].object ) ) then
			setElementAlpha( cctvs[ selectedCCTV ].object, 0 )
		end
		
		addEventHandler( "onClientGUIClick", cctvEdit.button.delete,
			function( )
				triggerServerEvent( "cctv:edit", localPlayer, selectedCCTV, false )
			end, false
		)
	end
	
	local function updateClientObject( )
		if ( getElementData( source, "cctv:gui:numberonly" ) ) then
			local inputText = guiGetText( source )
			local changedText
			
			if ( not tonumber( inputText ) ) then
				local sign = ""
				
				if ( inputText:sub( 1, 1 ) == '-' ) then
					sign = '-'
				end
				
				changedText = inputText:gsub( "[^%.%d]", "" )
				
				local numberParts = split( changedText, string.byte( '.' ) )
				
				if ( #numberParts > 0 ) then
					if ( #numberParts > 1 ) then
						local decimalPart = table.concat( numberParts, '', 2 )
						
						if ( decimalPart == "" ) then
							changedText = numberParts[ 1 ]
						else
							changedText = numberParts[ 1 ] .. '.' .. decimalPart
						end
					else
						changedText = numberParts[ 1 ]
					end
				end
				
				changedText = sign .. changedText
			end
			
			if ( changedText ) and ( changedText ~= inputText ) then
				guiSetText( source, changedText )
			end
		end
		
		if ( isElement( cctvObject ) ) then
			setElementModel( cctvObject, tonumber( guiGetText( cctvEdit.edit.model ) ) or options.defaultModel )
			setElementInterior( cctvObject, tonumber( guiGetText( cctvEdit.edit.interior ) ) or 0, tonumber( guiGetText( cctvEdit.edit.x ) ) or 0, tonumber( guiGetText( cctvEdit.edit.y ) ) or 0, tonumber( guiGetText( cctvEdit.edit.z ) ) or 0 )
			setElementDimension( cctvObject, tonumber( guiGetText( cctvEdit.edit.dimension ) ) or 0 )
			setElementRotation( cctvObject, tonumber( guiGetText( cctvEdit.edit.rx ) ) or 0, tonumber( guiGetText( cctvEdit.edit.ry ) ) or 0, tonumber( guiGetText( cctvEdit.edit.rz ) ) or 0 )
		end
	end
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.x, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.y, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.z, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.rx, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.ry, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.rz, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.interior, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.dimension, updateClientObject )
	addEventHandler( "onClientGUIChanged", cctvEdit.edit.model, updateClientObject )
	
	local function updateEditValue( upOrDown )
		local value = tonumber( guiGetText( source ) )
		
		if ( value ) then
			local multiplier = ( ( getKeyState( "lshift" ) ) or ( getKeyState( "rshift" ) ) ) and options.multiplier.big or ( ( ( getKeyState( "lctrl" ) ) or ( getKeyState( "rctrl" ) ) ) and options.multiplier.small or options.multiplier.normal )
			guiSetText( source, upOrDown == 1 and value + multiplier or value - multiplier )
		end
	end
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.x, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.y, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.z, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.rx, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.ry, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.rz, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.interior, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.dimension, updateEditValue )
	addEventHandler( "onClientMouseWheel", cctvEdit.edit.model, updateEditValue )
	
	addEventHandler( "onClientGUIClick", cctvEdit.button.proceed,
		function( )
			local name = guiGetText( cctvEdit.edit.name )
			local x, y, z = tonumber( guiGetText( cctvEdit.edit.x ) ), tonumber( guiGetText( cctvEdit.edit.y ) ), tonumber( guiGetText( cctvEdit.edit.z ) )
			local rx, ry, rz = tonumber( guiGetText( cctvEdit.edit.rx ) ), tonumber( guiGetText( cctvEdit.edit.ry ) ), tonumber( guiGetText( cctvEdit.edit.rz ) )
			local interior, dimension = tonumber( guiGetText( cctvEdit.edit.interior ) ), tonumber( guiGetText( cctvEdit.edit.dimension ) )
			local model = tonumber( guiGetText( cctvEdit.edit.model ) )
			
			if ( name ) and ( name:len( ) > 0 ) then
				if ( x ) and ( y ) and ( z ) and ( rx ) and ( ry ) and ( rz ) and ( interior ) and ( dimension ) and ( model ) then
					if ( interior >= 0 ) and ( dimension >= 0 ) and ( interior <= 255 ) and ( dimension <= 65535 ) then
						local object = createObject( model, 0, 0, 0 )
						
						if ( isElement( object ) ) then
							destroyElement( object )
						else
							outputChatBox( "Some fields have invalid values. Please check your inputs.", 230, 95, 95 )
							return
						end
						
						triggerServerEvent( "cctv:edit", localPlayer, selectedCCTV, { x = x, y = y, z = z, rx = rx, ry = ry, rz = rz, interior = interior, dimension = dimension, model = model, name = name } )
					else
						outputChatBox( "Some fields have invalid values. Please check your inputs.", 230, 95, 95 )
					end
				else
					outputChatBox( "Some fields have invalid values. Please check your inputs.", 230, 95, 95 )
				end
			else
				outputChatBox( "Please enter some name for the CCTV camera.", 230, 95, 95 )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", cctvEdit.button.toggle,
		function( )
			guiSetInputEnabled( not guiGetInputEnabled( ) )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", cctvEdit.button.cancel,
		function( )
			showCCTVEdit( true )
		end, false
	)
end

addEvent( "admin:levelRemoved", true )
addEventHandler( "admin:levelRemoved", root,
	function( )
		showCCTVManager( true, true )
	end
)

addEvent( "cctv:success", true )
addEventHandler( "cctv:success", root,
	function( )
		showCCTVEdit( true, true )
	end
)

addEvent( "cctv:sync", true )
addEventHandler( "cctv:sync", root,
	function( serverCCTVs )
		cctvs = serverCCTVs
		
		tempIndexed = { }
		
		for id, data in pairs( cctvs ) do
			table.insert( tempIndexed, id )
		end
		
		table.sort( tempIndexed )
		
		indexedCCTVs = { }
		
		for _, id in ipairs( tempIndexed ) do
			table.insert( indexedCCTVs, cctvs[ id ] )
		end
		
		if ( isElement( cctvManager.window ) ) then
			guiGridListClear( cctvManager.cctvs )
			
			loadCCTVsToGridList( cctvs )
			
			if ( selectedCCTV ) and ( not cctvs[ selectedCCTV ] ) and ( isElement( cctvEdit.window ) ) then
				showCCTVEdit( true )
			end
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "cctv:ready", localPlayer )
	end
)

addCommandHandler( "cctveditor",
	function( cmd )
		showCCTVManager( true )
	end
)
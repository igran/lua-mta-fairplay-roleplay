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
	combobox = { },
    button = { },
    label = { },
    edit = { }
}

local cctvLocation = { }

local options = {
	multiplier = {
		small = 0.1,
		normal = 1,
		big = 5
	},
	models = {
		{ model = 2921 },
		{ model = 1616 },
		{ model = 1886 },
		{ model = 1622 }
	}
}

options.defaultModel = options.models[ 1 ].model

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
	
	if ( forceEnd ) or ( isMonitoring ) or ( not exports.common:isPlayerServerAdmin( localPlayer ) ) then
		return
	end
	
	showCursor( true )
	
	cctvManager.window = guiCreateWindow( ( screenWidth - 493 ) / 2, ( screenHeight - 470 ) / 2, 493, 509, "CCTV Manager", false )
	guiWindowSetSizable( cctvManager.window, false )
	
	cctvManager.cctvs = guiCreateGridList( 10, 26, 473, 315, false, cctvManager.window )
	guiGridListAddColumn( cctvManager.cctvs, "ID", 0.1 )
	guiGridListAddColumn( cctvManager.cctvs, "Name", 0.4 )
	guiGridListAddColumn( cctvManager.cctvs, "Location", 0.4 )
	
	loadCCTVsToGridList( cctvs )
	
	cctvManager.button.edit = guiCreateButton( 10, 351, 473, 29, "Edit Camera", false, cctvManager.window )
	guiSetEnabled( cctvManager.button.edit, false )
	cctvManager.button.watch = guiCreateButton( 10, 390, 473, 29, "Watch Camera", false, cctvManager.window )
	guiSetEnabled( cctvManager.button.watch, false )
	cctvManager.button.create = guiCreateButton( 10, 429, 473, 29, "Create Camera", false, cctvManager.window )
	cctvManager.button.close = guiCreateButton( 10, 468, 473, 29, "Close Window", false, cctvManager.window )
	
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
	
	addEventHandler( "onClientGUIClick", cctvManager.button.watch,
		function( )
			local row, column = guiGridListGetSelectedItem( cctvManager.cctvs )
			
			if ( row ~= -1 ) and ( column ~= -1 ) then
				showCCTVManager( true, true )
				
				triggerServerEvent( "cctv:watch", localPlayer, nil, 1, row + 1 )
			end
		end, false
	)
	
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
				guiSetEnabled( cctvManager.button.watch, true )
			else
				guiSetEnabled( cctvManager.button.edit, false )
				guiSetEnabled( cctvManager.button.watch, false )
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
	
	if ( forceEnd ) or ( isMonitoring ) or ( not exports.common:isPlayerServerAdmin( localPlayer ) ) then
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
	cctvEdit.combobox.model = guiCreateComboBox( 208, 242, 89, #options.models * 20 + 20, "...", false, cctvEdit.window )
	
	for _, data in ipairs( options.models ) do
		local index = guiComboBoxAddItem( cctvEdit.combobox.model, data.model .. ( ( data.note and data.note:len( ) > 0 ) and "(" .. data.note .. ")" or "" ) )
		
		if ( ( cctv.model_id ) and ( cctv.model_id == data.model ) ) or ( ( not cctv.model_id ) and ( options.defaultModel == data.model ) ) then
			guiComboBoxSetSelected( cctvEdit.combobox.model, index )
		end
	end
	
	cctvEdit.button.proceed = guiCreateButton( 10, 279, 287, 28, ( cctv.name and "Update" or "Create" ) .. " Camera", false, cctvEdit.window )
	cctvEdit.button.delete = guiCreateButton( 10, 317, 287, 28, "Delete Camera", false, cctvEdit.window )
	cctvEdit.button.toggle = guiCreateButton( 10, 355, 287, 28, "Toggle Input", false, cctvEdit.window )
	cctvEdit.button.cancel = guiCreateButton( 10, 393, 287, 28, "Cancel", false, cctvEdit.window )
	
	cctvObject = createObject( cctv.name and cctv.model_id or options.defaultModel, cctv.pos_x, cctv.pos_y, cctv.pos_z, cctv.rot_x, cctv.rot_y, cctv.rot_z )
	setElementInterior( cctvObject, cctv.interior )
	setElementDimension( cctvObject, cctv.dimension )
	setElementAlpha( cctvObject, 165 )
	setElementCollisionsEnabled( cctvObject, false )
	
	if ( not cctv.name ) then
		guiSetEnabled( cctvEdit.button.delete, false )
	else
		if ( isElement( cctv.object ) ) then
			setElementAlpha( cctv.object, 0 )
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
	
	addEventHandler( "onClientGUIComboBoxAccepted", cctvEdit.combobox.model,
		function( )
			if ( isElement( cctvObject ) ) then
				local selectedIndex = guiComboBoxGetSelected( cctvEdit.combobox.model )
				local model = tonumber( guiComboBoxGetItemText( cctvEdit.combobox.model, selectedIndex ) )
				
				setElementModel( cctvObject, model or options.defaultModel )
			end
		end
	)
	
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
	
	addEventHandler( "onClientGUIClick", cctvEdit.button.proceed,
		function( )
			local name = guiGetText( cctvEdit.edit.name )
			local x, y, z = tonumber( guiGetText( cctvEdit.edit.x ) ), tonumber( guiGetText( cctvEdit.edit.y ) ), tonumber( guiGetText( cctvEdit.edit.z ) )
			local rx, ry, rz = tonumber( guiGetText( cctvEdit.edit.rx ) ), tonumber( guiGetText( cctvEdit.edit.ry ) ), tonumber( guiGetText( cctvEdit.edit.rz ) )
			local interior, dimension = tonumber( guiGetText( cctvEdit.edit.interior ) ), tonumber( guiGetText( cctvEdit.edit.dimension ) )
			local selectedIndex = guiComboBoxGetSelected( cctvEdit.combobox.model )
			
			if ( name ) and ( name:len( ) > 0 ) then
				if ( x ) and ( y ) and ( z ) and ( rx ) and ( ry ) and ( rz ) and ( interior ) and ( dimension ) and ( selectedIndex ) then
					local model, found = tonumber( guiComboBoxGetItemText( cctvEdit.combobox.model, selectedIndex ) )
					
					for _, data in ipairs( options.models ) do
						if ( data.model == model ) then
							found = true
							break
						end
					end
					
					if ( found ) and ( interior >= 0 ) and ( dimension >= 0 ) and ( interior <= 255 ) and ( dimension <= 65535 ) then
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
			local inputState = guiGetInputEnabled( )
			
			guiSetInputEnabled( not inputState )
			toggleAllControls( inputState, true, false )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", cctvEdit.button.cancel,
		function( )
			showCCTVEdit( true )
		end, false
	)
end

function showCCTVLocations( forceClose, forceEnd )
	if ( isElement( cctvLocation.location ) ) then
		destroyElement( cctvLocation.location )
		destroyElement( cctvLocation.name )
		
		if ( forceClose ) then
			return
		end
	end
	
	if ( forceEnd ) or ( not isMonitoring ) then
		return
	end
	
	local inactiveAlpha = 0.35
	
	cctvLocation.location = guiCreateGridList( 1315, 733, 230, 230, false )
	guiGridListAddColumn( cctvLocation.location, "Location", 0.9 )
	guiSetAlpha( cctvLocation.location, inactiveAlpha )

	cctvLocation.name = guiCreateGridList( 1555, 733, 230, 230, false )
	guiGridListAddColumn( cctvLocation.name, "ID", 0.15 )
	guiGridListAddColumn( cctvLocation.name, "Name", 0.75 )
	guiSetAlpha( cctvLocation.name, inactiveAlpha )
	
	local indexHolder = { }
	local locations = { }
	
	for _, cctv in ipairs( indexedCCTVs ) do
		if ( not indexHolder[ cctv.location ] ) then
			table.insert( locations, { cctvs = { }, location = cctv.location, count = 1 } )
			table.insert( locations[ #locations ].cctvs, { name = cctv.name, id = cctv.id } )
			
			indexHolder[ cctv.location ] = #locations
		else
			table.insert( locations[ indexHolder[ cctv.location ] ].cctvs, { name = cctv.name, id = cctv.id } )
			locations[ indexHolder[ cctv.location ] ].count = locations[ indexHolder[ cctv.location ] ].count + 1
		end
	end
	
	for _, data in ipairs( locations ) do
		local row = guiGridListAddRow( cctvLocation.location )
		
		guiGridListSetItemText( cctvLocation.location, row, 1, data.location .. " (" .. data.count .. ")", false, false )
	end
	
	guiGridListSetSelectedItem( cctvLocation.location, 0, 1 )
	
	local function alphaReact( )
		guiSetAlpha( source, eventName == "onClientMouseEnter" and 0.75 or inactiveAlpha )
	end
	addEventHandler( "onClientMouseEnter", cctvLocation.location, alphaReact )
	addEventHandler( "onClientMouseEnter", cctvLocation.name, alphaReact )
	addEventHandler( "onClientMouseLeave", cctvLocation.location, alphaReact )
	addEventHandler( "onClientMouseLeave", cctvLocation.name, alphaReact )
	
	local function addNames( )
		local location = guiGridListGetSelectedItem( cctvLocation.location )
		
		if ( location ~= -1 ) then
			location = guiGridListGetItemText( cctvLocation.location, location, 1 )
			location = indexHolder[ location:sub( 0, -location:reverse( ):find( "%(" ) - 2 ) ]
			
			if ( location ) then
				location = locations[ location ]
				
				if ( location ) then
					guiGridListClear( cctvLocation.name )
					
					for _, cctv in ipairs( location.cctvs ) do
						local row = guiGridListAddRow( cctvLocation.name )
						
						guiGridListSetItemText( cctvLocation.name, row, 1, cctv.id, false, true )
						guiGridListSetItemText( cctvLocation.name, row, 2, cctv.name, false, false )
					end
				end
			end
		end
	end
	addEventHandler( "onClientGUIClick", cctvLocation.location, addNames, false )
	
	addNames( )
	
	addEventHandler( "onClientGUIClick", cctvLocation.name,
		function( )
			local row = guiGridListGetSelectedItem( cctvLocation.name )
			
			if ( row ~= -1 ) then
				local id = tonumber( guiGridListGetItemText( cctvLocation.name, row, 1 ) )
				local index
				
				for indexedCCTV, data in ipairs( indexedCCTVs ) do
					if ( data.id == id ) then
						index = indexedCCTV
						break
					end
				end
				
				goToCamera( index )
			end
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
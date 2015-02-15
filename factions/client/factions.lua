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
local factionSelector = {
	button = { }
}

local factions = { }

function getFactionByID( id )
	for index, faction in pairs( factions ) do
		if ( faction.id == id ) then
			return faction, index
		end
	end
	
	return false
end

function showFactionMenu( forceClose )
	--todo
end
--[[
--massive
GUIEditor = {
    tab = {},
    label = {},
    tabpanel = {},
    edit = {},
    gridlist = {},
    window = {},
    button = {},
    memo = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        GUIEditor.window[1] = guiCreateWindow(455, 310, 966, 542, "Faction name", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.tabpanel[1] = guiCreateTabPanel(10, 29, 946, 461, false, GUIEditor.window[1])

        GUIEditor.tab[1] = guiCreateTab("Members", GUIEditor.tabpanel[1])

        GUIEditor.gridlist[1] = guiCreateGridList(10, 10, 788, 415, false, GUIEditor.tab[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Name", 0.1)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Rank", 0.1)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Wage", 0.1)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Leader", 0.1)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Status", 0.1)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Duty", 0.1)
        GUIEditor.button[1] = guiCreateButton(808, 10, 128, 28, "Kick member", false, GUIEditor.tab[1])
        GUIEditor.button[2] = guiCreateButton(808, 48, 128, 28, "Set rank", false, GUIEditor.tab[1])
        GUIEditor.button[3] = guiCreateButton(808, 86, 128, 28, "Toggle leader", false, GUIEditor.tab[1])

        GUIEditor.tab[2] = guiCreateTab("Notes", GUIEditor.tabpanel[1])

        GUIEditor.tabpanel[2] = guiCreateTabPanel(10, 10, 926, 417, false, GUIEditor.tab[2])

        GUIEditor.tab[3] = guiCreateTab("Faction note", GUIEditor.tabpanel[2])

        GUIEditor.memo[1] = guiCreateMemo(10, 10, 906, 333, "", false, GUIEditor.tab[3])

        GUIEditor.button[4] = guiCreateButton(677, 348, 167, 20, "", false, GUIEditor.memo[1])

        GUIEditor.button[5] = guiCreateButton(10, 353, 906, 30, "Save note", false, GUIEditor.tab[3])

        GUIEditor.tab[4] = guiCreateTab("Leader note", GUIEditor.tabpanel[2])


        GUIEditor.tab[5] = guiCreateTab("Vehicles", GUIEditor.tabpanel[1])
        GUIEditor.tab[6] = guiCreateTab("Ranks", GUIEditor.tabpanel[1])

        GUIEditor.edit[1] = guiCreateEdit(10, 37, 212, 27, "", false, GUIEditor.tab[6])
        GUIEditor.edit[2] = guiCreateEdit(232, 37, 78, 27, "", false, GUIEditor.tab[6])
        GUIEditor.label[1] = guiCreateLabel(10, 12, 212, 15, "Rank name", false, GUIEditor.tab[6])
        GUIEditor.label[2] = guiCreateLabel(232, 12, 78, 15, "Rank wage", false, GUIEditor.tab[6])
        GUIEditor.label[3] = guiCreateLabel(399, 12, 212, 15, "Rank name", false, GUIEditor.tab[6])
        GUIEditor.edit[3] = guiCreateEdit(399, 37, 212, 27, "", false, GUIEditor.tab[6])
        GUIEditor.label[4] = guiCreateLabel(621, 12, 78, 15, "Rank wage", false, GUIEditor.tab[6])
        GUIEditor.edit[4] = guiCreateEdit(621, 37, 78, 27, "", false, GUIEditor.tab[6])


        GUIEditor.label[5] = guiCreateLabel(10, 500, 760, 15, "MOTD: Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed posuere interdum sem. Quisque ligula eros ullamcorper quis.", false, GUIEditor.window[1])
        guiSetFont(GUIEditor.label[5], "default-bold-small")
        GUIEditor.button[6] = guiCreateButton(827, 503, 129, 29, "Close window", false, GUIEditor.window[1])    
    end
)
]]

function showFactionSelector( forceClose )
	if ( isElement( factionSelector.window ) ) then
		destroyElement( factionSelector.window )
		showCursor( false )
		
		if ( forceClose ) then
			return
		end
	end
	
	if ( not exports.common:isPlayerPlaying( localPlayer ) ) then
		return
	end
	
	showCursor( true )
	
	factionSelector.window = guiCreateWindow( ( screenWidth - 412 ) / 2, ( screenHeight - 392 ) / 2, 412, 392, "Factions", false )
	guiWindowSetSizable( factionSelector.window, false )

	factionSelector.factions = guiCreateGridList( 10, 28, 392, 235, false, factionSelector.window )
	guiGridListAddColumn( factionSelector.factions, "ID", 0.1 )
	guiGridListAddColumn( factionSelector.factions, "Name", 0.6 )
	guiGridListAddColumn( factionSelector.factions, "Type", 0.25 )
	
	if ( exports.common:count( factions ) == 0 ) then
		local row = guiGridListAddRow( factionSelector.factions )
		
		guiGridListSetItemText( factionSelector.factions, row, 2, "You are not in any faction", true, false )
	else
		local defaultFaction = exports.common:getPlayerDefaultFaction( localPlayer )
		local faction = ( defaultFaction and defaultFaction > 0 ) and getFactionByID( defaultFaction ) or false
		
		if ( faction ) then
			local row = guiGridListAddRow( factionSelector.factions )
			
			guiGridListSetItemText( factionSelector.factions, row, 2, "Default faction", true, false )
			
			local row = guiGridListAddRow( factionSelector.factions )
			
			guiGridListSetItemText( factionSelector.factions, row, 1, faction.id, false, true )
			guiGridListSetItemText( factionSelector.factions, row, 2, faction.name, false, false )
			guiGridListSetItemText( factionSelector.factions, row, 3, getFactionType( faction.type ), false, false )
			
			if ( exports.common:count( factions ) > 1 ) then
				local row = guiGridListAddRow( factionSelector.factions )
				
				guiGridListSetItemText( factionSelector.factions, row, 2, "Alternate factions", true, false )
			end
		end
		
		for _, faction in pairs( factions ) do
			if ( defaultFaction ~= faction.id ) then
				local row = guiGridListAddRow( factionSelector.factions )
				
				guiGridListSetItemText( factionSelector.factions, row, 1, tostring( faction.id ), false, true )
				guiGridListSetItemText( factionSelector.factions, row, 2, tostring( faction.name ), false, false )
				guiGridListSetItemText( factionSelector.factions, row, 3, getFactionType( faction.type ), false, false )
			end
		end
	end
	
	addEventHandler( "onClientGUIClick", factionSelector.factions,
		function( )
			local row, column = guiGridListGetSelectedItem( factionSelector.factions )
			if ( row ~= -1 ) and ( column ~= -1 ) then
				if ( row == 1 ) then
					guiSetEnabled( factionSelector.button.set, false )
				elseif ( row > 1 ) then
					guiSetEnabled( factionSelector.button.set, true )
				end
				
				if ( row ~= -1 ) then
					guiSetEnabled( factionSelector.button.open, true )
				else
					guiSetEnabled( factionSelector.button.set, false )
				end
			end
		end, false
	)
	
	factionSelector.button.open = guiCreateButton( 10, 273, 392, 29, "Open faction panel", false, factionSelector.window )
	guiSetEnabled( factionSelector.button.open, false )
	
	factionSelector.button.set = guiCreateButton( 10, 312, 392, 29, "Set as main faction", false, factionSelector.window )
	guiSetEnabled( factionSelector.button.set, false )
	
	factionSelector.button.close = guiCreateButton( 10, 351, 392, 29, "Close window", false, factionSelector.window )
	
	local function openFactionMenu( )
		local row, column = guiGridListGetSelectedItem( factionSelector.factions )
		if ( row ~= -1 ) and ( column ~= -1 ) then
			local factionID = guiGridListGetItemText( factionSelector.factions, row, 1 )
				  factionID = tonumber( factionID ) or false
			
			if ( factionID ) then
				showFactionMenu( factionID )
			else
				outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
			end
		else
			outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
		end
	end
	addEventHandler( "onClientGUIDoubleClick", factionSelector.factions, openFactionMenu )
	addEventHandler( "onClientGUIClick", factionSelector.button.open, openFactionMenu )
	
	addEventHandler( "onClientGUIClick", factionSelector.button.set,
		function( )
			local row, column = guiGridListGetSelectedItem( factionSelector.factions )
			if ( row ~= -1 ) and ( column ~= -1 ) then
				local factionID = guiGridListGetItemText( factionSelector.factions, row, 1 )
					  factionID = tonumber( factionID ) or false
				
				if ( factionID ) then
					triggerServerEvent( "factions:set_as_main", localPlayer, factionID )
				else
					outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
				end
			else
				outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", factionSelector.button.close,
		function( )
			showFactionSelector( true )
		end, false
	)
end

addEvent( "factions:update", true )
addEventHandler( "factions:update", root,
	function( serverFactions )
		if ( exports.common:count( serverFactions ) == 0 ) then
			factions = { }
		elseif ( exports.common:count( serverFactions ) == 1 ) then
			serverFactions = serverFactions[ 1 ]
			local faction, index = getFactionByID( serverFactions.id )
			
			if ( faction ) then
				factions[ index ] = serverFactions
			else
				table.insert( factions, serverFactions )
			end
		elseif ( exports.common:count( serverFactions ) > 1 ) then
			factions = serverFactions
		end
		
		if ( isElement( factionSelector.window ) ) then
			showFactionSelector( )
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "F3", "down",
			function( )
				showFactionSelector( true )
			end
		)
	end
)
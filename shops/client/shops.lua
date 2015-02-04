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
local shopWindow = {
	button = { },
	section = { }
}
local shop

function getTabIndex( tab )
	if ( isElement( tab ) ) then
		local tabPanel = getElementParent( tab )

		for index, child in ipairs( getElementChildren( tabPanel ) ) do
			if ( tab == child ) then
				return index
			end
		end
	end

	return false
end

function showShopWindow( forceClose )
	if ( isElement( shopWindow.window ) ) then
		destroyElement( shopWindow.window );
		showCursor( false )

		if ( forceClose ) then
			return
		end
	end

	if ( not shop ) then
		return
	end

	showCursor( true )

	shopWindow.window = guiCreateWindow( ( screenWidth - 600 ) / 2, ( screenHeight - 500 ) / 2, 600, 500, "Shop of " .. shop.name:gsub( "_", " " ), false )
	guiWindowSetSizable( shopWindow.window, false )

	local function purchaseItem( gridList, currentTab )
		if ( isElement( gridList ) ) then
			local row, column = guiGridListGetSelectedItem( gridList )

			if ( row ~= -1 ) and ( column ~= -1 ) then
				guiSetEnabled( shopWindow.window, false )
				triggerServerEvent( "shops:purchase", localPlayer, shop.id, getTabIndex( currentTab ), guiGridListGetItemText( gridList, row, 1 ) )
			else
				outputChatBox( "Please select a product from the list.", 230, 95, 95 )
			end
		end
	end
	
	shopWindow.tabPanel = guiCreateTabPanel( 5, 25, 600 - 5 * 2, 500 - ( 25 + 5 * 6 ) * 2, false, shopWindow.window )

	for index, section in ipairs( shop.sections ) do
		shopWindow.section[ index ] = { }
		shopWindow.section[ index ].tab = guiCreateTab( section.name, shopWindow.tabPanel )
		shopWindow.section[ index ].gridlist = guiCreateGridList( 5, 5, 600 - 5 * 5 - 4, ( 500 - ( 25 + 5 * 10 ) * 2 ) + 5, false, shopWindow.section[ index ].tab )

		guiGridListAddColumn( shopWindow.section[ index ].gridlist, "Index", 0.1 )
		guiGridListAddColumn( shopWindow.section[ index ].gridlist, "Name", 0.225 )
		guiGridListAddColumn( shopWindow.section[ index ].gridlist, "Description", 0.4 )
		guiGridListAddColumn( shopWindow.section[ index ].gridlist, "Price ($)", 0.125 )
		guiGridListAddColumn( shopWindow.section[ index ].gridlist, "Item ID", 0.1 )

		for itemIndex, item in ipairs( section.items ) do
			local row = guiGridListAddRow( shopWindow.section[ index ].gridlist )

			guiGridListSetItemText( shopWindow.section[ index ].gridlist, row, 1, itemIndex, false, true )
			guiGridListSetItemText( shopWindow.section[ index ].gridlist, row, 2, exports.items:getItemName( item.id ), false, false )
			guiGridListSetItemText( shopWindow.section[ index ].gridlist, row, 3, exports.items:getItemDescription( item.id ), false, false )
			guiGridListSetItemText( shopWindow.section[ index ].gridlist, row, 4, "$" .. exports.common:formatMoney( item.price ), false, true )
			guiGridListSetItemText( shopWindow.section[ index ].gridlist, row, 5, item.id, false, false )
		end

		addEventHandler( "onClientGUIDoubleClick", shopWindow.section[ index ].gridlist,
			function( )
				purchaseItem( source, getElementParent( source ) )
			end, false
		)
	end
	
	shopWindow.button.purchase = guiCreateButton( 5, 500 - ( ( 25 + 5 * 2 ) * 2 ), 600 - 5 * 2, 25, "Purchase", false, shopWindow.window )
	shopWindow.button.close = guiCreateButton( 5, 500 - ( 25 + 5 * 2 ), 600 - 5 * 2, 25, "Close window", false, shopWindow.window )

	addEventHandler( "onClientGUIClick", shopWindow.button.purchase,
		function( )
			local currentTab = guiGetSelectedTab( shopWindow.tabPanel )
			local gridList = getElementChildren( currentTab )[ 1 ]

			purchaseItem( gridList, currentTab )
		end, false
	)

	addEventHandler( "onClientGUIClick", shopWindow.button.close,
		function( )
			showShopWindow( true )
		end, false
	)
end

addEvent( "shops:open", true )
addEventHandler( "shops:open", root,
	function( shopData )
		shop = shopData
		
		showShopWindow( )
	end
)

addEvent( "shops:enable_gui", true )
addEventHandler( "shops:enable_gui", root,
	function( shopData )
		if ( isElement( shopWindow.window ) ) then
			
		end
	end
)
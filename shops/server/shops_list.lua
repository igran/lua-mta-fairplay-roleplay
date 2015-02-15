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

shopList = {
	{
		name = "General Store",
		sections = {
			{
				name = "Commons",
				items = {
					{
						id = 1,
						price = 2
					}
				}
			},
			{
				name = "Electronics",
				items = {
					{
						id = 2,
						price = 2
					}
				}
			}
		},
		skins = {
			287
		}
	}
}

function getShopList( type )
	return type and shopList[ type ] or shopList
end

function getShopItem( shopID, itemID, sectionID )
	local shop = getShopList( shopID )
	
	if ( shop ) then
		local searchFrom = shop.sections
		
		if ( sectionID ) then
			searchFrom = { shop.sections[ sectionID ] }
		end
		
		for _, section in ipairs( searchFrom ) do
			for index, item in ipairs( section.items ) do
				if ( item.id == itemID ) then
					return item
				end
			end
		end
	end
	
	return false
end
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

local imports = {
	factions = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "name", type = "varchar", length = 50, default = "" },
		{ name = "type", type = "smallint", length = 3, default = 1, is_unsigned = true },
		{ name = "motd", type = "text" },
		{ name = "note", type = "text" },
		{ name = "leader_note", type = "text" },
		{ name = "ranks", type = "text" },
		{ name = "modified", type = "timestamp", default = "CURRENT_TIMESTAMP" },
		{ name = "created", type = "timestamp", default = "0000-00-00 00:00:00" }
	},
	factions_characters = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "character_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "faction_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "rank", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "is_leader", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "modified", type = "timestamp", default = "CURRENT_TIMESTAMP" },
		{ name = "created", type = "timestamp", default = "0000-00-00 00:00:00" }
	}
}

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		for tableName, tableData in pairs( imports ) do
			exports.database:modify_table( tableName, tableData )
			exports.database:verify_table( tableName )
		end
	end
)
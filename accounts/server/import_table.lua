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
	accounts = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "username", type = "varchar", length = 25, default = "" },
		{ name = "password", type = "varchar", length = 1000, default = "" },
		{ name = "level", type = "tinyint", length = 3, default = 0 },
		{ name = "tutorial", type = "tinyint", length = 1, default = 0 },
		{ name = "tutorial_date", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "is_deleted", type = "tinyint", length = 1, default = 0 },
		{ name = "last_login", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "last_action", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "last_ip", type = "varchar", length = 128, default = "0.0.0.0" },
		{ name = "last_serial", type = "varchar", length = 32, default = "13371337133713371337133713371337" },
		{ name = "salt", type = "varchar", length = 1000, default = "" },
		{ name = "modified", type = "timestamp", default = "CURRENT_TIMESTAMP" },
		{ name = "created", type = "timestamp", default = "0000-00-00 00:00:00" }
	},
	characters = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "account", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "skin_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "name", type = "varchar", length = 255, default = "" },
		{ name = "gender", type = "varchar", length = 255, default = "" },
		{ name = "skin_color", type = "varchar", length = 255, default = "" },
		{ name = "default_faction", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "date_of_birth", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "origin", type = "varchar", length = 255, default = "" },
		{ name = "look", type = "varchar", length = 255, default = "" },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rotation", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "health", type = "smallint", length = 3, default = 100, is_unsigned = true },
		{ name = "armor", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "cash", type = "bigint", length = 18, default = 0, is_unsigned = true },
		{ name = "bank", type = "bigint", length = 18, default = 0, is_unsigned = true },
		{ name = "is_dead", type = "smallint", length = 1, default = 0, is_unsigned = true },
		{ name = "cause_of_death", type = "text" },
		{ name = "last_played", type = "timestamp", default = "0000-00-00 00:00:00" },
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
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
	cctv_cameras = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "name", type = "varchar", length = 50, default = "Interior" },
		{ name = "type", type = "tinyint", length = 2, default = 1 },
		{ name = "model_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rot_x", type = "float", default = 0 },
		{ name = "rot_y", type = "float", default = 0 },
		{ name = "rot_z", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "is_disabled", type = "tinyint", length = 1, default = 0 },
		{ name = "created_by", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "modified", type = "timestamp", default = "0000-00-00 00:00:00" },
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
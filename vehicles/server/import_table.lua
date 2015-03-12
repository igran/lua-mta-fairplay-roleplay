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
	vehicles = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "model_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rot_x", type = "float", default = 0 },
		{ name = "rot_y", type = "float", default = 0 },
		{ name = "rot_z", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "respawn_pos_x", type = "float", default = 0 },
		{ name = "respawn_pos_y", type = "float", default = 0 },
		{ name = "respawn_pos_z", type = "float", default = 0 },
		{ name = "respawn_rot_x", type = "float", default = 0 },
		{ name = "respawn_rot_y", type = "float", default = 0 },
		{ name = "respawn_rot_z", type = "float", default = 0 },
		{ name = "respawn_interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "respawn_dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "numberplate", type = "varchar", length = 10, default = "UNd3F1N3D" },
		{ name = "variant_1", type = "tinyint", length = 3, default = 255, is_unsigned = true },
		{ name = "variant_2", type = "tinyint", length = 3, default = 255, is_unsigned = true },
		{ name = "owner_id", type = "int", length = 11, default = 0 },
		{ name = "health", type = "smallint", length = 4, default = 1000, is_unsigned = true },
		{ name = "color", type = "varchar", length = 255, default = "[ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0], [ 0, 0, 0 ] ]" },
		{ name = "headlight_color", type = "varchar", length = 255, default = "[ [ 0, 0, 0 ] ]" },
		{ name = "headlight_state", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "door_states", type = "varchar", length = 255, default = "[ [ 0, 0, 0, 0, 0, 0 ] ]" },
		{ name = "panel_states", type = "varchar", length = 255, default = "[ [ 0, 0, 0, 0, 0, 0 ] ]" },
		{ name = "is_locked", type = "tinyint", length = 1, default = 1, is_unsigned = true },
		{ name = "is_engine_on", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_deleted", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_broken", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_bulletproof", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "model_set_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "created_by", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "modified", type = "timestamp", default = "CURRENT_TIMESTAMP" },
		{ name = "created", type = "timestamp", default = "0000-00-00 00:00:00" }
	},
	vehicles_model_sets = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "make", type = "varchar", length = 50, default = "GTA" },
		{ name = "model", type = "varchar", length = 50, default = "" },
		{ name = "year", type = "smallint", length = 4, default = 2004, is_unsigned = true },
		{ name = "price", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "gta_model_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "created_by", type = "int", length = 10, default = 0, is_unsigned = true },
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
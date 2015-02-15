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

interiorConfiguration = {
	inside = {
		{ x = 0, y = 0, z = 3, interior = 1, rotation = 0 }
	},
	type = {
		"House", "Rentable", "Government", "Business"
	}
}

function getInteriorConfiguration( )
	return interiorConfiguration
end

function getInteriorMarkerData( data, isEntrance )
	if ( isEntrance ) then
		return {
			x = data.pos_x,
			y = data.pos_y,
			z = data.pos_z,
			interior = data.interior,
			dimension = data.dimension,
			target_x = data.target_pos_x,
			target_y = data.target_pos_y,
			target_z = data.target_pos_z,
			target_interior = data.target_interior,
			target_dimension = data.id
		}
	else
		return {
			x = data.target_pos_x,
			y = data.target_pos_y,
			z = data.target_pos_z,
			interior = data.target_interior,
			dimension = data.id,
			target_x = data.pos_x,
			target_y = data.pos_y,
			target_z = data.pos_z,
			target_interior = data.interior,
			target_dimension = data.dimension
		}
	end
	
	return false
end
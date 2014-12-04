﻿function cleanString( string )
	while ( string:find( "  " ) ) do
		string:gsub( "  ", " " )
	end
	
	return string
end

function outputLocalActionMe( player, action )
	if ( exports.common:isPlayerPlaying( player ) ) then
		local x, y, z = getElementPosition( player )
		local affected = ""
		
		action = cleanString( action )
		
		for _, targetPlayer in ipairs( getElementsByType( "player" ) ) do
			local px, py, pz = getElementPosition( targetPlayer )
			local distance = getDistanceBetweenPoints3D( px, py, pz, x, y, z )
			
			if ( distance < 30 ) and ( getElementInterior( player ) == getElementInterior( targetPlayer ) ) and ( getElementDimension( player ) == getElementDimension( targetPlayer ) ) then
				outputChatBox( " *" .. exports.common:getRealPlayerName( player ) .. " " .. action, targetPlayer, 237, 116, 136, false )
			end
		end
	end
end
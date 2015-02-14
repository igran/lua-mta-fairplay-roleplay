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

function getPlayerMoney( player )
	return ( isElement( player ) and getElementData( player, "character:cash" ) ) and tonumber( getElementData( player, "character:cash" ) ) or 0
end

function setPlayerMoney( player, amount )
	if ( exports.common:isPlayerPlaying( player ) ) and ( tonumber( amount ) ) then
		return exports.security:modifyElementData( player, "character:cash", amount, false )
	end
	
	return false
end

function givePlayerMoney( player, amount )
	if ( exports.common:isPlayerPlaying( player ) ) and ( tonumber( amount ) ) then
		return exports.security:modifyElementData( player, "character:cash", getPlayerMoney( player ) + amount, false )
	end
	
	return false
end

function takePlayerMoney( player, amount )
	if ( exports.common:isPlayerPlaying( player ) ) and ( tonumber( amount ) ) then
		return exports.security:modifyElementData( player, "character:cash", getPlayerMoney( player ) - amount, false )
	end
	
	return false
end

function getPlayerBankMoney( player )
	return ( isElement( player ) and getElementData( player, "character:bank" ) ) and tonumber( getElementData( player, "character:bank" ) ) or 0
end

function setPlayerBankMoney( player, amount )
	if ( exports.common:isPlayerPlaying( player ) ) and ( tonumber( amount ) ) then
		return exports.security:modifyElementData( player, "character:bank", amount, false )
	end
	
	return false
end

function givePlayerBankMoney( player, amount )
	if ( exports.common:isPlayerPlaying( player ) ) and ( tonumber( amount ) ) then
		return exports.security:modifyElementData( player, "character:bank", getPlayerMoney( player ) + amount, false )
	end
	
	return false
end

function takePlayerBankMoney( player, amount )
	if ( exports.common:isPlayerPlaying( player ) ) and ( tonumber( amount ) ) then
		return exports.security:modifyElementData( player, "character:bank", getPlayerMoney( player ) - amount, false )
	end
	
	return false
end
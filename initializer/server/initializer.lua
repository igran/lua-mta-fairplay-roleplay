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

local threads, loadingTimer, isGlobalStart, startTick = { }
local loadedResources = 0
local resources = { "security", "database", "common", "messages", "accounts", "admin", "realism", "items", "inventory", "weapons", "chat", "bank", "vehicles", "interiors", "factions", "shops", "scoreboard", "superman", "cache" }
local isThreadedMode = true

local function resumeCoroutines( )
	for _, loadCoroutine in ipairs( threads ) do
		coroutine.resume( loadCoroutine )
	end
	
	if ( #resources ) and ( loadedResources >= #resources ) then
		threads = nil

		if ( isTimer( loadingTimer ) ) then
			killTimer( loadingTimer )
		end

		finishGlobalStart( )
	end
end

function finishGlobalStart( )
	if ( isGlobalStart ) then
		isGlobalStart = false

		outputDebugString( "Took " .. math.floor( getTickCount( ) - startTick ) .. " ms (average is " .. math.floor( ( getTickCount( ) - startTick ) / 1000 * 100 ) / 100 .. " seconds) to load all resources" .. ( isThreadedMode and " in threaded mode" or "" ) .. "." )
		
		return true
	end

	return false
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		startTick = getTickCount( )
		isGlobalStart = true

		local builder = getResourceFromName( "builder" )
		
		if ( getResourceState( builder ) ~= "running" ) then
			startResource( builder )
		end
		
		for _, resourceName in ipairs( resources ) do
			if ( threadedMode ) then
				local loadCoroutine = coroutine.create(
					function( resourceName )
						local resource = getResourceFromName( resourceName )
						
						if ( resource ) then
							exports.builder:load_resource( resourceName )
						end

						loadedResources = loadedResources and loadedResources + 1 or 1

						coroutine.yield( )
					end
				)
				coroutine.resume( loadCoroutine, resourceName )
				table.insert( threads, loadCoroutine )
			else
				local resource = getResourceFromName( resourceName )
				
				if ( resource ) then
					exports.builder:load_resource( resourceName )
				end
			end
		end

		if ( isThreadedMode ) then
			loadingTimer = setTimer( resumeCoroutines, 1000, 4 )
		else
			finishGlobalStart( )
		end
	end
)

addEventHandler( "onResourceStop", root,
	function( resource )
		if ( getResourceName( resource ) == "database" ) then
			for _, player in ipairs( getElementsByType( "player" ) ) do
				if ( exports.common:getAccountID( player ) ) then
					outputChatBox( "Server database module has stopped. Your account has been automatically limited to prevent any misuse of this action.", player, 230, 95, 95 )
				end
			end
		end
	end
)

addEventHandler( "onResourceStart", root,
	function( resource )
		if ( isGlobalStart ) then
			return
		end

		if ( getResourceName( resource ) == "database" ) then
			for _, player in ipairs( getElementsByType( "player" ) ) do
				if ( exports.common:getAccountID( player ) ) then
					outputChatBox( "Server database module has started. Your account limitations have been automatically lifted, enjoy!", player, 95, 230, 95 )
				end
			end
		end
	end
)
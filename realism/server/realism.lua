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

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setRuleValue( "Author", "Socialz" )
		setRuleValue( "Contributors", "Socialz <socialz@fairplaymta.net>, Gomitung <>" )
		setRuleValue( "Created", "December 23, 2010" )
		setRuleValue( "Website", "fairplaymta.net" )
		setRuleValue( "Version", "1.0.0" )
		setMapName( "FairPlay Roleplay" )
		setGameType( "FairPlay Roleplay" )
		
		createWater( -2998, -2998, -500, 2998, -2998, -500, -2998, 2998, -500, 2998, 2998, -500 )
		setMinuteDuration( 60000 )
		setFarClipDistance( 2000 )
		
		createBlip( 1419.08, -1553.65, 13.56, 52 ) 	-- LS Bank
		createBlip( 1480.95, -1772.07, 18.79, 41 ) 	-- LS City Hall
		createBlip( 1451.63, -2287.03, 13.54, 5 ) 	-- LS Airport
		createBlip( 933.13, -1720.93, 13.54, 36 ) 	-- LS DMV
		createBlip( 1555.49, -1675.63, 16.19, 30 ) 	-- LS PD
		createBlip( 1172.07, -1323.34, 15.4, 22 ) 	-- LS EMS
		createBlip( 1207.5, -1439.11, 13.38, 20 ) 	-- LS FD
		createBlip(  2737.6, -1760.2, 44.14, 33 ) 	-- LS Arena
	end
)
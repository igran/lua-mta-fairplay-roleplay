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

local localConnection

database.configuration.automated_resources = { }
database.configuration.default_charset = get( "default_charset" ) or "utf8"
database.configuration.default_engine = get( "default_engine" ) or "InnoDB"
database.utility = { }
database.verification = {
	-- name, type, length, default, is_unsigned, is_null, is_auto_increment, key_type
}

database.utility.keys = { unique = true, primary = true, index = true }
function getFormattedKeyType( keyValue, keyType )
	if ( keyValue ) and ( database.utility.keys[ keyType ] ) then
		return "\r\n" .. ( keyType ~= "index" and keyType:upper( ) .. " " or "" ) .. "KEY (`" .. escape_string( keyValue, "char_digit_special" ) .. "`),"
	end
	
	return ""
end

database.utility.keywords = {
	"CURRENT_TIMESTAMP", "CURRENT_TIMESTAMP()", "NOW()", "LOCALTIME", "LOCALTIME()", "LOCALTIMESTAMP", "LOCALTIMESTAMP()",
	"UTC_DATE()", "UTC_DATE", "UTC_TIME()", "UTC_TIME", "UTC_TIMESTAMP()", "UTC_TIMESTAMP",
	"CURDATE()", "CURRENT_DATE()", "CURRENT_DATE",
	"CURTIME()", "CURRENT_TIME()", "CURRENT_TIME",
	"UNIX_TIMESTAMP()", "UNIX_TIMESTAMP",
	"SYSDATE()", "SYSDATE"
}
function isKeyword( string )
	if ( string ) then
		for _, keyword in ipairs( database.utility.keywords ) do
			if ( keyword == string ) then
				return true
			end
		end
	end
	
	return false
end

local function doesTableExist( databaseName, tableName )
	localConnection = dbConnect( database.configuration.database_type, ( database.configuration.database_type == "sqlite" and database.configuration.database_file or "dbname=information_schema;host=" .. database.configuration.hostname ), ( database.configuration.database_type == "sqlite" and "" or database.configuration.username ), ( database.configuration.database_type == "sqlite" and "" or database.configuration.password ), "share=0;batch=" .. database.configuration.database_batch .. ";log=" .. database.configuration.database_log .. ";tag=" .. database.configuration.database_tag )
	
	if ( localConnection ) then
		local databaseName = escape_string( databaseName, "char_digit_special" )
		local tableName = escape_string( tableName, "char_digit_special" )
		local query = dbQuery( localConnection, "SELECT COUNT(*) as `count` FROM `tables` WHERE `table_schema` = ? AND `table_name` = ? LIMIT 1", databaseName, tableName )
		
		if ( query ) then
			local result = dbPoll( query, -1 )
			
			destroyElement( localConnection )
			localConnection = nil
			
			if ( result ) then
				return result[ 1 ].count
			end
		end
	end
	
	return false
end

function verify_table( tableName )
	local databaseName = escape_string( database.configuration.database, "char_digit_special" )
	local tableName = escape_string( tableName, "char_digit_special" )
	
	if ( tableName ) and ( database.verification[ tableName ] ) then
		local result = doesTableExist( databaseName, tableName )
		
		if ( result ) then
			if ( result > 0 ) then
				return true, 1
			else
				local arguments = { tableName }
				local query_string = "CREATE TABLE IF NOT EXISTS `??` ("
				
				for columnID, columnData in ipairs( database.verification[ tableName ] ) do
					table.insert( arguments, columnData.name )
					table.insert( arguments, columnData.type )
					
					if ( columnData.length ) then
						table.insert( arguments, columnData.length )
					end
					
					if ( columnData.default ) and ( not isKeyword( columnData.default ) ) then
						table.insert( arguments, columnData.default )
					end
					
					query_string = query_string .. "\r\n`??` ??" .. ( columnData.length and "(??)" or "" ) .. ( columnData.is_unsigned and " UNSIGNED" or "" ) .. " " .. ( columnData.is_null and "NULL" or "NOT NULL" ) .. ( columnData.default and " DEFAULT " .. ( not isKeyword( columnData.default ) and "?" or columnData.default ) or "" ) .. ( columnData.is_auto_increment and " AUTO_INCREMENT" or "" ) .. ( #database.verification[ tableName ] ~= columnID and "," or "" ) .. getFormattedKeyType( columnData.name, columnData.key_type )
				end
				
				table.insert( arguments, database.configuration.default_engine )
				table.insert( arguments, database.configuration.default_charset )
				
				query_string = query_string .. "\r\n) ENGINE=?? DEFAULT CHARSET=??;"
				
				--[[
				--debugging, just to illustrate the sql query as mta returns it
				local query_string_filled = query_string
				
				for _, value in ipairs( arguments ) do
					local next = query_string_filled:find( "?" )
					
					if ( next ) then
						local isDouble = query_string_filled:sub( next + 1, next + 1 ) == "?"
						query_string_filled = query_string_filled:sub( 1, next - 1 ) .. ( not isDouble and "'" or "" ) .. value .. ( not isDouble and "'" or "" ) .. query_string_filled:sub( next + ( isDouble and 2 or 1 ) )
					end
				end
				]]
				
				if ( execute( query_string, unpack( arguments ) ) ) then
					outputDebugString( "DATABASE: Created table '" .. tableName .. "'." )
					
					return true, 2
				else
					outputDebugString( "DATABASE: Unable to create table '" .. tableName .. "'.", 2 )
					
					return false, 3
				end
			end
		else
			if ( ping( ) ) then
				outputDebugString( "DATABASE: Database is possibly corrupted! Please make sure information_schema exists and is accessible by your SQL user '" .. database.configuration.username .. "' (" .. ( database.configuration.password == "" and "without password" or "with password" ) .. ") at " .. database.configuration.hostname .. "@" .. databaseName .. ".", 2 )
			else
				outputDebugString( "DATABASE: Database connection is missing! Please confirm your SQL information for user '" .. database.configuration.username .. "' (" .. ( database.configuration.password == "" and "without password" or "with password" ) .. ") at " .. database.configuration.hostname .. "@" .. databaseName .. ".", 2 )
			end

			return false, 2
		end
	end

	return false, 1
end

function modify_table( tableName, contents )
	database.verification[ tableName ] = contents
end

addEventHandler( "onResourcePreStart", root,
	function( resource )
		local resourceName = getResourceName( resource )
		local resources = database.configuration.automated_resources[ resourceName ]
		
		if ( resources ) then
			outputDebugString( "DATABASE: Verification check will be ran on '" .. resourceName .. "' resource (awaiting check on " .. #resources .. " table" .. ( #resources > 1 and "s" or "" ) .. ")." )
			
			for _,database in ipairs( resources ) do
				local _return, _code = verify_table( database )
				
				if ( _return ) then
					if ( _code == 2 ) then
						outputDebugString( "DATABASE: Verification check completed on '" .. resourceName .. "' for '" .. database .. "' (database created)." )
					end
				else
					outputDebugString( "DATABASE: Verification check completed on '" .. resourceName .. "' for '" .. database .. "', but errors occurred. Resource start has been cancelled!" )
					
					cancelEvent( )

					break
				end
			end
		end
	end
)

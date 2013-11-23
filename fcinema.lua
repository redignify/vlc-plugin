--[[
 Fcinema Extension for VLC media player 1.1 and 2.0
 
 Authors:  Miguel Arrieta

 This plugin is based on Guillaume Le Maout vlsub extension
 Contact: http://addons.videolan.org/messages/?action=newmessage&username=exebetche
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]


------------------------------- VLC STUFF ------------------------------------


function descriptor()
	return { 
		title = "fcinema",
		version = "0.0",
		author = "arrietaeguren",
		url = 'http://www.fcinema.org/prueba.php',
		shortdesc = "fcinema",
		description = "fcinema",
		capabilities = { "intf", 0 }
	}
end

function activate()
	
	vlc.msg.dbg("[Fcinema] Welcome")

	intf.show_main()

	-- get media info

	--intf.update_main()

end

function close()
	deactivate()
end

function deactivate()
    vlc.msg.dbg("[Fcinema] Bye bye!")
    if dlg then
		dlg:hide() 
	end
	
	--vlc.var.del_callback( vlc.object.input(), "intf-event", edl.check )
    vlc.deactivate()
end



---------------------------- INTERFACE ------------------------------------

local dlg = nil
local select_conf = {} -- Drop down widget / option table association 


intf = {
	input_table = {},


	show_main = function (  )
		intf.close_dlg()
		dlg = vlc.dialog( "fcinema")

		intf.input_table["title"] = dlg:add_label( "<h1>The avengers</h1>", 1, 1, 2, 1)
		intf.input_table["message"] = dlg:add_label("", 1, 7, 1, 1)
		
		dlg:add_label('Violence:', 1, 3, 1, 1)
		intf.input_table['Violence'] = dlg:add_dropdown(2, 3, 1, 1)

		dlg:add_label('Sex:', 1, 6, 1, 1)
		intf.input_table['Sex'] = dlg:add_dropdown(2, 6, 1, 1)

		dlg:add_button( "Ver pelicula", edl.launch, 4, 10, 1, 1)
		dlg:add_button( "Buscar", net.getinfo, 2, 10, 1, 1)
		dlg:add_button( "Close", deactivate, 3, 10, 1, 1)
		
		collectgarbage()
	end,

	show_help = function ( ... )
		-- body
		intf.close_dlg()
		dlg = vlc.dialog( "fcinema helper" )
		collectgarbage()
	end,

	show_message = function ( str )
		if input_table["message"] then
			input_table["message"]:set_text(str)
			dlg:update()
		end
	end,

	show_error = function ( str )
		str = "<span style='color:#B23'><b>Error:</b></span> ".. str
		show_message( str )
	end,

	show_success = function ( str )
		str = "<span style='color:#181'><b>Success</b></span> " .. str
		show_message( str )
	end,

	show_progress = function ( pct )
		local size = 80
		local accomplished = math.ceil( size*pct/100)
		local left = size - accomplished
		local content = "<span style='background-color:#181;color:#181;'>"..
		string.rep ("-", accomplished).."</span>"..
		"<span style='background-color:#fff;color:#fff;'>"..
		string.rep ("-", left).."</span>"
		show_message( content )
	end,

	close_dlg = function ()
		vlc.msg.dbg("[Fcinema] Closing dialog")

		if dlg ~= nil then 
			--~ dlg:delete() -- Throw an error
			dlg:hide() 
		end
		
		dlg = nil
		intf.input_table = nil
		intf.input_table = {}
		collectgarbage() --~ !important	
	end,

}

--------------------------- CONFIGURATION ------------------------------------

config = {
	url = "http://fcinema.org/prueba.php",
	path = nil,
	userAgentHTTP = "fcinema",
	useragent = "Fcinema",
	translations_avail = {},
	downloadBehaviours = nil,
	languages = languages
	option = options,

	getInputItem = function()
		return vlc.item or vlc.input.item()
	end,
}


------------------------------------ EDL --------------------------------------

edl = {
	start = { 10, 20, 30, 40 },
	stop = { 15, 25, 35, 45 },

	launch = function()

		edl.goto( 5 )
		vlc.var.add_callback( vlc.object.input(), "intf-event", edl.check )

		vlc.msg.dbg( "Callback activada " )

	end,

	check = function( )
		t = edl.gettime()

		if not t then return end

		vlc.msg.err( "Comprobando tiempo " .. t )
		for i, stop in ipairs( edl.stop ) do
			if t < stop - 1 and t > edl.start[i] then
				edl.goto ( stop )
			end
		end
	end,

	goto = function( time )
		--TODO check there is an input
		local duration = vlc.input.item():duration()
        vlc.var.set( vlc.object.input(), "position", time / duration)
	end,

	gettime = function()
		--TODO check there is an input
		return vlc.var.get( vlc.object.input(), "time" )
	end,

	read_data = function ( s )
		local start = {}
		local stop = {}

		--local i = 0

		--for line in string.gmatch( s , "[^;]+") do
		--	vlc.msg.dbg( line )
		--end

		dbg.msg( )
		for t,l,g in string.gmatch( s, "(%d+)/(%d+)/(%d+)" ) do 
			

			vlc.msg.dbg( t )
			vlc.msg.dbg( l )
			vlc.msg.dbg( g )

		end
		
	end,

	write_data = function (  )
		
	end,
}


--------------------------------------- NET -------------------------------------------

net = {
	url = "http://fcinema.org/prueba.php",
	userAgentHTTP = "fcinema",
	getinfo = function()
		if not media.gethash() then
			vlc.msg.dbg( "Imposible to get hash")
		end
		local params = "hash=".. media.file.hash
		params = params .. "&filename=".. media.file.uri
		net.post( params, net.url )


	end,
	post = function( params, url )
		local host, path = parse_url( url )	
		local header = {
			"POST "..path.." HTTP/1.1", 
			"Host: "..host, 
			"User-Agent: "..config.userAgentHTTP, 
			"Content-Type: application/x-www-form-urlencoded", 
			"Content-Length: "..string.len(params),
			"",
			""
		}
		params = table.concat(header, "\r\n")..params
		vlc.msg.dbg( params )
		local status, response = net.http_req(host, 80, params)
		vlc.msg.dbg( response )
		net.check_response( status, response )
		return status, response		
	end,

	get = function (url)
		local host, path = parse_url(url)
		local header = {
			"GET "..path.." HTTP/1.1", 
			"Host: "..host, 
			"User-Agent: "..config.userAgentHTTP,
			"",
			""
		}
		local request = table.concat(header, "\r\n")

		local status, response = net.http_req(host, 80, request)
		
		if status == 200 then 
			return response
		else
			return false, status, response
		end
	end,

	check_response = function( status, response )
		if status == 200 then 
			if response and response.status = "200 OK" then
				show_success( "Conexion correcta")
			else if response.status then
				show_error("code '"..response.status.."' ("..status..")")
			end
				elseif response.status == "406 No session" then
					return false
				elseif response then
					setError("code '"..response.status.."' ("..status..")")
					return false
				end
			else
				setError("Server not responding")
				return false
			end
		elseif status == 401 then
			intf.show_error("Request unauthorized")
			return false
		elseif status == 503 then 
			intf.show_error("Server overloaded, please retry later")
			return false
		end
	end,
	http_req = function (host, port, request)
		vlc.msg.dbg( host )
		vlc.msg.dbg( port )
		vlc.msg.dbg( request )
		local fd = vlc.net.connect_tcp(host, port)
		if not fd then return false end
		local pollfds = {}
		
		pollfds[fd] = vlc.net.POLLIN
		vlc.net.send(fd, request)
		vlc.net.poll(pollfds)
		local response = vlc.net.recv(fd, 1024)
		vlc.msg.dbg( "datos recividos" )
		local headerStr, body = string.match(response, "(.-\r?\n)\r?\n(.*)")
		local header = parse_header(headerStr)
		local contentLength = tonumber(header["Content-Length"])
		local TransferEncoding = header["Transfer-Encoding"]
		local status = tonumber(header["statuscode"])
		local bodyLenght = string.len(body)
		local pct = 0
		
		--~ if status ~= 200 then return status end
		-- Si la respuesta no entraba en 1024, bucle leyendo de 1024 en 1024
		while contentLength and bodyLenght < contentLength do
			vlc.net.poll(pollfds)
			response = vlc.net.recv(fd, 1024)

			if response then
				body = body..response
			else
				vlc.net.close(fd)
				return false
			end
			bodyLenght = string.len(body)
			pct = bodyLenght / contentLength * 100
			setMessage("Calculating hash: "..progressBarContent(pct))
		end
		vlc.net.close(fd)
		
		return status, body
	end,
}


----------------------------------  MEDIA ------------------------------------
media = {

	title = "",
	seasonNumber = "",
	episodeNumber = "",
	sublanguageid = "",

	file = {
		hasInput = false,
		uri = nil,
		ext = nil,
		name = nil,
		path = nil,
		protocol = nil,
		cleanName = nil,
		dir = nil,
		hash = nil,
		bytesize = nil,
		fps = nil,
		timems = nil,
		frames = nil
	},

	getFileInfo = function()
		-- Get video file path, name, extension from input uri
		local item = fcinema.getInputItem()
		local file = media.file
		if not item then
			file.hasInput = false;
			file.cleanName = nil;
			file.protocol = nil;
			file.path = nil;
			file.ext = nil;
			file.uri = nil;
		else
			vlc.msg.dbg("[Fcinema] Video URI: "..item:uri())
			local parsed_uri = vlc.net.url_parse(item:uri())
			file.uri = item:uri()
			file.protocol = parsed_uri["protocol"]
			file.path = parsed_uri["path"]
			
		-- Corrections
			
			-- For windows
			file.path = string.match(file.path, "^/(%a:/.+)$") or file.path
			
			-- For file in archive
			local archive_path, name_in_archive = string.match(file.path, '^([^!]+)!/([^!/]*)$')
			if archive_path and archive_path ~= "" then
				file.path = string.gsub(archive_path, '\063', '%%')
				file.path = vlc.strings.decode_uri(file.path)
				file.completeName = string.gsub(name_in_archive, '\063', '%%')
				file.completeName = vlc.strings.decode_uri(file.completeName)
				file.is_archive = true
			else -- "classic" input
				file.path = vlc.strings.decode_uri(file.path)
				file.dir, file.completeName = string.match(file.path, '^(.+/)([^/]*)$')
				
				local file_stat = vlc.net.stat(file.path)
				if file_stat 
				then
					file.stat = file_stat
				end
				
				file.is_archive = false
			end
			
			file.name, file.ext = string.match(file.completeName, '^([^/]-)%.?([^%.]*)$')
			
			if file.ext == "part" then
				file.name, file.ext = string.match(file.name, '^([^/]+)%.([^%.]+)$')
			end
			
			file.hasInput = true;
			file.cleanName = string.gsub(file.name, "[%._]", " ")
			vlc.msg.dbg("[Fcinema] file info "..(dump_xml(file)))
		end
		collectgarbage()
	end,

	gethash = function()
		setMessage("Calculating hash: "..progressBarContent(0))
		
		local item = fcinema.getInputItem()
		
		if not item then
			setError( "No input")
			return false
		end
		
		media.getFileInfo()
			
		if not media.file.path then
			setError( "No something")
			return false
		end
		
		local data_start = ""
		local data_end = ""
        local size
        local chunk_size = 65536
                
		-- Get data for hash calculation
		if media.file.is_archive then
			vlc.msg.dbg("[Fcinema] Read hash data from stream")
		
			local file = vlc.stream(media.file.uri)
			local dataTmp1 = ""
			local dataTmp2 = ""
			size = chunk_size
			
			data_start = file:read(chunk_size)
			
			while data_end do
				size = size + string.len(data_end)
				dataTmp1 = dataTmp2
				dataTmp2 = data_end
				data_end = file:read(chunk_size)
				collectgarbage()
			end
			data_end = string.sub((dataTmp1..dataTmp2), -chunk_size)
		elseif not file_exist(media.file.path) 
		and media.file.stat then
			vlc.msg.dbg("[Fcinema] Read hash data from stream")
			
			local file = vlc.stream(media.file.uri)
			
			if not file then
				vlc.msg.dbg("[Fcinema] No stream")
				return false
			end
			
			size = media.file.stat.size
			local decal = size%chunk_size
			
			data_start = file:read(chunk_size)
			
			-- "Seek" to the end 
			file:read(decal)
			
			for i = 1, math.floor(((size-decal)/chunk_size))-2 do
				file:read(chunk_size)
			end
			
			data_end = file:read(chunk_size)
				
			file = nil
		else
			vlc.msg.dbg("[Fcinema] Read hash data from file")
			local file = io.open( media.file.path, "rb")
			if not file then
				vlc.msg.dbg("[Fcinema] No stream")
				return false
			end
			
			data_start = file:read(chunk_size)
			size = file:seek("end", -chunk_size) + chunk_size
			data_end = file:read(chunk_size)
			file = nil
		end
		
		-- Hash calculation
        local lo = size
        local hi = 0
        local o,a,b,c,d,e,f,g,h
        local hash_data = data_start..data_end
        local max_size = 4294967296
        local overflow
        
		for i = 1,  #hash_data, 8 do
			a,b,c,d,e,f,g,h = hash_data:byte(i,i+7)
			lo = lo + a + b*256 + c*65536 + d*16777216
			hi = hi + e + f*256 + g*65536 + h*16777216
			
			if lo > max_size then
				overflow = math.floor(lo/max_size)
				lo = lo-(overflow*max_size)
				hi = hi+overflow
			end
			
			if hi > max_size then
				overflow = math.floor(hi/max_size)
				hi = hi-(overflow*max_size)
			end
        end
		
		media.file.bytesize = size
		media.file.hash = string.format("%08x%08x", hi,lo)
		vlc.msg.dbg("[Fcinema] Video hash: "..media.file.hash)
		vlc.msg.dbg("[Fcinema] Video bytesize: "..size)
		collectgarbage()
		return true
	end,

	getMovieInfo = function()
		-- Clean video file name and check for season/episode pattern in title
		if notmedia.file.name then
			movie.movie.title = ""
			movie.movie.seasonNumber = ""
			movie.movie.episodeNumber = ""
			return false 
		end
		
		local showName, seasonNumber, episodeNumber = string.match(movie.file.cleanName, "(.+)[sS](%d%d)[eE](%d%d).*")

		if not showName then
		   showName, seasonNumber, episodeNumber = string.match(movie.file.cleanName, "(.+)(%d)[xX](%d%d).*")
		end
		
		if showName then
			movie.movie.title = showName
			movie.movie.seasonNumber = seasonNumber
			movie.movie.episodeNumber = episodeNumber
		else
			movie.movie.title =media.file.cleanName
			movie.movie.seasonNumber = ""
			movie.movie.episodeNumber = ""
		end
		collectgarbage()
	end,

}


function parse_header(data)
	local header = {}
	
	for name, s, val in string.gfind(data, "([^%s:]+)(:?)%s([^\n]+)\r?\n") do
		if s == "" then header['statuscode'] =  tonumber(string.sub (val, 1 , 3))
		else header[name] = val end
	end
	return header
end 

function parse_url(url)
	local url_parsed = vlc.net.url_parse(url)
	return  url_parsed["host"], url_parsed["path"], url_parsed["option"]
end

						--[[ XML utils]]--

function parse_xml(data)
	local tree = {}
	local stack = {}
	local tmp = {}
	local level = 0
	local op, tag, p, empty, val
	table.insert(stack, tree)

	for op, tag, p, empty, val in string.gmatch(
		data, 
		"[%s\r\n\t]*<(%/?)([%w:_]+)(.-)(%/?)>[%s\r\n\t]*([^<]*)[%s\r\n\t]*"
	) do
		if op=="/" then
			if level>0 then
				level = level - 1
				table.remove(stack)
			end
		else
			level = level + 1
			if val == "" then
				if type(stack[level][tag]) == "nil" then
					stack[level][tag] = {}
					table.insert(stack, stack[level][tag])
				else
					if type(stack[level][tag][1]) == "nil" then
						tmp = nil
						tmp = stack[level][tag]
						stack[level][tag] = nil
						stack[level][tag] = {}
						table.insert(stack[level][tag], tmp)
					end
					tmp = nil
					tmp = {}
					table.insert(stack[level][tag], tmp)
					table.insert(stack, tmp)
				end
			else
				if type(stack[level][tag]) == "nil" then
					stack[level][tag] = {}
				end
				stack[level][tag] = vlc.strings.resolve_xml_special_chars(val)
				table.insert(stack,  {})
			end
			if empty ~= "" then
				stack[level][tag] = ""
				level = level - 1
				table.remove(stack)
			end
		end
	end
	
	collectgarbage()
	return tree
end

function parse_xmlrpc(data)
	local tree = {}
	local stack = {}
	local tmp = {}
	local tmpTag = ""
	local level = 0
	local op, tag, p, empty, val
	table.insert(stack, tree)

	for op, tag, p, empty, val in string.gmatch(
		data, 
		"<(%/?)([%w:]+)(.-)(%/?)>[%s\r\n\t]*([^<]*)"
	) do
		if op=="/" then
			if tag == "member" or tag == "array" then
				if level>0  then
					level = level - 1
					table.remove(stack)
				end
			end
		elseif tag == "name" then 
			level = level + 1
			if val~= "" then tmpTag  = vlc.strings.resolve_xml_special_chars(val) end
			
			if type(stack[level][tmpTag]) == "nil" then
				stack[level][tmpTag] = {}
				table.insert(stack, stack[level][tmpTag])
			else
				tmp = nil
				tmp = {}
				table.insert(stack[level-1], tmp)
				
				stack[level] = nil
				stack[level] = tmp
				table.insert(stack, tmp)
			end
			if empty ~= "" then
				level = level - 1
				stack[level][tmpTag] = ""
				table.remove(stack)
			end
		elseif tag == "array" then
			level = level + 1
			tmp = nil
			tmp = {}
			table.insert(stack[level], tmp)
			table.insert(stack, tmp)
		elseif val ~= "" then 
			stack[level][tmpTag] = vlc.strings.resolve_xml_special_chars(val)
		end
	end
	collectgarbage()
	return tree
end

function dump_xml(data)
	local level = 0
	local stack = {}
	local dump = ""
	
	local function parse(data, stack)
		local data_index = {}
		local k
		local v
		local i
		local tb
		
		for k,v in pairs(data) do
			table.insert(data_index, {k, v})
			table.sort(data_index, function(a, b)
				return a[1] < b[1] 
			end)
		end
		
		for i,tb in pairs(data_index) do
			k = tb[1]
			v = tb[2]
			if type(k)=="string" then
				dump = dump.."\r\n"..string.rep (" ", level).."<"..k..">"	
				table.insert(stack, k)
				level = level + 1
			elseif type(k)=="number" and k ~= 1 then
				dump = dump.."\r\n"..string.rep (" ", level-1).."<"..stack[level]..">"
			end
			
			if type(v)=="table" then
				parse(v, stack)
			elseif type(v)=="string" then
				dump = dump..(vlc.strings.convert_xml_special_chars(v) or v)
			elseif type(v)=="number" then
				dump = dump..v
			else
				dump = dump..tostring(v)
			end
			
			if type(k)=="string" then
				if type(v)=="table" then
					dump = dump.."\r\n"..string.rep (" ", level-1).."</"..k..">"
				else
					dump = dump.."</"..k..">"
				end
				table.remove(stack)
				level = level - 1
				
			elseif type(k)=="number" and k ~= #data then
				if type(v)=="table" then
					dump = dump.."\r\n"..string.rep (" ", level-1).."</"..stack[level]..">"
				else
					dump = dump.."</"..stack[level]..">"
				end
			end
		end
	end
	parse(data, stack)
	collectgarbage()
	return dump
end

						--[[ Misc utils]]--

function make_uri(str, encode)
    local windowdrive = string.match(str, "^(%a:\).+$")
	if encode then
		local encodedPath = ""
		for w in string.gmatch(str, "/([^/]+)") do
			encodedPath = encodedPath.."/"..vlc.strings.encode_uri_component(w) 
		end
		str = encodedPath
	end
    if windowdrive then
        return "file:///"..windowdrive..str
    else
        return "file://"..str
    end
end

function file_touch(name) -- test writetability
	if not name or trim(name) == "" 
	then return false end
	
	local f=io.open(name ,"w")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
end

function file_exist(name) -- test readability
	if not name or trim(name) == "" 
	then return false end
	local f=io.open(name ,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
end

function is_dir(path)
	if not path or trim(path) == "" 
	then return false end
	-- Remove slash at the or it won't work on Windows
	path = string.gsub(path, "^(.-)[\\/]?$", "%1")
	local f, _, code = io.open(path, "rb")
	
	if f then 
		_, _, code = f:read("*a")
		f:close()
		if code == 21 then
			return true
		end
	elseif code == 13 then
		return true
	end
	
	return false
end

function list_dir(path)
	if not path or trim(path) == "" 
	then return false end
	local dir_list_cmd 
	local list = {}
	if not is_dir(path) then return false end
	
	if fcinema.conf.os == "win" then
		dir_list_cmd = io.popen('dir /b "'..path..'"')
	elseif fcinema.conf.os == "lin" then
		dir_list_cmd = io.popen('ls -1 "'..path..'"')
	end
	
	if dir_list_cmd then
		for filename in dir_list_cmd:lines() do
			if string.match(filename, "^[^%s]+.+$") then
				table.insert(list, filename)
			end
		end
		return list
	else
		return false
	end
end

function mkdir_p(path)
	if not path or trim(path) == "" 
	then return false end
	if fcinema.conf.os == "win" then
		os.execute('mkdir "' .. path..'"')
	elseif fcinema.conf.os == "lin" then
		os.execute("mkdir -p '" .. path.."'")
	end
end

function is_window_path(path)
	return string.match(path, "^(%a:\).+$")
end

function is_win_safe(path)
	if not path or trim(path) == "" 
	or not is_window_path(path)
	then return false end
	return string.match(path, "^%a?%:?[\\%w%p%s§¤]+$")
end
		
function trim(str)
    if not str then return "" end
    return string.gsub(str, "^[\r\n%s]*(.-)[\r\n%s]*$", "%1")
end


local options = {
	language = nil,
	downloadBehaviour = 'save',
	langExt = false,
	removeTag = false,
	showMediaInformation = true,
	progressBarSize = 80,
	intLang = 'eng',
}

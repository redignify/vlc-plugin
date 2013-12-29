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
		version = config.version,
		author = "arrietaeguren",
		url = 'http://www.fcinema.org',
		shortdesc = "fcinema",
		description = "fcinema",
		capabilities = { "interface", 0 }
	}
end

function activate()
	
	vlc.msg.dbg("[Fcinema] Welcome")

	intf.main.show()

	cache.load_config()

	media.get_info()

end

function close()
	deactivate()
end

function deactivate()
    vlc.msg.dbg("[Fcinema] Bye bye!")

    if dlg then dlg:hide() end

	edl.deactivate()

    vlc.deactivate()
end

function meta_changed()
	
	edl.deactivate()

end



---------------------------- INTERFACE ------------------------------------

local dlg = nil

intf = {
	input_table = {},
	main = {
		--dlg = nil,
		show = function()

			intf.close_dlg()
			dlg = vlc.dialog( "fcinema")
			
			intf.input_table["title"] = dlg:add_label( "<i><center>Estas viendo...</center></i>", 1, 1, 3, 1)

			dlg:add_label('<center><i>Select your own style</i></center>', 1, 2, 3, 1)

			intf.input_table["message"] = dlg:add_label("", 1, 7, 3, 1)
			
			dlg:add_label('Violence:', 1, 3, 1, 1)
			--dlg:add_image( '/home/miguel/violence.png', 1, 3, 1, 1)
			intf.input_table['Violence'] = dlg:add_dropdown(2, 3, 2, 1)
			intf.input_table['Violence']:add_value( "Choose violence level", 1 )
			intf.input_table['Violence']:add_value( "Allow some minor scenes", 2 )
			intf.input_table['Violence']:add_value( "Avoid only hard scenes", 3 )
			intf.input_table['Violence']:add_value( "Show all violence ", 4 )

			dlg:add_label('Sex:', 1, 4, 1, 1)
			intf.input_table['Sex'] = dlg:add_dropdown(2, 4, 2, 1)
			intf.input_table['Sex']:add_value( "Avoid all sex", 1 )
			intf.input_table['Sex']:add_value( "Allow some minor scenes", 2 )
			intf.input_table['Sex']:add_value( "Avoid only explicit scenes", 3 )
			intf.input_table['Sex']:add_value( "Show all sex ", 4 )

			dlg:add_label('Language:', 1, 5, 1, 1)
			intf.input_table['Language'] = dlg:add_dropdown(2, 5, 2, 1)
			intf.input_table['Language']:add_value( "Avoid all language", 1 )
			intf.input_table['Language']:add_value( "Allow some minor scenes", 2 )
			intf.input_table['Language']:add_value( "Avoid only explicit scenes", 3 )
			intf.input_table['Language']:add_value( "Show all language ", 4 )

			dlg:add_button( "Editor", intf.editor.show, 1, 10, 1, 1)
			dlg:add_button( "Buscar", media.get_info, 2, 10, 1, 1)
			--dlg:add_button( "Close", deactivate, 2, 10, 1, 1)
			dlg:add_button( "Ver pelicula", edl.activate, 3, 10, 1, 1)
			
			collectgarbage()
		end,
	},

	editor = {

		show = function (  )
			intf.close_dlg()
			dlg = vlc.dialog( "fcinema editor" )
			intf.input_table['list'] = dlg:add_list( 1, 2, 6, 5 )
			dlg:add_button( "Get time", intf.editor.get_time, 3, 10, 1, 1)
			dlg:add_button( "Volver", intf.main.show, 4, 10, 1, 1)
			intf.input_table['Start'] = dlg:add_text_input( "", 2, 1, 1, 1 )
			intf.input_table['Stop'] = dlg:add_text_input( "", 3, 1, 1, 1 )
			intf.input_table['Type'] = dlg:add_dropdown(4, 1, 1, 1)
				intf.input_table['Type']:add_value( "Vio", 1 )
				intf.input_table['Type']:add_value( "Sex", 2 )
				intf.input_table['Type']:add_value( "Lan", 3 )
			intf.input_table['Desc'] = dlg:add_text_input( "", 5, 1, 4, 1 )
			intf.editor.fill_scenes()
			collectgarbage()
		end,

		get_time = function ()
			local str = media.get_time()
			vlc.msg.err( str )
			intf.input_table["Start"]:set_text( str )			
		end,

		fill_scenes = function()
			local list = intf.input_table["list"]
			list:clear()
			for i=1,#edl.desc do
				list:add_value( edl.desc[i].." "..edl.start[i].." "..edl.stop[i], i)
			end
		end,
	},
	

	show_help = function (  )
		-- body
		intf.close_dlg()
		dlg = vlc.dialog( "fcinema helper" )
		collectgarbage()
	end,

	msg = function ( str )
		if intf.input_table["message"] then
			intf.input_table["message"]:set_text(str)
			dlg:update()
		end
	end,

	sty = {
		err = function ( str )
			return "<span style='color:#B23'><b>"..str.."</b></span> "
		end,

		ok = function ( str )
			return "<span style='color:#181'><b>"..str.."</b></span> "
		end,

		tit = function ( str )
			return "<i><center><h1>"..str.."</h1></center></i>"
		end
	},



	progress_bar = function ( pct )
		local size = 20
		local accomplished = math.ceil( size*pct/100)
		local left = size - accomplished
		return "<span style='background-color:#181;color:#181;'>"..
		string.rep ("-", accomplished).."</span>"..
		"<span style='background-color:#fff;color:#fff;'>"..
		string.rep ("-", left).."</span>"
	end,

	close_dlg = function ()
		
		if dlg ~= nil then 
			vlc.msg.dbg("[Fcinema] Closing dialog")
			--~ dlg:delete() -- Throw an error
			dlg:hide()
		end
		
		dlg = nil
		input_table = nil
		input_table = {}
		collectgarbage() --~ !important	
	end,

}

--------------------------- CONFIGURATION ------------------------------------

config = {
	fcinema_api = "http://fcinema.org/api.php",
	userAgentHTTP = "fcinema",
	useragent = "Fcinema",
	lang = "esp",
	progressBarSize = 80,
	os = "",
	version = "0.0"
}


------------------------------------ EDL --------------------------------------

edl = {
	start = {},
	stop  = {},
	typ   = {},
	level = {},
	desc  = {},
	action= {},
	active = false,
	sync_data = {
		start = nil,
		speed = nil,
	},

	activate = function( )

		if edl.active then
			vlc.osd.message( "fcinema is already active", 1, "botton", 1000000 )
			dlg:hide()
		else	
			vlc.var.add_callback( vlc.object.input(), "intf-event", edl.check )
			edl.active = true
			vlc.osd.message( "fcinema activado", 1, "botton", 1000000 )
			dlg:hide() 
		end
	end,

	deactivate = function()
		if edl.active then
			vlc.var.del_callback( vlc.object.input(), "intf-event", edl.check )
			vlc.osd.message( "fcinema desactivado", 1, "botton", 1000000 )
			edl.active = false
		end
	end,

	check = function( )

		t = media.get_time()

		if not t then return end

		vlc.msg.dbg( "Comprobando tiempo " .. t )

		for i, stop in ipairs( edl.stop ) do
			if t < stop - 1 and t > edl.start[i] then
				-- TODO: allow different actions
				media.go_to ( stop )
				return
			end
		end
	end,

	parse = function ( str )

		-- key=value encoded info
		title = string.match( str, "tit=(.-);")

		intf.input_table['title']:set_text( intf.sty.tit( title ) or "Sorry, unknow movie" )
		
		-- csv encoded info
		local i = 1
		for start, stop, typ, level, desc 
				in string.gfind( str, "&(.-);(.-);(.-);(.-);(.-);" ) do
      		edl.start[i] = tonumber(start)
      		edl.stop[i]  = tonumber(stop)
      		edl.typ[i]   = typ
      		edl.level[i] = tonumber(level)
      		edl.desc[i]  = desc
      		vlc.msg.dbg( "Readed:"..edl.start[i].." "..edl.stop[i].." "..typ.." "..edl.level[i].." "..desc.."\n")
      		i = i + 1 -- TODO
      		
    	end
		
		intf.msg( "" )
		edl.sync()

	end,

	dump = function ( )
		--TODO: save edl info
	end,

	sync = function ( )
		--TODO: modify edl times to fit movie versíon
	end
}

--------------------------------------- CACHE ----------------------------------------

cache = {
	
	filename = "config.xml",
	index = "fcinema.txt",
	db_path = "movies",
	saved = false,
	path = nil,
	slash = "/",

	load_config = function()
		if path == nil then cache.find_path() end
		if path == nil then return end
		--TODO: load saved config
	end,

	save_config = function( )
		--TODO: save to config file
	end,

	find_path = function( )
		
		if is_window_path(vlc.config.datadir()) then
			config.os = "win"
			slash = "\\"
			cache.slash = slash
		else
			config.os = "lin"
			slash = "/"
		end
		
		local path_generic = {"lua", "extensions", "userdata", "fcinema"}
		local dirPath = slash..table.concat(path_generic, slash)
		local filePath	= slash..cache.filename
		
		--[[ Not sure about this TODO
		sub_dir = slash.."vlsub_subtitles"
		
		--  Check if config file path is stored in vlc config
		
		for path in vlc.config.get("sub-autodetect-path"):gmatch("[^,]+") do
			if path:match(".*"..sub_dir.."$") then
				cache.path = path:gsub("%s*(.*)"..sub_dir.."%s*$", "%1")
				cache.saved = true
			end
		end
		]]--
		
		-- if not stored in vlc config
		-- try to find a suitable config file path
		
	    if cache.path then
			if not is_dir(cache.path) and (config.os == "lin"  or is_win_safe(cache.path)) then
				mkdir_p(cache.path)
			end
	    else

	    -- Get clues from VLC
			local userdatadir = vlc.config.userdatadir()
			local datadir = vlc.config.datadir()
			
		-- Check if the config already exist
			if file_exist(userdatadir..dirPath..filePath) then
				cache.path = userdatadir..dirPath
				cache.saved = true
				return
			elseif file_exist(datadir..dirPath..filePath) then
				cache.path = datadir..dirPath
				cache.saved = true
				return
			end

		-- Create config files
			
			local extension_path = slash..path_generic[1]
				..slash..path_generic[2]
			
			-- use the same folder as the extension if accessible
			if is_dir(userdatadir..extension_path) 
			and file_touch(userdatadir..dirPath..filePath) then
					cache.path = userdatadir..dirPath
			elseif file_touch(datadir..dirPath..filePath) then
				cache.path = datadir..dirPath
			end
			
			-- try to create working dir in user folder
			if not cache.path
			and is_dir(userdatadir) then
				if not is_dir(userdatadir..dirPath) then
					mkdir_p(userdatadir..dirPath)
				end
				if is_dir(userdatadir..dirPath) and
				file_touch(userdatadir..dirPath..filePath) then
					cache.path = userdatadir..dirPath
				end
			end
			
			-- try to create working dir in vlc folder	
			if not cache.path and is_dir(datadir) then
				if not is_dir(datadir..dirPath) then
					mkdir_p(datadir..dirPath)
				end
				if file_touch(datadir..dirPath..filePath) then
					cache.path = datadir..dirPath
				end
			end
		end
	end,

	find_movie = function( hash )
		
		vlc.msg.dbg( "Looking on local cache" )
		intf.msg( "Looking for movie content on local cache")
		slash = cache.slash

		-- Get path
		if not cache.path then
			find_path()
			if not cache.path then
				intf.msg( "Sorry there is no cache")
				return false
			end
		end
		vlc.msg.dbg( cache.path .. slash .. cache.index )
		local tmpFile = io.open( cache.path .. slash .. cache.index, "rb")
		if not tmpFile then
			intf.msg( "Imposible to open index")
			return false
		end
		local index = tmpFile:read("*all")
		tmpFile:flush()
		tmpFile:close()

		intf.msg( "data readed")
		local pos, start, speed, movie_code = 
			string.find( index, media.file.hash .. " (w+) (w+) (w+)" )

		if start == nil then
			--TODO search by name
			intf.msg( "Sorry, this movie is not stored locally, try conecting to the web")
			return false
		end

		local tmpFile = io.open( cache.path..slash..db_path..slash..movie_code..".txt", "rb")
		if not tmpFile then return false end
		local content_info = tmpFile:read("*all")
		tmpFile:flush()
		tmpFile:close()

		edl.parse( content_info )

	end,


}
--------------------------------------- NET -------------------------------------------

net = {

	is_available = function()
		return true	--TODO
	end,

	ask_fcinema = function()

		local params = ""
		params = params .. "hash=".. media.file.hash
		params = params .. "&filename=".. media.file.name
		params = params .. "&version=" .. config.version
		params = params .. "&lang=" .. config.lang
		params = params .. "&bytesize=" .. media.file.bytesize

		local status, response = net.post( params, config.fcinema_api )
		-- TODO check response
		edl.parse( response )

	end,

	post = function( params, url )
		local host, path = net.parse_url( url )	
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
		local status, response = net.http_req(host, 80, params)
		return status, response		
	end,

	http_req = function (host, port, request)

		intf.msg( "Conectando con el servidor: ".. intf.progress_bar( 0 ) )
		
		local fd = vlc.net.connect_tcp(host, port)

		if not fd then return false end
		local pollfds = {}
		
		pollfds[fd] = vlc.net.POLLIN
		vlc.net.send(fd, request)
		vlc.net.poll(pollfds)	-- TODO: Peta si no hay servidor
		local response = vlc.net.recv(fd, 1024)
		local headerStr, body = string.match(response, "(.-\r?\n)\r?\n(.*)")
		local header = net.parse_header(headerStr)
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
			intf.msg( "Recibiendo datos: ".. intf.progress_bar( pct ) )
		end
		vlc.net.close(fd)
		
		return status, body
	end,

	parse_header = function(data)
		local header = {}
		
		for name, s, val in string.gfind(data, "([^%s:]+)(:?)%s([^\n]+)\r?\n") do
			if s == "" then header['statuscode'] =  tonumber(string.sub (val, 1 , 3))
			else header[name] = val end
		end
		return header
	end,

	parse_url = function (url)
		local url_parsed = vlc.net.url_parse(url)
		return  url_parsed["host"], url_parsed["path"], url_parsed["option"]
	end,
}


----------------------------------  MEDIA ------------------------------------
media = {

	title = "",

	file = {
		hasInput = false,
		uri = nil,
		ext = nil,
		name = "",
		path = nil,
		protocol = nil,
		cleanName = nil,
		dir = nil,
		hash = nil,
		bytesize = nil,
		completeName = nil,
	},

	get_info = function()

		if not media.input_item() then
			intf.msg( intf.sty.err( "No input item") )
			return
		end

		media.get_file_info()
		media.get_hash()

		if net.is_available() then
			vlc.msg.dbg( "Network is available")
			net.ask_fcinema()
		else
			vlc.msg.dbg( "Network no available")
			cache.find_movie()
		end

	end,

	go_to = function( time )
		--TODO: if not media.file.hasInput then return end
		--Set "position" as it crash if "time" is set directly
		local duration = vlc.input.item():duration()
        vlc.var.set( vlc.object.input(), "position", time / duration)
	end,

	get_time = function()
		--TODO: if media.file.hasInput == false then return end
		return vlc.var.get( vlc.object.input(), "time" )
	end,

	input_item = function()
		return vlc.item or vlc.input.item()
	end,

	get_file_info = function()
		vlc.msg.dbg( "Getting file info" )
		-- Get video file path, name, extension from input uri
		local item = media.input_item()
		local file = media.file
		if not item then
			file.hasInput = false
			file.cleanName = nil
			file.protocol = nil
			file.path = nil
			file.ext = nil
			file.uri = nil
			collectgarbage()
			return
		end

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
			if file_stat then file.stat = file_stat end
			file.is_archive = false
		end
		
		if not file.completeName then
			file.isstream = true
			file.is_archive = true
			vlc.msg.dbg("[Fcinema] file info "..(dump_xml(file)))
			vlc.msg.err( item:name() )
			return
		end

		file.name, file.ext = string.match(file.completeName, '^([^/]-)%.?([^%.]*)$')
		
		if file.ext == "part" then
			file.name, file.ext = string.match(file.name, '^([^/]+)%.([^%.]+)$')
		end
		
		file.hasInput = true;
		file.cleanName = string.gsub(file.name, "[%._]", " ")

		vlc.msg.dbg("[Fcinema] file info "..(dump_xml(file)))
		collectgarbage()
	end,


	get_hash = function()
	-- Compute hash according to opensub standards	
		intf.msg("Calculating hash: ".. intf.progress_bar( 0 ) )
		
		-- Get input and prepare stuff
		local item = media.input_item()
		
		if not item then 
			intf.msg( intf.sty.err( "No input item") )
			return false
		end
			
		if not media.file.path then
			intf.msg( "No input path")
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

		elseif not file_exist(media.file.path) and media.file.stat then
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
				vlc.msg.dbg("[Fcinema] No file")
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

}


----------------------------------------- UTILS -----------------------------------------------



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

		
function trim(str)
    if not str then return "" end
    return string.gsub(str, "^[\r\n%s]*(.-)[\r\n%s]*$", "%1")
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

function mkdir_p(path)
	if not path or trim(path) == "" 
	then return false end
	if config.os == "win" then
		os.execute('mkdir "' .. path..'"')
	elseif config.os == "lin" then
		os.execute("mkdir -p '" .. path.."'")
	end
end

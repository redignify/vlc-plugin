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

--iconitio, evitar palabras raras "hash", 


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

	intf.loading.show()

	media.get_info()

	intf.main.show()

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
	items = {},

	loading = {
		show = function ( )
			intf.change_dlg()
			intf.items["message"] = dlg:add_label("", 1, 99, 10, 1)
		end,
	},
	main = {
		show = function()

			intf.change_dlg()

			-- Static
			local title = intf.sty.tit( fcinema.data['tit'] ) or intf.sty.tit( 'El hobbit' )--"<i><center>Estas viendo...</center></i>"
			intf.items["title"] = dlg:add_label( title, 1, 1, 10, 1)
			intf.items["director"] = dlg:add_label( " ", 1, 2, 1, 1)
			intf.items["pg"] = dlg:add_label( " ", 3, 2, 1, 1)

			intf.items['ba'] = dlg:add_button( "Avanzado", intf.advanced.show, 3, 100, 1, 1)
			intf.items['bay'] = dlg:add_button( "Ayuda", intf.change_dlg, 2, 100, 1, 1)
			intf.items['bv'] = dlg:add_button( "Ver pelicula", edl.activate, 6, 100, 1, 1)

			intf.items["message"] = dlg:add_label("", 1, 99, 10, 1)

			-- "Dynamic"
			local row = 10
			for k,v in pairs( intf.main.list ) do
				intf.main.add_list( k, row )
				row = row + 10
			end

			--intf.items['vm6'] = dlg:add_button( "Violencia moderada", intf.main.show_4, 1, 40, 2, 1)
			--intf.items['s40'] = dlg:add_check_box( 'Skip (2 escenas)', 1, 3, 40, 2)
			
			collectgarbage()
		end,

		list = {},

		actions = {},

		button = {},

		label = {'Violencia extrema '},

		add_list = function ( typ, row )
			if row == 10 then
				func = intf.main.show_1
			elseif row == 20 then
				func = intf.main.show_2
			else
				func = intf.main.show_3
			end
			intf.items['l'..typ] = dlg:add_button( intf.main.label[1]..typ, func, 1, row, 2, 1)
			intf.items['s'..row] = dlg:add_check_box( 'Skip ('..#intf.main.list[typ]..' escenas)', 1, 3, row, 2)
			intf.main.button[ row / 10 ] = typ
		end,

		create_list = function ( ... )
			for k,v in pairs( fcinema.data['type'] ) do
				if not intf.main.list[v] then
					intf.main.list[v] = {}
				end
				table.insert( intf.main.list[v], k )
				intf.main.actions[k] = true
			end
		end,

		show_1 = function (  ) intf.main.show_n( 1 ) end,
		show_2 = function (  ) intf.main.show_n( 2 ) end,
		show_3 = function (  ) intf.main.show_n( 3 ) end,
		show_4 = function (  ) intf.main.show_n( 4 ) end,
		show_5 = function (  ) intf.main.show_n( 5 ) end,
		show_6 = function (  ) intf.main.show_n( 6 ) end,

		add_header = function ( row )
			intf.del( 's'..(row-1) )
			intf.items['de'..row] = dlg:add_label('<b><i>Descipción</i></b>', 2, row, 2, 1)
			intf.items['d'..row] = dlg:add_label('<b><i>Duración</i></b>', 5, row, 1, 1)
			intf.items['i'..row] = dlg:add_label('<b><i>Inicio</i></b>', 4, row, 1, 1)
		end,

		del_header = function ( row )
			local typ = intf.main.button[ ( row -1 )/ 10 ]
			local num = 0
			for k,v in pairs( intf.main.list[typ] ) do
				if intf.main.actions[v] == true then
					num = num + 1
				end
			end
			intf.items['s'.. (row-1)] = dlg:add_check_box( 'Skip ('..num..' escenas)', 1, 3, row-1, 1)
			intf.del( 'de'..row )
			intf.del( 'd'..row )
			intf.del( 'i'..row )
		end,
		
		add_scene = function ( row, num )
			local len = fcinema.data['stop'][num] - fcinema.data['start'][num]
			local hour = intf.to_hour( fcinema.data['start'][num] )

			intf.items['de'..row] = dlg:add_label( fcinema.data['desc'][num], 2, row, 2, 1)
			intf.items['d'..row] = dlg:add_label('<center>'..len..'"</center>', 5, row, 1, 1)
			intf.items['i'..row] = dlg:add_label( hour, 4, row, 1, 1)
			intf.items['s'..row] = dlg:add_check_box( 'Skip', 1, 6, row, 2)
			intf.items['s'..row]:set_checked( intf.main.actions[num] )
		end,
		
		del_scene = function ( row, num )
			intf.del( 'de'..row )
			intf.del( 'd'..row )
			intf.del( 'i'..row )
			intf.main.actions[num] = intf.items['s'..row]:get_checked()
			intf.del( 's'..row )
		end,
		
		show_n = function ( n )
			
			local row = n * 10
			
			if intf.items['s'..row] then
				--vlc.msg.dbg( 'adding '..row )
				typ = intf.main.button[n]
				for i,v in ipairs( intf.main.list[typ] ) do
					intf.main.add_scene( row + i + 1, v )
				end
				intf.main.add_header( row + 1)
			else
				--vlc.msg.dbg( 'deleting ' .. row )
				typ = intf.main.button[n]
				for i,v in ipairs( intf.main.list[typ] ) do
					intf.main.del_scene( row + i + 1, v )
				end
				intf.main.del_header( row + 1 )
			end
		end,
	},

	change_dlg = function ( ... )
		for k,v in pairs( intf.items ) do
			intf.del( k )
		end
		intf.items = nil
		intf.items = {}
		if not dlg then dlg = vlc.dialog( "fcinema") end
		collectgarbage()
	end,

	del = function ( str )
		if intf.items[ str ] then
			dlg:del_widget( intf.items[ str ] )
			intf.items[ str ] = nil
		end
	end,

	to_hour = function ( time )
		
		if type( time ) == "string" then return time end
		local sec = time%60
		local min = (time - sec )/60
		--local hour = sec/3600
		sec = math.floor( sec * 10 ) / 10
		if sec < 10 then sec = '0'..sec end
		if min < 10 then min = ' '..min end
		return min..':'..sec
	end,

	advanced = {
		show = function ( ... )
			intf.change_dlg()
			intf.items['e'] = dlg:add_button( "Editor", intf.editor.show, 1, 10, 1, 1)
		end,
	},

	editor = {

		show = function (  )
			intf.change_dlg()
			--dlg = vlc.dialog( "fcinema editor" )
			intf.items['list'] = dlg:add_list( 1, 2, 4, 5 )
			intf.items['a'] = dlg:add_button( "Empieza ahora", intf.editor.get_time, 2, 10, 1, 1)
			intf.items['b'] = dlg:add_button( "Termina ahora", intf.editor.get_time2, 3, 10, 1, 1)
			intf.items['c'] = dlg:add_button( "Añadir escena", intf.editor.add_value, 5, 5, 1, 1)
			intf.items['d'] = dlg:add_button( "Volver", intf.main.show, 10, 10, 1, 1)
			intf.items['e'] = dlg:add_button( "Editar selección", intf.main.show, 5, 6, 1, 1)

			intf.items['Start'] = dlg:add_text_input( "", 2, 9, 1, 1 )
			intf.items['Stop'] = dlg:add_text_input( "", 3, 9, 1, 1 )
			intf.items['Type'] = dlg:add_dropdown(4, 10, 1, 1)
				intf.items['Type']:add_value( "v", 1 )
				intf.items['Type']:add_value( "x", 2 )
				intf.items['Type']:add_value( "s", 3 )
			intf.items['Desc'] = dlg:add_text_input( "", 5, 10, 4, 1 )
			intf.editor.fill_scenes()
			collectgarbage()
		end,

		get_time = function ()
			local str = intf.to_hour( media.get_time() )
			vlc.msg.err( str )
			intf.items["Start"]:set_text( str )		
		end,

		get_time2 = function ()
			local str = intf.to_hour( media.get_time() )
			vlc.msg.err( str )
			intf.items["Stop"]:set_text( str )			
		end,

		add_value = function ( )
			local start = intf.items["Start"]:get_text() or ''
			local stop = intf.items["Stop"]:get_text() or ''
			local desc = intf.items["Desc"]:get_text() or ''
			local typ = intf.items["Type"]:get_text() or ''

			intf.editor.add_scene( start, stop, desc, typ, i )
			
		end,

		add_scene = function ( start, stop, desc, typ, i )
			start = intf.to_hour( start )
			stop = intf.to_hour( stop )
			intf.items['list']:add_value( start .." ".. stop.." "..typ.." "..desc, i)
		end,

		read_scene = function ( id )
			

			return start, stop, desc, typ
		end,

		fill_scenes = function()
			intf.items['list']:clear()
			local data = fcinema.data
			for i,v in ipairs( data['desc'] ) do
				intf.editor.add_scene( data['start'][i], data['stop'][i], data['desc'][i], data['type'][i], i )
			end
		end,
	},
	
	help = {
		show = function (  )
			intf.change_dlg()
			--dlg = vlc.dialog( "fcinema helper" )
			collectgarbage()
		end,
	},
	

	msg = function ( str )
		if intf.items["message"] then
			intf.items["message"]:set_text(str)
			dlg:update()
		end
	end,

	sty = {
		err = function ( str )
			if not str then return end
			return "<span style='color:#B23'><b>"..str.."</b></span> "
		end,

		ok = function ( str )
			if not str then return end
			return "<span style='color:#181'><b>"..str.."</b></span> "
		end,

		tit = function ( str )
			if not str then return end
			return "<i><center><h1>"..str.."</h1></center></i>"
		end
	},



	progress_bar = function ( pct )
		local size = 30
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
		items = nil
		items = {}
		collectgarbage() --~ !important	
	end,

}

--------------------------- CONFIGURATION ------------------------------------

config = {
	lang = "esp",
	progressBarSize = 80,
	os = "",
	version = "0.0",
	agent = "vlc",
}


------------------------------------ EDL --------------------------------------

edl = {
	start = {},
	stop  = {},
	action= {},
	active = false,

	activate = function( )
		if edl.active then
			vlc.osd.message( "fcinema is already active", 1, "botton", 1000000 )
			dlg:hide()
		else
			if not edl.from_user() then return end
			vlc.var.add_callback( vlc.object.input(), "intf-event", edl.check )
			edl.active = true
			vlc.osd.message( "fcinema activado", 1, "botton", 1000000 )
			dlg:hide() 
		end
	end,

	from_user = function ( ... )
		for k,v in pairs( intf.main.actions ) do
			if v then
				table.insert( edl.start, fcinema.data['start'][k] )
				table.insert( edl.stop, fcinema.data['stop'][k] )
			end
		end
		return 1
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

}

fcinema = {

	api_url = "http://fcinema.org/api.php",
	data = {},

	search = function()

		local params = ""
		params = params .. "action=search"
		params = params .. "&hash=".. media.file.hash
		params = params .. "&filename=".. media.file.name
		params = params .. "&bytesize=" .. media.file.bytesize
		params = params .. "&agent=" .. config.agent..'-'.. config.version
		params = params .. "&lang=" .. config.lang
		
		local status, response = net.post( params, fcinema.api_url )

		--if not response then return end
		--TODO: use dkjson
		local json = require ("dkjson")

		response = '{ "tit":"Toy Story 3","type":["v","s","v","x"],"start":[200,25,136,289],"stop":[230,50,140,300],"desc":["cosas para saltar","escene fea","esto mejor no ver","basura grafica"]}'

		--response = '{ "id":"0435761","tit":"Toy Story 3","director":"Lee Unkrich","pg":"G","rating":85 }'
		local a = json.decode( response )

		vlc.msg.dbg( type( a ) )
		vlc.msg.dbg( dump_xml( a ) or a )

		
		local data = simple_json_decode( response )

		if data['tit'] then
			--intf.items['title']:set_text( intf.sty.tit( data['tit'] ) )
			--intf.items['director']:set_text( data['director'][1] or "" )
			--intf.items['pg']:set_text( "PG: " .. data['pg'] or "" )
			fcinema.data = data
			--vlc.msg.dbg( fcinema.data['type'] )
			intf.main.create_list()
		else
			--intf.items['title']:set_text( "Sorry, unknow movie" )
		end
		intf.msg("")
		return true
	end,
	
}

function simple_json_decode( json )

	local function str2type( str )
		a = string.match( str, '"(.+)"' )
		if not a then a =  tonumber( str ) end
		if not a then a = tonumber( str:gsub( '.',',') ) end
		return a
	end

	local function table2type( t )
		tf = {}
		for i,v in ipairs( t ) do
			a = str2type( v )
			table.insert( tf, a )
		end
		return tf
	end

	local data = {}
	-- single
	for key, value in string.gmatch( json, '"([^:,]-)":([^:]-)[,}]') do
		data[key] = str2type( value )
	end
	-- strings
	for key, value in string.gmatch( json, '"([^:,]-)":%[([^:]-)][,}]') do
		data[key] = table2type( split( value ) )
	end

	vlc.msg.dbg("[Fcinema] decoded ".. dump_xml(data) )
	--vlc.msg.deb("json encoded " .. simple_json_encode(data) )

	return data
end

--------------------------------------- NET -------------------------------------------

net = {

	post = function( params, url )
		local host, path = net.parse_url( url )	
		local header = {
			"POST "..path.." HTTP/1.1", 
			"Host: "..host, 
			"Content-Type: application/x-www-form-urlencoded", 
			"Content-Length: "..string.len(params),
			"",
			""
		}
		params = table.concat(header, "\r\n")..params
		vlc.msg.dbg( params )
		local status, response = net.http_req(host, 80, params)
		vlc.msg.dbg( response or " " )
		return status, response		
	end,

	http_req = function (host, port, request)

		intf.msg( "Identificando película: ".. intf.progress_bar( 40 ) )
		
		local fd = vlc.net.connect_tcp(host, port)

		if not fd or fd == -1 then return false end
		local pollfds = {}
		intf.msg( "Identificando película: ".. intf.progress_bar( 50 ) )
		pollfds[fd] = vlc.net.POLLIN
		vlc.net.send(fd, request)
		intf.msg( "Identificando película: ".. intf.progress_bar( 70 ) )
		vlc.net.poll(pollfds)
		intf.msg( "Identificanto película: ".. intf.progress_bar( 80 ) )
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
			pct = bodyLenght / contentLength * 30 + 70
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
		intf.msg( "Identificando película: ".. intf.progress_bar( 10 ) )
		media.get_file_info()
		intf.msg( "Identificando película: ".. intf.progress_bar( 20 ) )
		media.get_hash()
		intf.msg( "Identificando película: ".. intf.progress_bar( 30 ) )

		if not fcinema.search() then
			vlc.msg.dbg( "Network no available")
			--cache.find_movie()
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


function simple_json_encode( table )

	local function str2json( str )
		if type(str)=="number" then
			return str
		else
			return '"'..str..'"'
		end
	end

	local function type2json( value )
		local json
		if type(v)=="table" then
			json = '['
			for k, v in pairs( value ) do
				json = json..str2json(v)..','
			end
			json = json ..']'
		else
			json = str2json( value )
		end
		return json
	end

	local str = '{'
	for k, v in pairs( table ) do
		str = str..'"'.. k..'":'
		str = str..type2json(v)..','
	end
	return str..'}'

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

function split(str)
	if str == nil then return end
   local pat = ","
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

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

--[[Lua scripts are tried in alphabetical order in the user's VLC config
directory lua/{playlist,meta,intf}/ subdirectory on Windows and Mac OS X or
in the user's local share directory (~/.local/share/vlc/lua/... on linux),
then in the global VLC lua/{playlist,meta,intf}/ directory.
]]--


function descriptor()
    return { 
        title = "fcinema",
        version = config.version,
        author = "arrietaeguren",
        url = 'http://www.fcinema.org',
        shortdesc = "fcinema",
        description = "fcinema",
        capabilities = { "input-listener" }
    }
end

function activate()

    config.load()

    vlc.msg.dbg("[Fcinema] Welcome")

    intf.loading.show()

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

--[[function menu()
    return {       
        "Mostrar menu", 
        "Enviar feedback", 
        "Mostrar ayuda"
    }
end

function trigger_menu(dlg_id)
    if dlg_id == 1 then
        intf.main.show()
    elseif dlg_id == 2 then
        intf.main.show()
    elseif dlg_id == 3 then
        intf.main.show()
    end
    collectgarbage() --~ !important    
end
]]--
function meta_changed()
    --TODO:
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

    confirm_movie = {
        show = function ( ... )
            intf.change_dlg()
            intf.items['header'] = dlg:add_label( "<b><h3><center>¿Que película estas viendo?</center></h3></b>", 1, 1, 4, 1 )
            intf.items['list'] = dlg:add_list( 1, 3, 7, 7 )
            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)
            intf.items['title'] = dlg:add_text_input( media.file.name, 1, 2, 6, 1 )
            intf.items['search'] = dlg:add_button( "Buscar por nombre", intf.confirm_movie.search, 7, 2, 1, 1 )
            intf.items['choose'] = dlg:add_button( "Seleccionar", intf.confirm_movie.choose, 6, 11, 1, 1 )
            intf.items['local'] = dlg:add_button( "Modo offline", intf.confirm_movie.private, 7, 11, 1, 1 )
            

            intf.confirm_movie.fill_movies()
        end,

        fill_movies = function()
            intf.items['list']:clear()
            local data = fcinema.data
            if not data or not data['titles'] then return end
            for k,v in pairs( data['titles'] ) do
                local desc = string.gsub( data['directors'][k], "%s+", " ")
                intf.items['list']:add_value( data['titles'][k]..' ('..desc..')', k )
            end
        end,

        search = function ( ... )
            media.file.name = intf.items["title"]:get_text()
            local data = fcinema.search_online( nil, nil, nil, media.file.name )
            fcinema.data = data
            intf.confirm_movie.show()
        end,

        choose = function ( ... )
            local tab = intf.items['list']:get_selection( )
            for k,v in pairs( tab ) do
                id = fcinema.data['ids'][k]
                break
            end
            fcinema.search( id )
        end,

        private = function ( ... )
            if not fcinema.data then return end
            fcinema.data['id'] = 'p'..media.file.hash
            fcinema.data['title'] = intf.items["title"]:get_text()
            local index = system.read( config.path .. config.offline_db )
            index = index .. media.file.hash ..';'..fcinema.data['id']..';0;\n'
            system.write( config.path .. config.offline_db, index )
            intf.main.show()
        end,

    }, 

    main = {
        show = function()

            intf.change_dlg()
            
            intf.main.list = {}
            intf.main.actions = {}
            intf.main.button = {}

            intf.main.create_list()

            -- Static
            local title = intf.sty.tit( fcinema.data['title'] ) or intf.sty.tit( ' ' )
            intf.items["title"] = dlg:add_label( title, 2, 1, 10, 1)
            intf.items["director"] = dlg:add_label( '<i><center>'..(fcinema.data['director'] or '')..'</center></i>', 2, 2, 10, 1)
            intf.items["pg"] = dlg:add_label( fcinema.data['pg'] or '', 3, 2, 1, 1)

            intf.items['advanced'] = dlg:add_button( "Avanzado", intf.advanced.show, 3, 100, 1, 1)
            intf.items['help'] = dlg:add_button( "Ayuda", intf.help.show, 1, 100, 2, 1)
            intf.items['watch'] = dlg:add_button( "Ver pelicula", edl.activate, 10, 100, 2, 1)

            intf.items["message"] = dlg:add_label("", 1, 99, 10, 1)

            intf.items["image"] = dlg:add_image( 'http://ia.media-imdb.com/images/M/MV5BMTcwNTE4MTUxMl5BMl5BanBnXkFtZTcwMDIyODM4OA@@._V1_SX300.jpg', 2, 1, nil, 2 )
            --fcinema.data['poster']

            -- "Dynamic"
            local row = 10
            for k,v in pairs( intf.main.list ) do
                intf.main.add_list( k, row )
                row = row + 10
            end
            
            collectgarbage()
        end,

        label =  {
            ['v'] = 'Violencia',
            ['vp'] = 'Violencia extrema',
            ['x'] = 'Sexo implicito',
            ['xp'] = 'Sexo explicito',
            ['s'] = 'Desnudo implicito',
            ['sp'] = 'Desnudo explicito'
        },

        add_list = function ( typ, row )
            if row == 10 then func = intf.main.show_1
            elseif row == 20 then func = intf.main.show_2
            elseif row == 30 then func = intf.main.show_3
            elseif row == 40 then func = intf.main.show_4
            elseif row == 50 then func = intf.main.show_5
            else func = intf.main.show_6
            end
            intf.items['l'..typ] = dlg:add_button( intf.main.label[typ] or typ, func, 1, row, 3, 1)
            intf.items['s'..row] = dlg:add_check_box( 'Skip ('..#intf.main.list[typ]..' escenas)', 1, 4, row, 2)
            intf.main.button[ row / 10 ] = typ
        end,

        create_list = function ( ... )
            if not fcinema.data['type'] then return end
            intf.main.list = {}
            for k,v in pairs( fcinema.data['type'] ) do
                if not intf.main.list[v] then
                    intf.main.list[v] = {}
                end
                table.insert( intf.main.list[v], k )
                intf.main.actions[k] = true
            end
            vlc.msg.dbg( json.encode( intf.main.list ) )
        end,

        read_values = function ( ... )
            
        end,

        show_1 = function (  ) intf.main.show_n( 1 ) end,
        show_2 = function (  ) intf.main.show_n( 2 ) end,
        show_3 = function (  ) intf.main.show_n( 3 ) end,
        show_4 = function (  ) intf.main.show_n( 4 ) end,
        show_5 = function (  ) intf.main.show_n( 5 ) end,
        show_6 = function (  ) intf.main.show_n( 6 ) end,

        add_header = function ( row )
            intf.del( 's'..(row-1) )
            intf.items['de'..row] = dlg:add_label('<b><center><i>Descipción</i></center></b>', 2, row, 6, 1)
            intf.items['d'..row] = dlg:add_label('<b><i>Duración</i></b>', 10, row, 1, 1)
            intf.items['i'..row] = dlg:add_label('<b><i>Inicio</i></b>', 9, row, 1, 1)
        end,

        del_header = function ( row )
            local typ = intf.main.button[ ( row -1 )/ 10 ]
            local num = 0
            for k,v in pairs( intf.main.list[typ] ) do
                if intf.main.actions[v] == true then
                    num = num + 1
                end
            end
            intf.items['s'.. (row-1)] = dlg:add_check_box( 'Skip ('..num..' escenas)', 1, 4, row-1, 1)
            intf.del( 'de'..row )
            intf.del( 'd'..row )
            intf.del( 'i'..row )
        end,
        
        add_scene = function ( row, num )
            local len = fcinema.data['stop'][num] - fcinema.data['start'][num]
            len = math.floor( len )
            local hour = intf.to_hour( fcinema.data['start'][num], 1 )

            intf.items['de'..row] = dlg:add_label( fcinema.data['desc'][num], 2, row, 6, 1)
            intf.items['d'..row] = dlg:add_label('<center>'..len..'"</center>', 10, row, 1, 1)
            intf.items['i'..row] = dlg:add_label( hour, 9, row, 1, 1)
            intf.items['s'..row] = dlg:add_check_box( 'Skip', 1, 11, row, 1)
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
        if not dlg then dlg = vlc.dialog( "Family Cinema (Beta)") end
        collectgarbage()
    end,

    del = function ( str )
        if intf.items[ str ] then
            dlg:del_widget( intf.items[ str ] )
            intf.items[ str ] = nil
        end
    end,

    to_hour = function ( time, precision )
        if type( time ) == "string" then return time end
        local sec = time%60
        local min = (time - sec )/60
        --local hour = sec/3600
        sec = math.floor( sec * precision ) / precision
        if sec < 10 then sec = '0'..sec end
        if min < 10 then min = ' '..min end
        return min..':'..sec
    end,

    to_sec = function ( str )
        if not str or str == '' then return end
        if type( str ) == "number" then return str end
        local min, sec = string.match( str, '(.+):(.+)' )
        sec = min * 60 + sec
        return sec
    end,

    advanced = {
        show = function ( ... )
            intf.change_dlg()
            intf.items['l_editor'] = dlg:add_label( "Crea tu propia lista de escenas: ", 1, 2, 3, 1 )
            intf.items['b_editor'] = dlg:add_button( "Editor", intf.editor.show, 4, 2, 1, 1)

            intf.items['l_donate'] = dlg:add_label( "Ayuda a mantener fcinema: ", 1, 3, 1, 1 )
            intf.items['b_donate'] = dlg:add_button( "Donar", intf.advanced.donate, 4, 3, 1, 1)

            intf.items['l_sync'] = dlg:add_label( "Sincronización manual: ", 1, 4, 1, 1 )
            intf.items['b_sync'] = dlg:add_button( "Sincronizar", intf.manual_sync.show, 4, 4, 1, 1)

            intf.items['l_bad_movie'] = dlg:add_label( "No es esta la película que estas viendo: ", 1, 5, 1, 1 )
            intf.items['b_bad_movie'] = dlg:add_button( "Cambiar película", intf.advanced.bad_hash, 4, 5, 1, 1)

            intf.items['l_feedback'] = dlg:add_label( "Tu opinión nos importa: ", 1, 6, 1, 1 )
            intf.items['b_feedback'] = dlg:add_button( "Enviar feedback", intf.feedback.show, 4, 6, 1, 1)

            intf.items['b_auto_sync'] = dlg:add_button( "Auto sync", sync.auto, 4, 7, 1, 1 )

            intf.items["message"] = dlg:add_label("", 1, 9, 7, 1)
            --intf.items['l_main'] = dlg:add_label( "Empieza: ", 1, 5, 1, 1 )
            intf.items['b_main'] = dlg:add_button( "Atras", intf.main.show, 4, 10, 1, 1)
        end,

        donate = function ( ... )
            intf.msg( intf.sty.ok( "Toda la información sobre como ayudar en <a href='http://www.fcinema.org/'>fcinema.org</a>") )
        end,

        bad_hash = function ( ... )
            --fcinema.data = nil
            --local data = fcinema.search_online( nil, nil, nil, media.file.name )
            --fcinema.data = data
            intf.confirm_movie.show()
        end,
    },

    feedback = {

        show = function ( ... )
            intf.change_dlg()

            intf.items['l_texto'] = dlg:add_label( "Introduce tu comentario: ", 1, 1, 2, 1 )
            intf.items['comment'] = dlg:add_text_input( "", 1, 2, 5, 1 )
            intf.items['b_comment'] = dlg:add_button( "Enviar feedback", intf.feedback.send, 6, 2, 1, 1 )

            intf.items["message"] = dlg:add_label("", 1, 9, 7, 1)
            intf.items['b_back'] = dlg:add_button( "Volver", intf.advanced.show, 6, 10, 1, 1)

        end,

        send = function ( ... )
            fcinema.feedback( "","","")
        end,

    },

    manual_sync = {
        
        show = function ( ... )
            intf.change_dlg()

            intf.items['l_offset'] = dlg:add_label( "Introduce los segundos de desfase: ", 1, 1, 3, 1 )
            intf.items['offset'] = dlg:add_text_input( "", 1, 2, 1, 1 )
            intf.items['b_offset'] = dlg:add_button( "Aplicar offset", intf.manual_sync.apply_offset, 3, 2, 1, 1 )

            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)
            intf.items['b_back'] = dlg:add_button( "Volver", intf.advanced.show, 10, 10, 1, 1)

        end,

        apply_offset = function ( )
            local offset = intf.items['offset']:get_text()
            if sync.apply_offset( offset ) then
                intf.msg( "Offset de " .. offset .. "s aplicado")
            end
        end,
    },

    editor = {

        dropdown = {},

        show = function (  )
            intf.change_dlg()
            --dlg = vlc.dialog( "fcinema editor" )
            intf.items['list'] = dlg:add_list( 1, 2, 7, 8 )

            intf.items['l_start'] = dlg:add_label( "Empieza: ", 8, 2, 1, 1 )
            intf.items['Start'] = dlg:add_text_input( "", 9, 2, 1, 1 )
            intf.items['b_start'] = dlg:add_button( "Ahora", intf.editor.get_time, 10, 2, 1, 1)

            intf.items['l_end'] = dlg:add_label( "Termina: ", 8, 3, 1, 1 )
            intf.items['Stop'] = dlg:add_text_input( "", 9, 3, 1, 1 )
            intf.items['b_end'] = dlg:add_button( "Ahora", intf.editor.get_time2, 10, 3, 1, 1)

            intf.items['l_desc'] = dlg:add_label( "Descripción: ", 8, 4, 1, 1 )
            intf.items['Desc'] = dlg:add_text_input( "",9, 4, 2, 1 )

            intf.items['l_type'] = dlg:add_label( "Tipo: ", 8, 5, 1, 1 )
            intf.items['Type'] = dlg:add_dropdown(9, 5, 1, 1)

            

            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)
            
            intf.editor.dropdown = {}
            for k,v in pairs( intf.main.label ) do
                table.insert( intf.editor.dropdown, k )
                local i = table.maxn( intf.editor.dropdown )
                intf.items['Type']:add_value( v, i )
            end
            
            intf.items['b_preview'] = dlg:add_button( "Previsualizar", intf.editor.preview, 8, 6, 1, 1)
            intf.items['b_add'] = dlg:add_button( "Añadir escena", intf.editor.add_value, 9, 6, 1, 1)
            intf.items['b_edit'] = dlg:add_button( "Editar selección", intf.editor.edit, 10, 6, 1, 1)

            --intf.items['space'] = dlg:add_label( "", 9, 7, 1, 1 )

            intf.items['b_next'] = dlg:add_button( "Siguiente", intf.editor.nextframe, 10, 7, 1, 1)
            intf.items['b_previous'] = dlg:add_button( "Anterior", intf.editor.previousframe, 8, 7, 1, 1)
            intf.items['b_play'] = dlg:add_button( "Play / Pause", intf.editor.play, 9, 7, 1, 1)

            intf.items['space2'] = dlg:add_label( "", 9, 9, 1, 1 )

            intf.items['b_load'] = dlg:add_button( "Cargar", intf.editor.load, 7, 10, 1, 1)
            intf.items['b_upload'] = dlg:add_button( "Subir", fcinema.upload, 8, 10, 1, 1)
            intf.items['b_save'] = dlg:add_button( "Guardar", fcinema.save, 9, 10, 1, 1)
            intf.items['b_back'] = dlg:add_button( "Volver", intf.editor.close, 10, 10, 1, 1)
            
            intf.editor.fill_scenes()
            collectgarbage()
        end,

        --[[upload = function ( ... )
            intf.change_dlg()
            intf.items['l_token'] = dlg:add_label( "Introduce tu token", 1, 1, 1, 1 )
            intf.items['token'] = dlg:add_text_input( config.options.token , 2, 1, 3, 1 )
            intf.items[]
            fcinema.upload()
            intf.editor.show()
        end,]]--

        load = function ( ... )
            local path = intf.items['Desc']:get_text()
            local data = fcinema.read( path )
            if data then
                fcinema.data = nil
                fcinema.data = data
                intf.editor.fill_scenes()
                intf.msg( "Fichero leido con exito")
            else
                intf.msg( "Escribe la ruta del fichero en el campo descripción")
            end
        end,

        close = function ( ... )
            edl.deactivate()
            intf.main.show()
        end,

        nextframe = function ( ... )
            --TODO: change this
            t = media.get_time()
            if not t then return end
            media.go_to( t + 1 / 30 )
        end,

        previousframe = function ( ... )
            --TODO: change this
            t = media.get_time()
            if not t then return end
            media.go_to( t - 1 / 30 )
        end,

        status = nil,

        play = function ( ... )
            
            local status = intf.editor.status
            if status == nil then
                status = vlc.playlist.status()
            end

            if status == 'playing' then
                vlc.playlist.pause()
                intf.editor.status = "paused"
            elseif status == 'paused' then
                vlc.playlist.play()
                intf.editor.status = "playing"
            end

        end,

        preview = function ( ... )
            if edl.active then
                edl.deactivate()
                --intf.items['b_preview']:set_text( "Previsualizar")
            else
                edl.start[1] = intf.to_sec( intf.items["Start"]:get_text() )
                edl.stop[1] = intf.to_sec( intf.items["Stop"]:get_text() ) 
                media.go_to( edl.start[1] - 5 )
                vlc.playlist.play()
                --intf.items['b_preview']:set_text( "Parar preview")
                vlc.var.add_callback( vlc.object.input(), "intf-event", edl.check )
                edl.active = true
            end
        end,        

        get_time = function ()
            local str = intf.to_hour( media.get_time() , 1000 )
            intf.items["Start"]:set_text( str )        
        end,

        get_time2 = function ()
            local str = intf.to_hour( media.get_time() , 1000 )
            intf.items["Stop"]:set_text( str )            
        end,

        add_value = function ( )
            local start = intf.to_sec( intf.items["Start"]:get_text() )
            local stop = intf.to_sec( intf.items["Stop"]:get_text() )
            local desc = intf.items["Desc"]:get_text()
            local typ_num = intf.items["Type"]:get_value()

            local typ = intf.editor.dropdown[typ_num]

            intf.editor.add_scene( start, stop, typ, desc, nil )
        end,

        edit = function (  )
            local tab = intf.items['list']:get_selection( )
            local data = fcinema.data
            local start, stop, desc, typ
            for k,v in pairs( tab ) do
                start = data['start'][k]
                stop = data['stop'][k]
                desc = data['desc'][k]
                typ = data['type'][k]
                table.remove( data['start'], k )
                table.remove( data['stop'], k )
                table.remove( data['desc'], k )
                table.remove( data['type'], k )
                break
            end

            stop  = intf.to_hour( stop, 1000 )
            intf.items["Stop"]:set_text( stop )

            start  = intf.to_hour( start, 1000 )
            intf.items["Start"]:set_text( start )

            intf.items["Desc"]:set_text( desc )

            intf.editor.fill_scenes()

        end,

        add_scene = function ( start, stop, typ, desc, i )
            local data = fcinema.data

            if not start or not stop or desc == '' then
                intf.msg( intf.sty.err( "Error: " ) .. " Por favor pon datos validos")
                return
            end
            intf.msg("")

            if not data['stop'] then
                fcinema.data['start'] = {}
                fcinema.data['stop'] = {}
                fcinema.data['desc'] = {}
                fcinema.data['type'] = {}
            end

            if not i then
                i = table.maxn( data['start'] ) + 1
            end

            start_h = intf.to_hour( start, 1 )
            stop_h = intf.to_hour( stop, 1 )
            intf.items['list']:add_value( start_h .." ".. stop_h.." "..typ.." "..desc, i )

            --TODO: overwrite the same??
            data['start'][i] = start
            data['stop'][i] = stop
            data['type'][i] = typ
            data['desc'][i] = desc
            
        end,

        fill_scenes = function()
            intf.items['list']:clear()
            local data = fcinema.data
            for k,v in pairs( data['desc'] ) do
                intf.editor.add_scene( data['start'][k], data['stop'][k], data['type'][k], data['desc'][k], k )
            end
        end,
    },
    
    help = {
        show = function (  )
            intf.change_dlg()
            intf.items['help'] = dlg:add_html( intf.help.text, 1, 1, 4, 1)
            intf.items['trick'] = dlg:add_label(string.rep ("&nbsp;", 100), 1, 2, 3, 1)
            intf.items['back'] = dlg:add_button( "Atras", intf.main.show, 4, 2, 1, 1)
            collectgarbage()
        end,

        text = "Ayuda sobre como usar fcinema <br>" ..
        "un poco de about y thanks a opensub ... <br>"..
        "película erronea <br>" ..
        "sincronización manual <br>"..
        "...",
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
            return "<center><h1>"..str.."</h1></center>"
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
    os = "",
    version = "0.0",
    agent = "vlc",
    slash = '/',
    path = nil,
    offline_db = "offline.txt",
    db = "fcinema.txt",
    options = {
        lang = "esp", --os.getenv("LANG"),
        token = "1234",
    },

    load = function ( ... )
        
        os.setlocale( 'C' )
        json = require ("dkjson")
        
        find_path()
        
        local data = system.read( config.path .. 'config.json')
        if data then
            local options = json.decode( data )
            if options then
                config.options = options
            end
        end
        
    end,

    save = function ( ... )
        system.write( config.path .. 'config.json', json.encode( config.options ) )
    end,
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
        edl.start = {}
        edl.stop = {}
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
            if t < stop - 1 and t > edl.start[i] - 0.175 then
                -- TODO: allow different actions
                media.go_to ( stop )
                return
            end
        end
    end,

}

------------------------------- fcinema.org ---------------------------------------

fcinema = {

    api_url = "http://fcinema.org/api.php",
    data = nil, --{ ['start'] = {}, ['stop'] = {}, ['desc'] = {}, ['type'] = {} },

    search = function( id )
        fcinema.data = nil
        fcinema.data = {}
        local data = nil

    -- Try files in offline mode
        if not id then
            vlc.msg.dbg( "Looking files in offline mode")
            id = fcinema.hash2id( config.offline_db )
            if id then
                data = fcinema.read( config.path ..  id .. '.json')
            end
        end

    -- Try net
        if data == nil then
            vlc.msg.dbg( "Looking on fcinema.org")
            data = fcinema.search_online( id, media.file.hash, media.file.bytesize, media.file.name )
            if data and data['new_version'] then
                intf.loading.show()
                intf.msg( "Nueva versión desponible " .. data['new_version'] )
                return
            end
        end
    
    -- Try local cache
        if data == nil or ( not data['title'] and not data['titles'] ) then
            vlc.msg.dbg( "Looking on local cache")
            id = fcinema.hash2id( config.db )
            if id then
                data = fcinema.read( config.path ..  id .. '.json')
            end
        end
        
    -- Parse received data
        if not data or data['error'] then
            intf.confirm_movie.show()
            intf.msg( "Lo sentimos no hay información disponible")
        elseif data['title'] then
            vlc.msg.dbg( "Readed: " .. json.encode( data ) .."\n" )
            fcinema.data = data
            intf.main.show()
        elseif data['titles'] then
            vlc.msg.dbg( "Readed: " .. json.encode( data ) .."\n" )
            fcinema.data = data
            intf.confirm_movie.show()
        end        
                
        return true
    end,

    search_online = function ( imdb_code, hash, bytesize, name )
        fcinema.data = nil
        fcinema.data = {}
        local params = ""
        params = params .. "action=search"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
        params = params .. "&lang=" .. config.options.lang
        if imdb_code then params = params .. "&imdb_code=" .. imdb_code end
        if bytesize then params = params .. "&bytesize=" .. bytesize end
        if hash then params = params .. "&hash=" .. hash end
        if name then params = params .. "&filename=" .. name end

        local status, response = net.post( params, fcinema.api_url )
        if not response then return end
        local data = string.match(response, '{(.+)}')
        if data then
            data = json.decode( '{'..data..'}' )
            if data and data['title'] then
                fcinema.data = data
                fcinema.save( config.db )
            end
            return data
        end
        
    end,

    feedback = function ( name, email, idea )
        local params = ""
        params = params .. "action=feedback"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
        params = params .. "&name=".. name
        params = params .. "&email=".. email
        params = params .. "&idea=".. idea 

        local status, response = net.post( params, fcinema.api_url )
        if response then
            intf.msg( "Feedback enviado, muchas gracias por tu ayuda")
        else
            intf.msg( "Por favor, conectate a internet")
        end
    end,

    upload = function (  )
        local data = json.encode( fcinema.data )
        local params = ""
        params = params .. "action=modify"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
        params = params .. "&imdb_code=" .. fcinema.data['id']
        params = params .. "&data=".. data
        params = params .. "&token=" .. config.options.token
                
        local status, response = net.post( params, fcinema.api_url )
        intf.msg('')
        if response then
            data = string.match(response, '{(.+)}')
            if data then
                data = json.decode( '{'..data..'}' )
                intf.msg( data ) --TODO
            end
        end
        
    end,

    save = function ( db )
        edl.deactivate()
        if not db then db = config.offline_db end
        if not config.path then return end
        
        local file = config.path ..fcinema.data['id'] .. ".json"
        local data = json.encode( fcinema.data )
        system.write( file, data )

        local index = system.read( config.path .. db ) or ""
        index = index .. media.file.hash ..';'..fcinema.data['id']..';0;\n'
        system.write( config.path .. db, index )
        intf.msg( intf.sty.ok( 'Guardado con exito') )
    end,

    hash2id = function ( db )
        vlc.msg.dbg( config.path .. db )
        local data = system.read( config.path .. db )
        if data then
            local id, offset = string.match( data, media.file.hash .. ';(.-);(.-);' )
            if id then
                vlc.msg.dbg( "ID finded! " .. id )
                return id
            end
        end
    end,

    read = function ( file )
        vlc.msg.dbg( file )
        local data = system.read( file )
        if data then
            vlc.msg.dbg( data )
            return json.decode( data )
        end
    end,
    
}

--------------------------------------- SYSTEM ----------------------------------------

system = {

    read = function ( file )
        vlc.msg.dbg( file )
        local tmpFile = io.open( file, "rb")
        if not tmpFile then return false end
        local data = tmpFile:read("*all")
        tmpFile:flush()
        tmpFile:close()
        tmpFile = nil
        collectgarbage()
        return data
    end,

    write = function ( file, str )
        local tmpFile = assert( io.open( file , "wb") )
        tmpFile:write( str )
        tmpFile:flush()
        tmpFile:close()
        tmpFile = nil
        collectgarbage()
        return true
    end,
}

-------------------------------------- SYNC -------------------------------------------

sync = {

    auto = function ( ... )
        
        local borders = sync.get_borders()
        local ref = { 34, 45, 67, 78, 85, 90}
        -- TODO: fps issues when sync ( recognition and apply)
        local offset = sync.borders2offset( borders, ref )
        -- TODO: convert frames offset to ms offset
        sync.apply_offset( offset )

    end,

    get_borders = function ( ... )
        if config.os == "win" then
            os.execute('mkdir "' .. path..'"')
        elseif config.os == "lin" then
            os.execute("mkdir -p '" .. path.."'")
        end
        local borders = { 44, 55, 60, 77, 88, 100}
        return borders
    end,

    borders2offset = function ( ours, ref )
        
        local sum = {}
        local d

        for kr,vr in pairs( ref ) do
            for ko,vo in pairs( ours ) do
                d = vr - vo
                if not sum[ d ] then
                    sum[ d ] = 1
                else
                    sum[ d ] = sum[ d ] + 1
                end
            end
        end

        local max = 0
        local offset
        for k, v in pairs( sum ) do
            if v > max then
                max = v
                offset = k
            end
        end
        vlc.msg.dbg( "Posibles offsets: " .. json.encode( sum ) )
        vlc.msg.dbg( "Offset automático calculado: " .. offset )

        return offset
    end,

    apply_factor = function ( ... )
        -- TODO
    end,

    apply_offset = function ( offset )
        if not type( offset ) == 'number' then return end
        for k,v in pairs( fcinema.data['start']) do
            fcinema.data['start'][k] = fcinema.data['start'][k] + offset
            fcinema.data['stop'][k] = fcinema.data['stop'][k] + offset
        end
        return true
    end,
    
}

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

        intf.msg( "Conectando con el servidor: ".. intf.progress_bar( 40 ) )
        
        local fd = vlc.net.connect_tcp(host, port)

        if not fd or fd == -1 then return false end
        local pollfds = {}
        intf.msg( "Enviando datos: ".. intf.progress_bar( 50 ) )
        pollfds[fd] = vlc.net.POLLIN
        vlc.net.send(fd, request)
        intf.msg( "Esperando respuesta: ".. intf.progress_bar( 70 ) )
        vlc.net.poll(pollfds)
        intf.msg( "Recibiendo respuesta: ".. intf.progress_bar( 80 ) )
        local response = vlc.net.recv(fd, 10024)
        vlc.msg.dbg( response )
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
            vlc.msg.dbg("[Fcinema] file info "..(json.encode(file)))
            vlc.msg.err( item:name() )
            return
        end

        file.name, file.ext = string.match(file.completeName, '^([^/]-)%.?([^%.]*)$')
        
        if file.ext == "part" then
            file.name, file.ext = string.match(file.name, '^([^/]+)%.([^%.]+)$')
        end
        
        file.hasInput = true;
        file.cleanName = string.gsub(file.name, "[%._]", " ")

        vlc.msg.dbg("[Fcinema] file info "..(json.encode(file)))
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


function find_path(  )
    
    local slash

    if is_window_path(vlc.config.datadir()) then
        config.os = "win"
        slash = "\\"
        config.slash = slash
    else
        config.os = "lin"
        slash = "/"
    end

--Posible paths for config
    local userdatadir = vlc.config.userdatadir()
    local datadir = vlc.config.datadir()

    local path_generic = {"lua", "extensions", "userdata", "fcinema"}
    local fcinema_path = slash..table.concat(path_generic, slash)

    local paths = {userdatadir, datadir}

--Check if cache is somewhere out there
    for k,v in pairs( paths ) do
        if file_exist( v .. fcinema_path .. config.db ) then
            config.path = v .. fcinema_path .. slash
            return
        end
    end

--Find place for cache
    for k,v in pairs( paths ) do
        if is_dir(v) and not is_dir( v..fcinema_path) then
            mkdir_p( v..fcinema_path)
        end
        if file_touch( v ..fcinema_path..config.db) then
            config.path = v ..fcinema_path .. slash
        end
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

function is_window_path(path)
    return string.match(path, "^(%a:\\).+$")
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

function trim(str)
    if not str then return "" end
    return string.gsub(str, "^[\r\n%s]*(.-)[\r\n%s]*$", "%1")
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

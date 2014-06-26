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
        capabilities = { "input-listener"}
    }
end

function activate()

    config.load()

    vlc.msg.dbg("[Fcinema] Welcome")

    intf.loading.show()

    media.get_info()

end


--[[
TODO escuchar inputs del teclado

vlc.var.add_callback( vlc.object.libvlc(), "key-pressed", key_press )
function key_press( var, old, new, data )
  local key = new
  vlc.msg.dbg( key )
end
]]--



function close()
    deactivate()
end

function deactivate()
    vlc.msg.dbg("[Fcinema] Bye bye!")

    if dlg then dlg:hide() end

    edl.deactivate()

    config.save()

    fcinema.save()

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
function meta_changed( ... )
    -- body
end

function input_changed()
    --TODO: On DVD input change constantly
    --edl.deactivate()
    vlc.msg.dbg( '[Fcinema] Input changed' )
    
end

---------------------------- LANGUAGE -------------------------------------

style = {
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
}

lang = {
    which_movie = "<b><h3><center>¿Que película estas viendo?</center></h3></b>",
    view_movie = "Ver película",
    name_search = "Buscar por nombre",
    selec = "Seleccionar",
    b_help = "Ayuda",
    add_new = "Añadir nueva",
    incomplete_info = style.err("Atención: ").."la información de esta película puede estar incompleta",
    advanced = "Avanzado",
    init = '<b><i>Inicio</i></b>',
    help = "Ayuda sobre como usar fcinema <br>" ..
        "un poco de about y thanks a opensub ... <br>"..
        "película erronea <br>" ..
        "calibración manual <br>"..
        "...",
    ------ Advanced -------------
    l_editor = "Crea tu propia lista de escenas: ",
    b_editor = "Editor",
    l_donate = "Ayuda a mantener fcinema: ",
    b_donate = "Donar",
    l_sync = "Calibración manual: ",
    b_sync = "Calibrar",
    l_feedback = "Tu opinión nos importa: ",
    b_feedback = "Enviar feedback",
    l_bad_movie = "No es esta la película que estas viendo: ",
    b_bad_movie = "Cambiar película",
    b_auto_sync = "Auto sync",
    back = "Atras",
    msg_donate = "Todo sobre como ayudar en en <a href='http://www.fcinema.org/'>fcinema.org</a>",
    b_change_lang = "Cambiar idioma",
    --------- Editor -----------------
    preview = "Previsualizar",
    add_scene = "Añadir",
    delete_scene = "Eliminar",
    modify_scene = "Modificar",
    cache = "Recientes",
    share = "Compartir",
    invalid_data = style.err("Error: ") .. " No puede haber campos vacios",
    now = "Ahora",
    ---------- Manual sync ------------
    insert_offset = "Introduce los segundos de desfase: ",
    apply_offset = "Aplicar offset",
    cancel = "Cancelar",
    ----- Movie selector
    recent_files_folder = "Los ficheros deben estar en la carpeta ",
    new_movie_warning = style.err("Importante:").." Asegurese de que la película realmente no esta",
}

---------------------------- INTERFACE ------------------------------------

local dlg = nil

intf = {
    
    ------------------------- Loading message interface --------------------------------

    loading = {
        show = function ( )
            intf.change_dlg()
            intf.items["message"] = dlg:add_label("", 1, 1, 4, 1)
        end,
    },

    --------------------------- Selecting movie interface --------------------------------

    select_movie = {
        show = function ( ... )
        -- Display interface for selecting movie
            intf.change_dlg()
            intf.items['header'] = dlg:add_label( lang.which_movie, 1, 1, 4, 1 )
            intf.items['list'] = dlg:add_list( 1, 3, 7, 7 )
            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)
            intf.items['title'] = dlg:add_text_input( media.file.cleanName, 1, 2, 6, 1 )
            intf.items['b_search'] = dlg:add_button( lang.name_search, intf.select_movie.search_name_online, 7, 2, 1, 1 )
            intf.items['b_choose'] = dlg:add_button( lang.selec, intf.select_movie.choose, 7, 11, 1, 1 )
            intf.items['b_cache'] = dlg:add_button( lang.cache, intf.select_movie.cache, 2, 11, 1, 1)
            intf.items['local'] = dlg:add_button( lang.add_new, intf.select_movie.new.show, 1, 11, 1, 1 )

            intf.select_movie.fill_movies()
        end,

        fill_movies = function ( ... )
        -- Display list of possible movies
            intf.items['list']:clear()
            local movie_list = fcinema.movie_list
            if not movie_list or not movie_list['Titles'] then return end
            for k,v in pairs( movie_list['Titles'] ) do
                local desc = string.gsub( movie_list['Directors'][k], "%s+", " ")
                intf.items['list']:add_value( movie_list['Titles'][k]..' ('..desc..')', k )
            end
        end,

        cache = function ( ... )
        -- Display movies stored in cache

        -- Prepare stuff
            intf.items['list']:clear()
            fcinema.movie_list = {}
            fcinema.movie_list['IDs'] = {}
        -- Retrieve ALL files in config path (not just movies)
            local dir_list = vlc.net.opendir( config.path )
        -- Read file content, if it's a movie, show title and desc
            for k,v in pairs( dir_list ) do
                local movie = fcinema.read( config.path .. v )
                if movie and type(movie)~= 'number' and movie['title'] then
                    local desc = string.gsub( movie['director'] or 'Unkown', "%s+", " ")
                    fcinema.movie_list['IDs'][k] = movie['id']--string.gsub( v, '.json', '')
                    intf.items['list']:add_value( movie['title']..' ('..desc..')', k )
                end
            end
            intf.msg( lang.recent_files_folder .. config.path )
        end,

        search_name_online = function ( ... )
        -- Search movie name online
            media.file.name = intf.items["title"]:get_text()
            media.file.cleanName = media.file.name
            local movie_list = fcinema.search_online( nil, nil, nil, media.file.name )
            fcinema.movie_list = movie_list
            intf.select_movie.fill_movies()
            intf.msg("")
        end,

        choose = function ( ... )
            local k = get_list_selection()
            local id = fcinema.movie_list['IDs'][k]
            media.file.name = intf.items["title"]:get_text()
            media.file.cleanName = media.file.name
            fcinema.search( id )
            vlc.msg.dbg('[Fcinema] Selected '..id )
            fcinema.add2index( config.path .. config.user_modified_db )
        end,

        new = {
        -- Dialog for adding new movies

            show = function( ... )
            -- Show the dialog, request title, director...
                local title = intf.items["title"]:get_text()
                intf.change_dlg()

                intf.items['l_name'] = dlg:add_label( lang.new_movie_warning, 1, 1, 5, 1 )
                
                intf.items['l_title'] = dlg:add_label( "Título: ", 1, 2, 2, 1 )
                intf.items['title'] = dlg:add_text_input( title, 3, 2, 3, 1 )

                intf.items['l_director'] = dlg:add_label( "Director: ", 1, 3, 2, 1 )
                intf.items['director'] = dlg:add_text_input( "", 3, 3, 3, 1 )

                intf.items["message"] = dlg:add_label("", 1, 4, 3, 1)

                intf.items['b_send'] = dlg:add_button( "Añadir", intf.select_movie.new.add, 5, 5, 1, 1 )         
                intf.items['b_back'] = dlg:add_button( lang.back, intf.select_movie.show, 1, 5, 1, 1)
            end,

            add = function ( ... )
                local data = { ['Scenes'] = {} }
                data['Title'] = intf.items["title"]:get_text()
                data['Director'] = intf.items["director"]:get_text()
                data['ImdbCode'] = 'p'..media.file.hash   -- Add 'p' to specify manually added movie
                fcinema.load_movie( data )
                fcinema.add2index( config.path .. config.user_modified_db )
                fcinema.save()
                intf.main.show()
            end,
        },

    }, 

    ------------------------------ MAIN ------------------------------
    main = {
        show = function()

            intf.change_dlg()
            
            intf.main.actions = {}
            intf.main.button = {}

            intf.main.create_list()

            local title = style.tit( fcinema.data['Title'] ) or style.tit( ' ' )
            intf.items["title"] = dlg:add_label( title, 1, 1, 7, 1)
            intf.items["director"] = dlg:add_label( '<i><center>'..(fcinema.data['Director'] or '')..'</center></i>', 1, 2, 7, 1)
            --intf.items["pg"] = dlg:add_label( fcinema.data['PGCode'] or ' ', 3, 2, 1, 1)

            intf.items['advanced'] = dlg:add_button( lang.advanced, intf.advanced.show, 3, 11, 2, 1)
            intf.items['help'] = dlg:add_button( lang.b_help, intf.help.show, 1, 11, 1, 2)
            intf.items['watch'] = dlg:add_button( lang.view_movie, intf.main.list_view, 5, 11, 1, 1)
          
            intf.items["message"] = dlg:add_label("", 1, 10, 10, 1)

            --intf.main.show_poster()
            --intf.main.toggle_list()

            --intf.items['l_levels'] = dlg:add_label( '<center><i>Filtering level 0.Off - 5.Strict</center></i>', 1, 2, 3, 1 ) --TODO
            intf.main.show_category( 's', 3, 5 )
            intf.main.show_category( 'v', 4, 7 )
            intf.main.show_category( 'p', 5, 8 )
            intf.main.show_category( 'd', 6, 9 )
            intf.items['imdb_parentguide'] = dlg:add_label("<a href='http://www.imdb.com/title/"..fcinema.data['ImdbCode'].."/parentalguide'>IMDB Parents Guide</a>", 5,5,1,1)
            intf.items['kids-in-mind'] = dlg:add_label("<a href='http://www.kids-in-mind.com/cgi-bin/search/search.pl?q="..fcinema.data['Title'].."'>Kids In Mind Guide</a>",5,4,1,1)
            intf.main.apply_level()
            intf.main.show_warning()
            collectgarbage()
        end,

        show_warning = function ( ... )
            if not fcinema.data['Complete'] then
                intf.msg( lang.incomplete_info )
            end
        end,

        list_view = function ( ... )
            intf.main.apply_level()
            intf.change_dlg()
            intf.items["l_info"] = dlg:add_label("Fcinema eliminará las escenas con *", 5, 1, 5, 1)
            intf.items["message"] = dlg:add_label("", 5, 9, 5, 1)
            intf.main.show_warning()
            intf.items['watch'] = dlg:add_button( lang.view_movie, intf.main.watch_movie, 8, 8, 1, 1)
            intf.items['back'] = dlg:add_button( "Atras", intf.main.show, 5, 8, 1, 1)
            intf.main.toggle_list()
        end,

        show_poster = function ()
            local poster = fcinema.data['Poster']
            if poster then
                local dst = config.path..fcinema.data['ImdbCode']..'.jpg'
                if not file_exist( dst ) then
                    net.downloadfile( poster, dst )
                end
                if file_exist( dst ) then
                    intf.items["image"] = dlg:add_image( dst,  1, 1, 1, 2 )
                end
            end
        end,

        show_category = function ( label, pos, preselect )
            local preselect = config.options['l_'..label]
            --intf.del( 'l_'..label )
            --intf.del( 'level'..label )
            intf.items['l_'..label] = dlg:add_label( '<b><i>'..intf.main.label[label]..'</b></i>', 1, pos, 2, 1)
            intf.items['level'..label] = dlg:add_dropdown( 3, pos, 1, 1)
            if preselect then intf.items['level'..label]:add_value( intf.main.levels[preselect], preselect ) end
            for i=0,5 do
                intf.items['level'..label]:add_value( intf.main.levels[i], i )
            end
            --intf.items['count'..label] = dlg:add_label( '3 skips (12s)', 5, pos, 1, 1)
        end,

        levels = {
            [0] = '0. Desactivado',
            [1] = '1. Muy laxo',
            [2] = '2. Laxo',
            [3] = '3. Moderado',
            [4] = '4. Estricto',
            [5] = '5. Muy estricto'
        },

        label = {
            ['s'] = 'Sex & Nudity',
            ['v'] = 'Violence & Gore',
            ['p'] = 'Profanity',
            ['d'] = 'Drugs',
            ['syn'] = 'Sync'
        },


        watch_movie = function ( ... )
        -- Be sure scene are synced
            if sync.lock() then return end
        -- Read all values and start playback
            edl.activate()
        end,

        toggle_list = function( ... )
           if not intf.items['scene_list'] then
                intf.items['scene_list'] = dlg:add_list( 5, 3, 4, 4 )
                intf.main.fill_list()
                intf.items['b_skip'] = dlg:add_button( 'Skip', intf.main.skip, 6, 8, 1, 1)
                intf.items['b_nskip'] = dlg:add_button( 'No skip', intf.main.nskip, 7, 8, 1, 1)
            else
                intf.del( 'scene_list' )
            end
        end,

        fill_list = function()
            if not intf.items['scene_list'] then return end
            intf.items['scene_list']:clear()
            local data = fcinema.data
            local txt, level, typ, desc
            for k,v in pairs( data['Scenes'] ) do
                if intf.main.actions[k] then txt = '*' else txt ='  ' end
                level = v['Severity']
                typ = v['Category']
                desc = v['AdditionalInfo'] or ''
                intf.items['scene_list']:add_value( txt..level..typ..' '..desc, k )
            end
        end,

        skip = function( ... )
            local tab = intf.items['scene_list']:get_selection( )
            for k,v in pairs( tab ) do
                intf.main.actions[k] = true
            end
            intf.main.fill_list()
        end,

        nskip = function( ... )
            local tab = intf.items['scene_list']:get_selection( )
            for k,v in pairs( tab ) do
                intf.main.actions[k] = false
            end
            intf.main.fill_list()
        end,

        apply_level = function()

            intf.main.actions = {}
            for cat,v1 in pairs(intf.main.label) do
                if intf.items['level'..cat] then
                    local level = intf.items['level'..cat]:get_value()
                    config.options['l_'..cat] = level
                    if intf.main.list[cat] then
                        for k,v in pairs( intf.main.list[cat] ) do
                            if fcinema.data['Scenes'][v]['Severity'] + level <= 5 then
                                intf.main.actions[v] = false
                                vlc.msg.dbg( 'no skip '..v)
                            else
                                intf.main.actions[v] = true
                                vlc.msg.dbg( 'skip '..v)
                            end
                        end
                    end
                end
            end
            intf.main.fill_list()
        end,

        create_list = function ( ... )
        -- Creates a list of all scenes classified by type
            -- e.g list['violence'] = { scene 4, scene 9 }

            intf.main.list = {}
            if not fcinema.data['Scenes'] then return end
            for k,v in pairs( fcinema.data['Scenes'] ) do
                local category = v['Category']
                if category ~= 'syn' then
                    if not intf.main.list[category] then
                        intf.main.list[category] = {}
                    end
                    table.insert( intf.main.list[category], k )
                    intf.main.actions[category] = true
                end
            end
            vlc.msg.dbg( json.encode( intf.main.list ) )
        end,
    },




    ------------------------------ Advanced dialog interface ------------------------------------
    advanced = {
        show = function ( ... )
            intf.main.apply_level()
            intf.change_dlg()
            intf.items['l_editor'] = dlg:add_label( lang.l_editor, 1, 2, 3, 1 )
            intf.items['b_editor'] = dlg:add_button( lang.b_editor, intf.editor.show, 4, 2, 1, 1)

            intf.items['l_donate'] = dlg:add_label( lang.l_donate, 1, 3, 1, 1 )
            intf.items['b_donate'] = dlg:add_button( lang.b_donate, intf.advanced.donate, 4, 3, 1, 1)

            intf.items['l_sync'] = dlg:add_label( lang.l_sync, 1, 4, 1, 1 )
            intf.items['b_sync'] = dlg:add_button( lang.b_sync, intf.manual_sync.show, 4, 4, 1, 1)

            intf.items['l_bad_movie'] = dlg:add_label( lang.l_bad_movie, 1, 5, 1, 1 )
            intf.items['b_bad_movie'] = dlg:add_button( lang.b_bad_movie, intf.advanced.bad_hash, 4, 5, 1, 1)

            intf.items['l_feedback'] = dlg:add_label( lang.l_feedback, 1, 6, 1, 1 )
            intf.items['b_feedback'] = dlg:add_button( lang.b_feedback, intf.advanced.feedback, 4, 6, 1, 1)

            --intf.items['b_auto_sync'] = dlg:add_button( lang.b_auto_sync, sync.auto, 4, 7, 1, 1 )

            intf.items['b_change_lang'] = dlg:add_button( lang.b_change_lang, intf.advanced.lang, 4, 7, 1, 1 )

            --intf.items['l_contribute'] = dlg:add_label( "Fcinema esta desarrollado por una comunidad de voluntarios" ,1, 6, 1, 1 )
            intf.items['language'] = dlg:add_dropdown( 3, 7, 1, 1)
            intf.items['language']:add_value( "Spanish", 2 )
            intf.items['language']:add_value( "English", 1 )

            intf.items["message"] = dlg:add_label("", 1, 8, 7, 1)
            --intf.items['l_main'] = dlg:add_label( "Empieza: ", 1, 5, 1, 1 )
            intf.items['b_main'] = dlg:add_button( lang.back, intf.main.show, 4, 9, 1, 1)
        end,

        donate = function ( ... )
            intf.msg( lang.msg_donate )
            net.openurl( 'http://www.fcinema.org/donate' )
        end,

        feedback = function ( ... )
            --intf.feedback.show()
            net.openurl( 'http://www.fcinema.org' )
        end,

        lang = function ( ... )
            system.write( config.path .. "saved.json", json.encode(lang) )
            local lang_id = intf.items['language']:get_value()
            if lang_id == 1 then
                config.options.lang = "eng"
                config.load_lang( "eng" )
            elseif lang_id == 2 then
                config.options.lang = "esp"
                config.load_lang( "esp" )
            end
        end,

        bad_hash = function ( ... )
            --fcinema.data = nil
            --local data = fcinema.search_online( nil, nil, nil, media.file.name )
            --fcinema.data = data
            intf.select_movie.show()
        end,
    },

    
    feedback = {     

        show = function ( ... )

            intf.change_dlg()

            intf.items['l_name'] = dlg:add_label( "Nombre (opcional): ", 1, 1, 2, 1 )
            intf.items['name'] = dlg:add_text_input( "", 3, 1, 3, 1 )

            intf.items['l_mail'] = dlg:add_label( "Email (opcional): ", 1, 2, 2, 1 )
            intf.items['mail'] = dlg:add_text_input( "", 3, 2, 3, 1 )

            intf.items['l_comment'] = dlg:add_label( "Sugerencia: ", 1, 3, 2, 1 )
            intf.items['comment'] = dlg:add_text_input( "", 3, 3, 3, 1 )
            --intf.items['trick'] = dlg:add_label("&nbsp;", 1, 4, 2, 1)

            intf.items["message"] = dlg:add_label(" ", 1, 5, 3, 1)

            intf.items['b_send'] = dlg:add_button( "Enviar feedback", intf.feedback.send, 4, 5, 1, 1 )
            intf.items['b_back'] = dlg:add_button( lang.back, intf.advanced.show, 1, 5, 1, 1)

        end,

        send = function ( ... )
            local name = intf.items['name']:get_text()
            local mail = intf.items['mail']:get_text()
            local comment = intf.items['comment']:get_text()
            fcinema.feedback( name,mail,comment)
        end,

    },

    manual_sync = {
        
        show = function ( ... )
            intf.change_dlg()

            intf.items['l_now'] = dlg:add_label( style.ok("Tip: ").. 'Haz click en "Ahora" justo cuando veas', 1, 1, 5, 1 )
            intf.items['l_desc'] = dlg:add_label( 'aparecer ' .. (fcinema.data['SyncScenes'][1]['AdditionalInfo'] or ''), 1, 2, 5, 1 )
            
            intf.items['b_sync_now'] = dlg:add_button( lang.now, intf.manual_sync.now, 3, 3, 1, 1 )            

            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)
            intf.items['b_ok'] = dlg:add_button( 'Cancelar', intf.advanced.show, 5, 10, 1, 1)

            intf.items['b_back2'] = dlg:add_button( "<<", intf.manual_sync.jump_backward_2, 1, 7, 1, 1)
            intf.items['b_back'] = dlg:add_button( "<", intf.manual_sync.jump_backward_1, 2, 7, 1, 1)
            intf.items['b_toggle'] = dlg:add_button( "Play / Pause", intf.editor.toggle, 3, 7, 1, 1)
            intf.items['b_next'] = dlg:add_button( ">", intf.manual_sync.jump_fordward_1, 4, 7, 1, 1)
            intf.items['b_next2'] = dlg:add_button( ">>", intf.manual_sync.jump_fordward_2, 5, 7, 1, 1)

            media.go_to( fcinema.data['SyncScenes'][1]['Start'] - 60 ) -- TODO not sure about this
            vlc.playlist.play()

        end,

        jump_backward_1 = function() media.jump( -0.3 ) end,
        jump_fordward_1 = function() media.jump( 0.1 ) end,
        jump_backward_2 = function() media.jump( -2.1 ) end,
        jump_fordward_2 = function() media.jump( 2 ) end,

        now = function ( )

        -- Apply offset
            local t = media.get_time()
            if not t then return end
            local offset = t - fcinema.data['SyncScenes'][1]['Start']
            sync.apply_offset( offset )
            sync.status = 1

        -- Modify interface (if it was not modified)
            if not intf.items['b_preview'] then
                intf.items["l_now"]:set_text( style.ok('Genial!')..' la escena debería haber desaparecido, si todavía ves el comienzo' )
                intf.items["l_desc"]:set_text('o el final, reajusta el comienzo usando las flechas y "Ahora"')
                intf.items['b_preview_o'] = dlg:add_button( "Ver escena original", intf.manual_sync.preview_o, 4, 3, 2, 1 )
                intf.items['b_preview'] = dlg:add_button( "Ver escena cortada", intf.manual_sync.preview, 1, 3, 2, 1 )
                intf.items['b_ok']:set_text( 'Listo' )
            end

        -- Launch scene preview
            intf.manual_sync.preview()

        end,

        preview_o = function ( ... )
        -- Preview original scene
            media.go_to( fcinema.data['SyncScenes'][1]['Start'] - 5 )
            vlc.playlist.play()
        end,

        preview = function ( ... )
        -- Preview modified scene
            edl.start[1] = fcinema.data['SyncScenes'][1]['Start']
            edl.stop[1] = fcinema.data['SyncScenes'][1]['Stop']

            media.go_to( edl.start[1] - 5 )
            vlc.playlist.play()
            if edl.preview_active == 0 then
                vlc.var.add_callback( vlc.object.input(), "intf-event", edl.one_time_preview )
            end
            vlc.msg.dbg("[Fcinema] Preview started")
            edl.preview_active = 1
        end,
    },


    ------------------------------- Editor dialog -----------------------------------

    editor = {

        dropdown = {},

        show = function (  )
            --if sync.lock then return end
            intf.change_dlg()

            intf.items['list'] = dlg:add_list( 1, 1, 4, 6 )

            intf.items['l_start'] = dlg:add_button( "Empieza: ", intf.editor.go2start, 7, 3, 1, 1 )
            intf.items['Start'] = dlg:add_text_input( "", 8, 3, 2, 1 )
            intf.items['b_start'] = dlg:add_button( lang.now, intf.editor.get_time, 10, 3, 1, 1)

            intf.items['l_end'] = dlg:add_button( "Termina: ", intf.editor.go2end, 7, 4, 1, 1 )
            intf.items['Stop'] = dlg:add_text_input( "", 8, 4, 2, 1 )
            intf.items['b_end'] = dlg:add_button( lang.now, intf.editor.get_time2, 10, 4, 1, 1)

            intf.items['l_desc'] = dlg:add_label( "Descripción: ", 7, 7, 1, 1 )
            intf.items['Desc'] = dlg:add_text_input( "",8, 7, 2, 1 )

            intf.items['l_type'] = dlg:add_label( "Tipo y nivel: ", 7, 5, 1, 1 )
            intf.items['Type'] = dlg:add_dropdown( 8, 5, 2, 1)
            intf.items['level'] = dlg:add_dropdown( 10, 5, 1, 1)
            for i=1,5 do
                intf.items['level']:add_value( i, i )
            end

            intf.items['l_action'] = dlg:add_label( "Acción", 7, 6, 2, 1 )
            intf.items['Action'] = dlg:add_dropdown( 8, 6, 1, 1)
            intf.items['Action']:add_value( "Saltar", 1 )
            intf.items['Action']:add_value( "Sin sonido", 2 )
            intf.items['Action']:add_value( "Sin imagen", 3 )
            intf.items['Action']:add_value( "Descripción", 4 )
            

            intf.items["message"] = dlg:add_label("", 1, 8, 7, 1)
            
            intf.editor.dropdown = {}
            for k,v in pairs( intf.main.label ) do
                table.insert( intf.editor.dropdown, k )
                local i = table.maxn( intf.editor.dropdown )
                intf.items['Type']:add_value( v, i )
            end

            intf.items['b_preview'] = dlg:add_button( lang.preview, intf.editor.preview, 8, 2, 2, 1)
            intf.items['b_add'] = dlg:add_button( lang.add_scene, intf.editor.add_scene, 2, 7, 1, 1)
            intf.items['b_delete'] = dlg:add_button( lang.delete_scene, intf.editor.delete_scene, 1, 7, 1, 1)
            intf.items['b_modify'] = dlg:add_button( lang.modify_scene, intf.editor.modify, 3, 7, 2, 1)

            intf.items['b_back2'] = dlg:add_button( "<<", intf.manual_sync.jump_backward_2, 7, 1, 1, 1)
            intf.items['b_back'] = dlg:add_button( "<", intf.manual_sync.jump_backward_1, 7, 2, 1, 1)
            intf.items['b_toggle'] = dlg:add_button( "Play / Pause", intf.editor.toggle, 8, 1, 2, 1)
            intf.items['b_next'] = dlg:add_button( ">", intf.manual_sync.jump_fordward_1, 10, 2, 1, 1)
            intf.items['b_next2'] = dlg:add_button( ">>", intf.manual_sync.jump_fordward_2, 10, 1, 1, 1)

            intf.items['b_upload'] = dlg:add_button( lang.share, intf.editor.request_pass, 8, 8, 2, 1)
            intf.items['b_cancel'] = dlg:add_button( lang.back, intf.main.show, 10, 8, 1, 1)
            
            collectgarbage()
            intf.editor.fill_list()

        end,

        request_pass = function ( ... )
        -- Deny, movie is not identified globaly (??)
            if string.match( fcinema.data['ImdbCode'], 'p' ) then
                intf.msg( style.err("Imposible").." compartir ficheros locales")
                return
            end

        -- Deny, no scene for manual sync
            local have_sync = false
            if fcinema.data['type'] then
                for k,v in pairs( fcinema.data['type'] ) do
                    if v ~= 'syn' then
                        have_sync = true
                        break
                    end
                end
            end
            if not have_sync then
                intf.msg( style.err("Espera ").."antes debes crear una escena de calibración manual")
                return
            end

        -- Deny, movie is out of sync
            if sync.lock() then return end
            
            intf.change_dlg()
            intf.items['l_name'] = dlg:add_label( "Nombre usuario: ", 1, 1, 1, 1 )
            intf.items['i_name'] = dlg:add_text_input( config.options.name, 2, 1, 1, 1 )
            intf.items['l_pass'] = dlg:add_label( "Contraseña: ", 1, 2, 1, 1 )
            intf.items['i_pass'] = dlg:add_password( "", 2, 2, 1, 1 )

            intf.items['l_new_user'] = dlg:add_label( "¿Aun no eres usuario? <a href='http://www.fcinema.org/'>Crear una cuenta</a>", 1, 3, 2, 1 )
            --intf.items['message'] = dlg:add_label( "", 1, 4, 2, 1 )
            intf.items['b_upload'] = dlg:add_button( "Compartir", intf.editor.upload, 2, 4, 1, 1)
            intf.items['b_cancel'] = dlg:add_button( lang.cancel, intf.editor.show, 1, 4, 1, 1)
            
        end,

        upload = function ( ... )
            local pass = intf.items['i_pass']:get_text()
            local user = intf.items['i_name']:get_text()
            config.options.name = user
            if fcinema.upload( user, pass ) then
                intf.editor.show()
                intf.msg( style.ok( "Gracias por colaborar con fcinema") )
            else
                intf.editor.request_pass()
                intf.items['l_name']:set_text( style.err("Nombre usuario: "))
                intf.items['l_pass']:set_text( style.err("Contraseña: "))
            end
        end,

        nextframe = function ( ... )
            intf.msg("")
            local len = intf.items["len"]:get_value()
            media.jump( len*0.2 )
        end,

        previousframe = function ( ... )
            intf.msg("")
            local len = intf.items["len"]:get_value()
            media.jump( -len*0.2 )
        end,

        toggle = function ( )
            intf.msg("")
            vlc.playlist.pause()
        end,

        preview = function ( ... )
            intf.msg("")

        -- Read input
            edl.start[1] = intf.to_sec( intf.items["Start"]:get_text() )
            edl.stop[1] = intf.to_sec( intf.items["Stop"]:get_text() )
            edl.action[1] = intf.items["Action"]:get_value()

        -- If no scene on input, look if something is selected on the list
            if not edl.start[1] then
                local k = get_list_selection()
                if not k then return end
                edl.start[1] = fcinema.data['Scenes'][k]['Start']
                edl.stop[1] = fcinema.data['Scenes'][k]['End']
                edl.action[1] = fcinema.data['Scenes'][k]['Action']
            end
            
        -- Start the preview
            media.go_to( edl.start[1] - 5 )
            vlc.playlist.play()
            if edl.preview_active == 0 then
                vlc.var.add_callback( vlc.object.input(), "intf-event", edl.one_time_preview )
            end
            vlc.msg.dbg("[Fcinema] Preview started")
            edl.preview_active = 1
        end,        

        get_time = function ()
            intf.msg("")
            local str = intf.to_hour( media.get_time() , 1000 )
            intf.items["Start"]:set_text( str )        
        end,

        get_time2 = function ()
            intf.msg("")
            local str = intf.to_hour( media.get_time() , 1000 )
            intf.items["Stop"]:set_text( str )            
        end,

        go2start = function ()
            intf.msg("")
            local start = intf.to_sec( intf.items["Start"]:get_text() )
            if not start then
                intf.msg( style.err("Error: ") .." Salta al comienzo de la escena")
                return
            end
            media.go_to( start )
        end,

        go2end = function ()
            intf.msg("")
            local stop = intf.to_sec( intf.items["Stop"]:get_text() )
            if not stop then
                intf.msg( style.err("Error: ") .." Salta al final de la escena")
                return
            end
            media.go_to( stop )
        end,

        add_scene = function ( ... )
            intf.msg("")
        -- Read values
            local start = intf.to_sec( intf.items["Start"]:get_text() )
            local stop = intf.to_sec( intf.items["Stop"]:get_text() )
            local desc = intf.items["Desc"]:get_text()
            local typ_num = intf.items["Type"]:get_value()
            local typ = intf.editor.dropdown[typ_num]
            local action_num = intf.items["Action"]:get_value()
            local action = action_num
            local level = intf.items["level"]:get_value()
            
        -- Check the values are correct
            if not start or not stop then
                intf.msg( lang.invalid_data )
                return
            elseif stop < start then
                intf.msg( style.err("Error: ").. "compruebe duración de la escena" )
                return
            end

        -- Add the scene
            if fcinema.add_scene( start, stop, typ, desc, level, action ) == -1 then return end
            fcinema.save()

        -- Classify movie as user modified
            fcinema.add2index( config.path .. config.user_modified_db )

        -- Clean the editor
            intf.items["Start"]:set_text("")
            intf.items["Stop"]:set_text("")
            intf.items["Desc"]:set_text("")
        
        -- Update the list
            intf.editor.fill_list()

        end,

        delete_scene = function ( ... )
        -- Delete selected scene from memory and interface (permanent!)
        
        -- Get selection index and delete
            local tab = intf.items['list']:get_selection( )
            for k,v in pairs( tab ) do
                fcinema.del_scene( k )
            end
            
        -- Update the list
            intf.editor.fill_list()
        end,

        modify = function (  )
        -- Modify selected scene, delete from current list and display on inputs

        -- Get selected index and corresponding values
            local k = get_list_selection()
            if not k or k == intf.editor.selected then return end
            intf.editor.selected = k

            local start, stop, desc, typ, level           
            start = fcinema.data['Scenes'][k]['Start']
            stop = fcinema.data['Scenes'][k]['End']
            desc = fcinema.data['Scenes'][k]['AdditionalInfo']
            typ = fcinema.data['Scenes'][k]['Category']
            level = fcinema.data['Scenes'][k]['Severity']
            fcinema.del_scene( k )
        
        -- Update the list
            intf.editor.fill_list()

        -- Update the inputs
            stop_h  = intf.to_hour( stop, 1000 )
            intf.items["Stop"]:set_text( stop_h )

            start_h  = intf.to_hour( start, 1000 )
            intf.items["Start"]:set_text( start_h )

            intf.items["Desc"]:set_text( desc )

        -- Update the type --TODO: simplify this stuff
            intf.del( 'Type' )
            intf.items['Type'] = dlg:add_dropdown( 8, 5, 2, 1)
            intf.editor.dropdown = {}
            for k,v in pairs( intf.main.label ) do
                if k == typ then
                    table.insert( intf.editor.dropdown, k )
                    local i = table.maxn( intf.editor.dropdown )
                    intf.items['Type']:add_value( v, i )
                end
            end
            for k,v in pairs( intf.main.label ) do
                table.insert( intf.editor.dropdown, k )
                local i = table.maxn( intf.editor.dropdown )
                intf.items['Type']:add_value( v, i )
            end

        -- Update the level
            intf.del( 'level' )
            intf.items['level'] = dlg:add_dropdown( 10, 5, 1, 1)
            intf.items['level']:add_value( level, level )
            for i=1,5 do
                intf.items['level']:add_value( i, i )
            end

            collectgarbage()
            dlg:update()

        end,

        fill_list = function()
        -- Display scenes on editor interface list
            intf.items['list']:clear()
            local data = fcinema.data
            for k,v in pairs( data['Scenes'] ) do
                local start_h = intf.to_hour( v['Start'], 1 )
                local stop_h = intf.to_hour( v['End'], 1 )
                local typ = v['Category']
                local desc = v['AdditionalInfo']
                local level = v['Severity']
                intf.items['list']:add_value( typ..level.." "..start_h .." "..desc, k )
            end
        end,
    },
    
    help = {
        show = function (  )
            intf.main.apply_level()
            intf.change_dlg()
            intf.items['help'] = dlg:add_html( lang.help, 1, 1, 4, 1)
            intf.items['trick'] = dlg:add_label(string.rep ("&nbsp;", 100), 1, 2, 3, 1)
            intf.items['back'] = dlg:add_button( lang.back, intf.main.show, 4, 2, 1, 1)
            collectgarbage()
        end,
    },
    ------------------------- Interface utils ------------------------

    items = {},

    change_dlg = function ( ... )
    -- Functions to run every time dialog is changed
        edl.deactivate()
        sync.auto()

    -- Delete all elements on the previous dialog
    -- (Creating a new dialog works but replace dialog position)
        for k,v in pairs( intf.items ) do
            intf.del( k )
        end
        intf.items = nil
        intf.items = {}
        if not dlg then dlg = vlc.dialog( "Family Cinema (Beta)") end
        collectgarbage()
    end,

    del = function ( str )
    -- Delete widget 'str' from the current interface
        if intf.items[ str ] then
            dlg:del_widget( intf.items[ str ] )
            intf.items[ str ] = nil
        end
    end,

    to_hour = function ( time, precision )
    -- Convert time format to min:sec
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
    -- Convert time format to sec
        if not str or str == '' then return end
        if type( str ) == "number" then return str end
        local min, sec = string.match( str, '(.+):(.+)' )
        sec = min * 60 + sec
        return sec
    end,

    msg = function ( str )
    -- Displays a message on the user interface
        if intf.items["message"] then
            intf.items["message"]:set_text(str)
            dlg:update()
        end
    end,

    progress_bar = function ( pct )
    -- Displays a progress bar filled at percentage 'pct'
        local size = 30
        local accomplished = math.ceil( size*pct/100)
        local left = size - accomplished
        return "<span style='background-color:#181;color:#181;'>"..
        string.rep ("-", accomplished).."</span>"..
        "<span style='background-color:#fff;color:#fff;'>"..
        string.rep ("-", left).."</span>"
    end,

}

--------------------------- CONFIGURATION ------------------------------------

config = {
    os = "",
    version = "0.01",
    agent = "vlc",
    slash = '/',
    path = '',
    user_modified_db = "user_modified_db.txt",
    hash2id_db = "fcinema.txt",
    options = {
        lang = "esp", --os.getenv("LANG"),
        --token = "1234",
        name = "",
    },

    load = function ( ... )
    -- Load configuration

    -- Load libraries...
        os.setlocale( 'C' ) -- Avoid problems with local decimal separators (specially in json)
        json = require ("dkjson")
        --socket = require("socket") -- TODO use luasocket instead of vlc.net
        --local system_lang = os.getenv("LANG") eg. en_US.UTF-8 

    -- Find cache path
        find_path()

    -- Load stored options
        local data = system.read( config.path .. 'config.json')
        if data then
            local options = json.decode( data )
            if options then
                config.options = options
            end
        end

    -- Set user interface language
        if config.options.lang ~= "esp" then -- TODO just for dbg?
            config.load_lang( config.options.lang )
        end
    end,

    load_lang = function ( language )
    -- Set user interface language
        local data = fcinema.read( config.path .. language .. ".json" )
        if data then
            for k,v in pairs(data) do
                lang[k] = data[k]
            end
            intf.advanced.show()
        else
            intf.msg( style.err("Error: ") .. "Language pack not found" )
        end
    end,

    save = function ( ... )
    -- Save user configuration
        system.write( config.path .. 'config.json', json.encode( config.options ) )
    end,
}


------------------------------------ EDL --------------------------------------

edl = {
-- Manage 'Edit Decision List'
    start = {},
    stop  = {},
    action= {},
    active = false,
    preview_active = 0,
    start_margin = 0.2,
    stop_margin = 0.1,
    last_time = 0,

    activate = function( )
    -- Activate callback for edl, 'edl.check' will be called around 3-5 times/second
        if edl.active then
            vlc.osd.message( "fcinema is already active", 1, "botton", 1000000 )
            dlg:hide()
        else
            if not edl.from_user() then return end
            vlc.playlist.play()
            vlc.var.add_callback( vlc.object.input(), "intf-event", edl.check )
            vlc.var.add_callback( vlc.object.libvlc(), "key-pressed", edl.key_press ) -- TODO testing
            edl.active = true
            vlc.osd.message( "fcinema activado", 1, "botton", 1000000 )
            dlg:hide()
        end
        --vlc.video.fullscreen( ) -- TODO testing
    end,

    from_user = function ( ... )
    -- Retrieve which scene must be skipped
        edl.start = {}
        edl.stop = {}
        for k,v in pairs( intf.main.actions ) do
            if v then
                table.insert( edl.start, fcinema.data['Scenes'][k]['Start'] - edl.start_margin )
                table.insert( edl.stop, fcinema.data['Scenes'][k]['End'] + edl.stop_margin )
                table.insert( edl.action, fcinema.data['Scenes'][k]['Action'] )
            end
        end
        vlc.msg.dbg( '[Fcinema]'..json.encode( edl.start ) .. json.encode( edl.stop ) )
        return true
    end,

    deactivate = function()
    -- Deactivate callbacks

    -- Deactivate normal playing callback
        if edl.active then
            vlc.var.del_callback( vlc.object.input(), "intf-event", edl.check )
            vlc.var.del_callback( vlc.object.libvlc(), "key-pressed", edl.key_press ) -- TODO testing
            vlc.osd.message( "fcinema desactivado", 1, "botton", 5000000 )
            vlc.playlist.play()
            vlc.playlist.pause()    -- FIXME: on linux this toggle!!
            edl.active = false
        end


    -- Deactivate preview callback
        if edl.preview_active ~= 0 then
            vlc.var.del_callback( vlc.object.input(), "intf-event", edl.one_time_preview )
            edl.preview_active = 0
        end
    end,

    one_time_preview = function ( ... )
    -- Preview scene cut one time
    
    -- Check if preview is active
        if edl.preview_active ~= 1 then return end

    -- Get current time (avoid repetions)
        local t = media.get_time()
        if not t or t == edl.last_time then return end
        edl.last_time = t
        vlc.msg.dbg( '[Fcinema] Comprobando tiempo ' .. t )

    -- Check if current time is in "dark zone" and stop preview
        if t < edl.stop[1] - 0.2 and t > edl.start[1] then
            if edl.action[1] == 2 then --'Mute'
                media.mute()
            elseif edl.action[1] == 'Dark' then 
                media.dark()
            elseif edl.action[1] == 'Label' then
                media.label('')
            else
                media.go_to( edl.stop[1] )
            end
            return
        end

        if t > edl.stop[1] then
            edl.preview_active = 2 -- crash if callbacks are deactivated from a callback
            media.unmute()
        end
    end,


    key_press = function ( var, old, new, data )
        local key = new
        if key == 113 then
            if not edl.pressed then
                edl.first_pressed = edl.last_time
                edl.pressed = true
                media.mute()
                media.distort()
            end
            edl.last_pressed = edl.last_time
        end
    end,

    last_pressed = 0,
    first_pressed = 0,
    pressed = false,

    check = function( )
    -- Check if current time is inside 'dark zone' and skip it

    -- Get current time (avoid repetions)
        local t = media.get_time()
        if not t or t == edl.last_time then return end
        edl.last_time = t
        --vlc.msg.dbg( '[Fcinema] Comprobando tiempo ' .. t )

    -- Fast scene edition
        if edl.pressed and edl.last_pressed < t-0.7 then
            edl.pressed = false
            fcinema.add_scene( edl.first_pressed - 0.8, edl.last_pressed-0.1, 'u', 'Escena sin clasificar', 1, 1 )
            media.unmute()
        end

    -- Check if current time is in "dark zone"
        for i, stop in ipairs( edl.stop ) do
            if t < stop - 0.2 and t > edl.start[i] then
                if edl.action[i] == 2 then --'Mute'
                    media.mute()
                elseif edl.action[i] == 'Dark' then 
                    media.dark()
                elseif edl.action[i] == 'Label' then
                    media.label('')
                else
                    media.go_to( stop )
                end
                return
            end
        end

        if not edl.pressed then 
            media.unmute()
            media.undistort()
        end

    end,

}

------------------------------- fcinema.org ---------------------------------------

fcinema = {

    api_url = "http://fcinema.org/api.php",
    data = nil,
    movie_list = nil,

    search = function( id )
    -- Search movie content. If id is not specified last computed hash is used

    -- Clean everything, just in case
        fcinema.data = nil
        local data = nil

    -- Search in files modified by user
        vlc.msg.dbg( "[Fcinema] Looking in user modified movies")
        if not id then
            id = fcinema.hash2id( config.user_modified_db )
            if id then
                vlc.msg.dbg( "[Fcinema] ID found in user modified movies! " .. id )
            end
        end
        if id then -- Do not use 'else'
            data = fcinema.read( config.path ..  id .. '.json')
        end

    -- Search in online db
        if data == nil then
            vlc.msg.dbg( "[Fcinema] Looking on fcinema.org")
            data = fcinema.search_online( id, media.file.hash or nil, media.file.bytesize, media.file.name )
        end
    
    -- Search in local cache
        if data == nil or ( not data['Title'] and not data['Titles'] ) then
            vlc.msg.dbg( "[Fcinema] Looking on local cache")
            id = fcinema.hash2id( config.hash2id_db )
            if id then
                vlc.msg.dbg( '[Fcinema] ID found in local cache! ' .. id )
                data = fcinema.read( config.path ..  id .. '.json')
            end
        end
        
    -- Parse readed/received data
        if not data or data['Error'] then
            intf.select_movie.show()
            intf.msg( "Lo sentimos no hay información disponible")
            vlc.msg.dbg( "[Fcinema] No info, displaying searching dialog")
        elseif data['Title'] then
            vlc.msg.dbg( "[Fcinema] Readed: " .. json.encode( data ) .."\n" )
            fcinema.load_movie( data )
            intf.main.show()
        elseif data['Titles'] then
            vlc.msg.dbg( "[Fcinema] Readed: " .. json.encode( data ) .."\n" )
            fcinema.movie_list = data
            intf.select_movie.show()
        end

        return true
    end,

    search_online = function ( imdb_code, hash, bytesize, name )
    -- Search for movie content on internet database (save on local cache if found)

        fcinema.data = nil
    -- Define query parameters
        local params = ""
        params = params .. "action=search"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
        params = params .. "&lang=" .. config.options.lang
        if imdb_code then params = params .. "&imdb_code=" .. imdb_code end
        if bytesize then params = params .. "&bytesize=" .. bytesize end
        if hash then params = params .. "&hash=" .. hash end
        if name then params = params .. "&filename=" .. name end

    -- Request server info and parse response
        local status, response = net.post( params, fcinema.api_url )
        if not response then return end
        local data = string.match(response, '{(.+)}')
        if data then
            data = json.decode( '{'..data..'}' )
            if data and data['Title'] then
                fcinema.load_movie( data )
                fcinema.add2index( config.path .. config.hash2id_db )
                fcinema.save()
            end
            return data
        end
        
    end,

    load_movie = function ( data )
        sync.status = 0
        sync.syncing = false
        sync.applied_offset = 0
        fcinema.data = nil
        fcinema.data = data
    end,

    feedback = function ( name, email, idea )
        local params = ""
        params = params .. "action=feedback"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
        params = params .. "&name=".. name or ""
        params = params .. "&email=".. email or ""
        params = params .. "&idea=".. idea or ""

        local status, response = net.post( params, fcinema.api_url )
        if response then
            intf.msg( "Feedback enviado, muchas gracias por tu ayuda")
        else
            intf.msg( "Por favor, conectate a internet")
        end
    end,

    upload = function ( user, pass  )
        local data = json.encode( sync.unsync() )
        local params = ""
        params = params .. "action=modify"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
--        params = params .. "&imdb_code=" .. fcinema.data['ImdbCode']
        params = params .. "&data=".. data
        params = params .. "&username=" .. user or ""
        params = params .. "&password=" .. pass or ""
                
        local status, response = net.post( params, fcinema.api_url )
        intf.msg('')
        if response then
            data = string.match(response, '{(.+)}')
            if data then
                data = json.decode( '{'..data..'}' )
                if data.status and data.status == "Ok" then
                    return true
                end
            end
        end
        
        return false
        
    end,

    save = function ( )
    -- Save current movie content

    -- Safety measures
        edl.deactivate()
        if not config.path or config.path == '' then return end
        
    -- Restore to orignal
        local data = json.encode( sync.unsync() )

    -- Write content to file
        local file = config.path ..fcinema.data['ImdbCode'] .. ".json"
        system.write( file, data )
        intf.msg( style.ok( 'Guardado con exito') )

    end,

    add2index = function ( db )
    -- Add movie to index in database 'db'

    -- Safety measures
        if not media.file.hash then return end
    -- Read index
        local index = system.read( db ) or ''
    -- Remove current hash from index, avoid duplicates
        index = string.gsub( index, media.file.hash .. ';(.-);(.-);', '' )
    -- Add hash and save
        index = index .. media.file.hash ..';'..fcinema.data['ImdbCode']..';0;\n'
        system.write( db, index )
    end,

    hash2id = function ( db )
    -- Get movie ID from hash
        --vlc.msg.dbg( "[Fcinema] Looking for hash in " .. config.path .. db )
        if not media.file.hash then return end
        local data = system.read( config.path .. db )
        if data then
            local id, offset = string.match( data, media.file.hash .. ';(.-);(.-);' )
            if id then
                return id
            end
        end
    end,

    read = function ( file )
        local data = system.read( file )
        if data then
            return json.decode( data )
        end
    end,
    
    add_scene = function ( start, stop, typ, desc, level, action )
    -- Add scene to movie content

        local scene = {}
        if typ == 'syn' then
            scene['Start'] = start
            scene['End'] = stop
            scene['AdditionalInfo'] = desc or ''

            if not fcinema.data['SyncScenes'] then
                fcinema.data['SyncScenes'] = {}
            elseif sync.lock() then return -1 end

        -- Get index
            local i = table.maxn( fcinema.data['SyncScenes'] ) + 1

        -- Insert values
            fcinema.data['SyncScenes'][i] = scene

            vlc.msg.dbg( "[Fcinema] New scene added" )

        else
            scene['Start'] = start
            scene['End'] = stop
            scene['Category'] = typ
            scene['Severity'] = level
            scene['Action'] = action
            scene['AdditionalInfo'] = desc or ''

            if not fcinema.data['Scenes'] then
                fcinema.data['Scenes'] = {}
            elseif sync.lock() then return -1 end

        -- Get index
            local i = table.maxn( fcinema.data['Scenes'] ) + 1

        -- Insert values
            fcinema.data['Scenes'][i] = scene

            vlc.msg.dbg( "[Fcinema] New scene added" )
        end

        return i
    end,

    del_scene = function ( scene_number )
    -- Delete scene 'from' movie content
        table.remove( fcinema.data['Scenes'], scene_number )
        fcinema.save()
    end,
}

--------------------------------------- SYSTEM ----------------------------------------

system = {

    read = function ( file )
    -- Read file content, return false if error
        vlc.msg.dbg( '[Fcinema] Reading data from file: '.. file )
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
    -- Write content 'str' to file 'file'
        if not str then return end
        vlc.msg.dbg( '[Fcinema] Writing data to file: '.. file )
        local tmpFile = io.open( file , "wb")
        if not tmpFile then return false end
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

    -- TODO: reset values when a new movie is loaded
    status = 0, -- -1. Failed | 0. Out of sync | 1. Manual synced | 2. Auto synced | 3. Synced from ref
    syncing = false,
    applied_offset = 0,

    lock = function ( ... )
    -- Return 'true' if movie is out of sync. Used by some actions that require movie to be synced
        sync.auto()
        if sync.status > 0 then return false end
        if sync.syncing == true then
            intf.msg( style.err("Espera: ").."los cortes se estan calibrando")
            vlc.msg.dbg( "[Fcinema] Esperando sync")
            return true
        else
            intf.manual_sync.show()
            intf.msg( style.err("Espera: ").."antes debes calibrar los cortes manualmente")
            vlc.msg.dbg( "[Fcinema] Calibrar a mano")
            return true
        end
    end,

    auto = function ( ... )
    -- Auto sync process

    -- No movie, nothing to sync
        if not fcinema.data then return end

    -- Already synced, return
        if sync.status > 0 then return end

    -- No scenes -> first used this movie -> sync has no sense, set as ref
        if not fcinema.data['Scenes'][1] then
            fcinema.data['PreviousSync'] = {}
            fcinema.data['PreviousSync'][media.file.hash] = 0
            sync.status = 1
            fcinema.save()
            return
        end

    -- Look if this file/hash has being synced before
        if fcinema.data['PreviousSync'] and sync.status <= 0 then
            local offset = fcinema.data['PreviousSync'][media.file.hash]
            if offset then
                sync.apply_offset( offset )
                sync.status = 3
                intf.msg( style.ok( "Calibrado ").." gracias a la base de datos")
                return
            end
        end

    -- Request scene shot detection
        local ref = fcinema.data['Shots']   -- Autosync reference information
        if ref and not sync.syncing and sync.status == 0 then
            sync.request_sync_info()
        end
    
    -- Try to read scene shot data and autosync
        if sync.syncing and sync.status == 0 then
            local sync_info = sync.read_sync_info()
            if sync_info then
                local offset = sync.borders2offset( sync_info, ref )
                sync.apply_offset( offset - sync.applied_offset )
                sync.status = 2
            end
        end
        
    end,


    request_sync_info = function ( )
    -- Launch something that computes shot edges and stores them

    -- Clean files, just in case
        os.remove( config.path.."cuts.log")
        os.remove( config.path.."cmd.avi")

    -- Call program according to OS
        if config.os == "win" then
            local vlc_path = vlc.config.datadir()
            local invisible = vlc_path..'\\lua\\extensions\\AutoSync\\invisible.vbs'
            local bacht_file = vlc_path..'\\lua\\extensions\\AutoSync\\getcuts.bat'
            local cmd = 'start "" "'..invisible..'" "'..bacht_file..'" "'..media.file.uri..'" "'..config.path..'" '
            vlc.msg.dbg("[Fcinema] Executing ".. cmd )
            local status = os.execute( cmd )
            if status == 0 then
                vlc.msg.dbg( "[Fcinema] Sync proccess started")
                sync.syncing = true
            else
                sync.status = -1
                intf.msg( style.err("Atención: ").."Usa la calibración manual")
            end
        elseif config.os == "lin" then
            sync.status = -1
            intf.msg( style.err("Atención: ").."Usa la calibración manual")
        end
    end,

    read_sync_info = function ( ... )
        local sync_info = { ['frame'] = {}, ['prob'] = {}, ['fps'] = media.get_fps() }

        if config.os == "win" then
            local log = system.read( config.path.."cuts.log" )
            if not log or log == "" then return end
            vlc.msg.dbg( log )
            os.remove( config.path.."cuts.log")
            os.remove( config.path.."cmd.avi")
            for frame, prob in string.gfind( log, "([^%s]+)%s+([^%s]+)%s+[01]") do
                if prob+0 > 0.1 then
                   table.insert( sync_info['frame'] , frame+0 )
                   table.insert( sync_info['prob'] , math.floor(prob*100) )
                   --sync_info['frame'] = prob
                end
            end
        elseif config.os == "lin" then
            --os.execute()
            return
        end
        sync.syncing = false
        sync.sync_info = sync_info
        if not fcinema.data['Shots'] then
            fcinema.data['Shots'] = sync_info
        end
        vlc.msg.dbg( '[Fcinema] Readed sync info is: '..json.encode( sync_info ) )
        return sync_info
    end,

    borders2offset = function ( our_info, ref_info )
    
    -- Check before wasting time    
        if not ref_info or not our_info then 
            intf.msg( style.err("Atención: ").."Usa la calibración manual")
            return
        end 

    -- Calculate the offset from the scene change list
        local sum = {}
        local d
        --vlc.msg.dbg( "calculating borders", json.encode(our_info), json.encode(ref_info) )
        fps_r = ref_info['fps']
        fps_o = our_info['fps']
        for kr,vr in pairs( ref_info['frame'] ) do
            pr = ref_info['prob'][kr]
            for ko,vo in pairs( our_info['frame'] ) do
                po = our_info['prob'][ko]
                d = vr/fps_r - vo/fps_o
                d = math.floor( d * 25 )/25 + 0.5/25
                --d = vr - vo
                if not sum[ d ] then
                    sum[ d ] =  1 - math.abs( pr - po ) / (pr + po)
                else
                    sum[ d ] = sum[ d ] + 1 - math.abs( pr - po ) / (pr + po)
                end
            end
        end

        -- Calculate the maximum
        local max = 0
        local offset
        for k, v in pairs( sum ) do
            if v > max then
                max = v
                offset = k
            end
        end
        offset = -offset
        if max < 5 then
            intf.msg("Imposible asegurar calibración automática")
            return
        end

        vlc.msg.dbg( "[Fcinema] Posibles offsets: " .. json.encode( sum ) )
        vlc.msg.dbg( "[Fcinema] Offset automático calculado: " .. offset .." con "..max.." coincidencias")

        return offset
    end,

    apply_offset = function ( offset )
    -- Apply an offset of 'offset' seconds to all scenes
        if not type( offset ) == 'number' then return end

    -- Apply offset
        for k,v in pairs( fcinema.data['Scenes']) do
            fcinema.data['Scenes'][k]['Start'] = fcinema.data['Scenes'][k]['Start'] + offset
            fcinema.data['Scenes'][k]['End'] = fcinema.data['Scenes'][k]['End'] + offset
        end

    -- Update applied offset
        sync.applied_offset = sync.applied_offset + offset
    
    -- Update sync reference
        if not fcinema.data['PreviousSync'] then
            fcinema.data['PreviousSync'] = {}
        end
        fcinema.data['PreviousSync'][media.file.hash] = sync.applied_offset
        fcinema.save()
    
    -- Display info
        vlc.msg.dbg( "[Fcinema] "..offset.."s of extra offset applied" )
        intf.msg( "calibración de "..(math.floor(offset*100)/100).." segundos aplicada" )
        return true
    end,

    unsync = function ( )
    -- Restore scene sync to original, undo applied offsets (this must be done before sharing/saving the file)
        local data = deepcopy( fcinema.data ) -- create a copy of the table
        for k,v in pairs( data['Scenes']) do
            data['Scenes'][k]['Start'] = data['Scenes'][k]['Start'] - sync.applied_offset
            data['Scenes'][k]['End'] = data['Scenes'][k]['End'] - sync.applied_offset
        end
        intf.msg( '[Fcinema] Data prepared to share/save')
        return data
    end,
    
}

--------------------------------------- NET -------------------------------------------

net = {
-- Net functionality
    -- TODO need vlc.net module, permission problems on some versions!

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
        if not vlc.net then
            intf.msg( 'No network access')
            return
        end
        local fd = vlc.net.connect_tcp(host, port)

        if not fd or fd == -1 then return false end
        local pollfds = {}
        intf.msg( "Enviando datos: ".. intf.progress_bar( 50 ) )
        pollfds[fd] = vlc.net.POLLIN
        vlc.net.send(fd, request)
        intf.msg( "Esperando respuesta: ".. intf.progress_bar( 70 ) )
        vlc.net.poll(pollfds)
        intf.msg( "Recibiendo respuesta: ".. intf.progress_bar( 80 ) )
        local response = vlc.net.recv(fd, 1024*512) -- FIXME
        vlc.msg.dbg( '[Fcinema] Datos recibidos del servidor: '.. response )
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

    openurl = function ( url )
        if not url then return end
        if config.os == "win" then
            os.execute( 'start ' .. url )
        else
            os.execute( 'xdg-open ' .. url )
        end
        return true
    end,

    downloadfile = function ( url, dst )
        if config.os == "win" then
            --os.execute( 'start ' .. url )
        else
            vlc.msg.dbg("[Fcinema] Downloading file ".. url)
            local command = 'wget  -O '..dst..' '..url
            vlc.msg.dbg( "[Fcinema] Executing: ".. command)
            os.execute( command )
        end
    end,

}


----------------------------------  MEDIA ------------------------------------
media = {
-- Media information

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
    -- Get all movie info

    -- Check input exist
        if not media.input_item() then
            intf.msg( style.err( "No input item") )
            return
        end
        intf.msg( "Identificando película: ".. intf.progress_bar( 10 ) )

    -- Get general info
        media.get_file_info()
        vlc.msg.dbg("[Fcinema] File info "..(json.encode( media.file )))
        intf.msg( "Identificando película: ".. intf.progress_bar( 20 ) )
    
    -- Get hash
        media.get_hash()
        intf.msg( "Identificando película: ".. intf.progress_bar( 30 ) )
        
    -- Display retrieved info
        vlc.msg.dbg("[Fcinema] File info "..(json.encode( media.file )))
    
    -- Search for file content
        fcinema.search()

    end,

    go_to = function( time )
    -- Go to specified time
        --Set "position" as it crash if "time" is set directly
        local duration = vlc.input.item():duration()
        vlc.var.set( vlc.object.input(), "position", time / duration)
    end,

    muted = false,
    volume = 0,

    dark = function ( ... )
        -- body
    end,

    undark = function ( ... )
        -- body
    end,

    distort = function ( ... )
        vlc.config.set( "gamma", 1 )
    end,

    undistort = function ( ... )
        -- body
    end,

    label = function ( str )
        media.dark()
        media.mute()
        vlc.osd.message( str, 1, "botton", 5000000 )
    end,

    mute = function ( ... )
        if not media.muted then
            media.muted = true
            media.volume = vlc.volume.get()
            vlc.msg.dbg( "[Fcinema] Muting" )
            vlc.volume.set( 0 )
        end
    end,

    unmute = function ( ... )
    -- Unmute scene (only if it was muted ;)
        if media.muted then
            vlc.msg.dbg( "[Fcinema] Unmuting" )
            vlc.volume.set( media.volume )
            media.muted = false
        end
    end,

    jump = function ( diff )
    -- Jump specified time
        local t = media.get_time()
        if not t then return end
        vlc.msg.dbg("[Fcinema] Jumping "..diff.."s from "..t.."s.")
        vlc.var.set( vlc.object.input(), "time", t + diff )
    end,

    get_time = function()
        --TODO: if media.file.hasInput == false then return end
        return vlc.var.get( vlc.object.input(), "time" )
    end,

    get_fps = function ()
        local info = vlc.input.item():info()
        local fps
        for k,v in pairs(info) do
            if v['Frame rate'] then
                fps = v['Frame rate']
                break
            end
        end
        return fps
    end,

    input_item = function()
        return vlc.item or vlc.input.item()
    end,

    get_file_info = function()
    -- Retrieve file info
        vlc.msg.dbg( "[Fcinema] Getting file info" )

    -- Get video file path, name, extension... from input uri
        local item = media.input_item()
        local file = media.file
        file.name = vlc.input.item():name()--?¿
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

        --vlc.msg.dbg("[Fcinema] Video URI: "..item:uri())
        local parsed_uri = vlc.net.url_parse(item:uri())
        file.uri = item:uri()
        file.protocol = parsed_uri["protocol"]
        file.path = parsed_uri["path"]
        
    -- Make some corrections to movie names...
        
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

        collectgarbage()
    end,


    get_hash = function()
    -- Compute hash according to opensub standards
        -- In case hash computation is not possible -> hash = 'n'..creation_time


    -- Get input and prepare stuff
        local item = media.input_item()
        
        if not item then 
            intf.msg( style.err( "No input item") )
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
            vlc.msg.dbg("[Fcinema] Read hash data from stream 1")
        
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
            vlc.msg.dbg("[Fcinema] Read hash data from stream 2")
            
            local file = vlc.stream(media.file.uri)
            
            if not file then
                vlc.msg.dbg("[Fcinema] No stream")
                media.file.hash = 'n'..media.file.stat.creation_time
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
                media.file.hash = 'n'..media.file.stat.creation_time
                return false
            end
            
            data_start = file:read(chunk_size)
            if not data_start then
                vlc.msg.dbg("[Fcinema] Imposible leer fichero")
                media.file.hash = 'n'..media.file.stat.creation_time
                return false
            end
            size = file:seek("end", -chunk_size) + chunk_size
            data_end = file:read(chunk_size)
            file = nil
        end
        
    -- Compute hash
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
    
    -- Store computed hash
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
-- Find best path for cache (find previously used or select new one)

-- OS specific issues
    local slash
    if is_window_path(vlc.config.datadir()) then
        config.os = "win"
        slash = "\\"
        config.slash = slash
    else
        config.os = "lin"
        slash = "/"
    end

--Posible paths for config (in order of priority)
    local paths = {
        vlc.config.userdatadir(), --: Get the user's VLC data directory.
        vlc.config.datadir(), --: Get the VLC data directory.
        vlc.config.homedir(), --: Get the user's home directory.
        vlc.config.configdir(), --: Get the user's VLC config directory.
        vlc.config.cachedir() --: Get the user's VLC cache directory.
    }

    local path_generic = {"lua", "extensions", "userdata", "fcinema"}
    local fcinema_path = slash..table.concat(path_generic, slash)

-- Check if cache is somewhere out there
    for k,v in pairs( paths ) do
        if file_exist( v .. fcinema_path .. config.hash2id_db ) then
            config.path = v .. fcinema_path .. slash
            return
        end
    end

-- Find new place for cache
    for k,v in pairs( paths ) do
        if is_dir(v) and not is_dir( v..fcinema_path) then
            mkdir_p( v..fcinema_path)
        end
        if file_touch( v ..fcinema_path..slash..config.hash2id_db) then
            config.path = v ..fcinema_path .. slash
            return
        end
    end

-- Complain, we don't have cache!
    intf.msg('Imposible encontrar sitio para la cache')
    vlc.msg.dbg("[Fcinema] Imposible place cache")
    for k,v in pairs( paths ) do
        vlc.msg.dbg( v )
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

function mkdir_p(path)  -- Create dir
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

function get_list_selection(  )
    if not intf.items['list'] then return end
    local tab = intf.items['list']:get_selection( )
    for k,v in pairs( tab ) do
        return k
    end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

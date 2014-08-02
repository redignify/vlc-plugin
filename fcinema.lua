--]]
--[[
 Fcinema Extension for VLC media player 1.1 and 2.0
 
 Authors:  Miguel Arrieta, Alejandro Sopeña

 We want to give special thanks to:
 -  Guillaume Le Maout, for his extraordinary vlc extension "vlsub", a great model for us
    Contact: http://addons.videolan.org/messages/?action=newmessage&username=exebetche
 -  Opensubtibles, for his great open database
 
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

--[[
Lua scripts are tried in alphabetical order in the user's VLC config
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
end--]]

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
    view_movie = "Watch film",
    name_search = "Search by name",
    selec = "Select",
    b_help = "Help",
    add_new = "Add new",
    kontuz = "Warning: ",
    incomplete_info = "film content migth be incomplete",
    advanced = "Advanced",
    b_next = "Next",
    init = '<b><i>Inicio</i></b>',
    help = "<h2>Ayuda sobre como usar fcinema</h2>" ..
        "<p><b>Clasificación de escenas: </b> Las escenas estan clasicadas por tipo y gravedad. Para entender en detalle los niveles de gravedad visita <a href='http://www.fcinema.org/categories'>fcinema.org/categories</a>. Si buscas más detalles sobre la escena puedes encontrar también segundos, subtipo y/o texto explicativo.</p>"..
        "<p><b>Añadir escenas: </b> Asegurate de haber entendido bien los <a href='http://www.fcinema.org/categories'>niveles de gravedad</a>. Hecho esto, si se puede no apures, intenta eliminar uno o dos segundos extra antes y después de la escena. Así evitarás posibles sorpresas. En nombre de todos nuestros usuarios ¡gracias por colaborar!</p>"..
        "<p><b>Película erronea: </b> ¿no es la película que estas viendo? Haz click en <i>Avanzado</i> y luego en <i>Cambiar película</i></p>" ..
        "<p><b>Calibración manual: </b> ¿fallos en la calibración? Haz click en <i>Avanzado</i> y luego en <i>Calibración manual</i></p>" ..
        "<i>¿Sigues con preguntas? Visita <a href='http://www.fcinema.org/how'>fcinema.org/how</a></i>",
    ------ Advanced -------------
    l_editor = "Create your scene list: ",
    b_editor = "Editor",
    l_donate = "Support fcinema: ",
    b_donate = "Donate",
    l_sync = "Manual calibration: ",
    b_sync = "Calibration",
    l_feedback = "Your opinion is important: ",
    b_feedback = "Send feedback",
    l_bad_movie = "Not the film you are watching?: ",
    b_bad_movie = "Change film",
    b_auto_sync = "Auto sync",
    back = "Back",
    msg_donate = "All about collab on <a href='http://www.fcinema.org/'>fcinema.org</a>",
    b_change_lang = "Change language",
    --------- Editor -----------------
    l_editor_check_length = "check scene duration",
    preview = "Preview",
    add_scene = "Add",
    delete_scene = "Delete",
    modify_scene = "Modify",
    cache = "Recent",
    share = "Share",
    l_error = "Error: ",
    invalid_data = " Please complete all fields",
    now = "Now",
    ---------- Manual sync ------------
    apply_offset = "Apply offset",
    cancel = "Cancel",
    ----- Movie selector
    recent_files_folder = "Manualy add files on folder ",
    new_movie_warning = style.err("Important:").." Are you sure film isn't on IMDB database?",
    name = "Name (optional): ",
    email = "Email (optional): ",
    click_at_start = style.ok("Tip: ").. 'Click "Now" just when see',
    b_view_original = "View origal scene",
    b_view_edited = "View edited scene",
    b_ready = "Done",
    b_start = "Start: ",
    b_end = "End: ",
    l_more_info = "Additinal info: ",
    l_cat_and_level = "Category & level",
    l_action = "Action",
    l_skip = "Skip",
    l_mute = "Mute",
    msg_sharing_without_id = style.err("Impossible").." to share films without global ID",
    msg_include_sync = style.err("Wait ").."first you must add a scene for manual calibration",
    l_username = "Username: ",
    l_password = "Password: ",
    share = "Share",
    l_thanks_for_sharing = "Thanks for your collab!"


}

---------------------------- INTERFACE ------------------------------------

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
            intf.items['list'] = dlg:add_list( 1, 3, 4, 1 )
            intf.items["message"] = dlg:add_label(" ", 1, 4, 4, 1)
            intf.items['title'] = dlg:add_text_input( media.file.cleanName, 1, 2, 3, 1 )
            intf.items['b_search'] = dlg:add_button( lang.name_search, intf.select_movie.search_name_online, 4, 2, 1, 1 )
            intf.items['b_choose'] = dlg:add_button( lang.selec, intf.select_movie.choose, 4, 5, 1, 1 )
            intf.items['b_cache'] = dlg:add_button( lang.cache, intf.select_movie.cache, 2, 5, 1, 1)
            intf.items['local'] = dlg:add_button( lang.add_new, intf.select_movie.new.show, 1, 5, 1, 1 )

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
                if movie and type(movie)~= 'number' and movie['Title'] then
                    local desc = string.gsub( movie['Director'] or 'Unkown', "%s+", " ")
                    fcinema.movie_list['IDs'][k] = movie['ImdbCode']--string.gsub( v, '.json', '')
                    intf.items['list']:add_value( movie['Title']..' ('..desc..')', k )
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
                intf.items['title'] = dlg:add_text_input( title, 2, 2, 3, 1 )

                intf.items['l_director'] = dlg:add_label( "Director: ", 1, 3, 2, 1 )
                intf.items['director'] = dlg:add_text_input( "", 2, 3, 3, 1 )

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

            local title = style.tit( fcinema.data['Title'] or ' ' )
            intf.items["title"] = dlg:add_label( title, 1, 1, 7, 1)
            local subheader = '<i><center>'..(fcinema.data['Director'] or '')..'  '..( fcinema.data['PGCode'] or '' ) ..'</center></i>'
            intf.items["director"] = dlg:add_label( subheader, 1, 2, 7, 1)
        

            intf.items['advanced'] = dlg:add_button( lang.advanced, intf.advanced.show, 3, 9, 2, 1)
            intf.items['help'] = dlg:add_button( lang.b_help, intf.help.show, 1, 9, 1, 1)
            intf.items['watch'] = dlg:add_button( lang.b_next, intf.main.list_view, 5, 9, 1, 1)
          
            intf.items["message"] = dlg:add_label("", 1, 8, 10, 1)

            --intf.main.show_poster()
            --intf.main.toggle_list()

            intf.items['l_levels'] = dlg:add_label( '<center><i>Selecciona la severidad del filtrado</center></i>', 1, 3, 3, 1 ) --TODO
            intf.main.show_category( 's', 4 )
            intf.main.show_category( 'v', 5 )
            intf.main.show_category( 'p', 6 )
            intf.main.show_category( 'd', 7 )
            intf.items['imdb_parentguide'] = dlg:add_label("<a href='http://www.imdb.com/title/"..fcinema.data['ImdbCode'].."/parentalguide'>IMDB Parents Guide</a>", 5,5,1,1)
            intf.items['kids-in-mind'] = dlg:add_label("<a href='http://www.kids-in-mind.com/cgi-bin/search/search.pl?q="..fcinema.data['Title'].."'>Kids In Mind Guide</a>",5,4,1,1)
            intf.main.apply_level()
            intf.main.show_warning()
            collectgarbage()
        end,

        show_warning = function ( ... )
            if not fcinema.data['Complete'] then
                intf.msg( style.err( lang.kontuz ) .. lang.incomplete_info )
            end
        end,

        list_view = function ( ... )
            intf.main.apply_level()
            intf.change_dlg()
            intf.items["l_info"] = dlg:add_label("fcinema saltará las escenas marcadas con *", 1, 1, 5, 1)
            intf.items["message"] = dlg:add_label("", 1, 4, 4, 1)
            intf.main.show_warning()
            intf.items['watch'] = dlg:add_button( lang.view_movie, intf.main.watch_movie, 4, 3, 1, 1)
            intf.items['back'] = dlg:add_button( "Atras", intf.main.show, 1, 3, 1, 1)

            intf.items['scene_list'] = dlg:add_list( 1, 2, 4, 1 )
            intf.main.fill_list()
            intf.items['b_skip'] = dlg:add_button( 'Skip', intf.main.skip, 2, 3, 1, 1)
            intf.items['b_nskip'] = dlg:add_button( 'No skip', intf.main.nskip, 3, 3, 1, 1)

            --intf.main.toggle_list()
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

        show_category = function ( label, pos )
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
            ['se'] = '- Explicit sex',
            ['si'] = '- Implicit sex',
            ['sn'] = '- Nudity',
            ['st'] = '- Talking about',
            ['so'] = '- Obscene lan/ges',
            ['v'] = 'Violence & Gore',
            ['p'] = 'Profanity',
            ['ps'] = '- Swearword',
            ['pb'] = '- Blasphemy',
            ['d'] = 'Drugs',
            --['u'] = 'Unkown',
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
                intf.items['scene_list'] = dlg:add_list( 1, 4, 2, 2 )
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
            local txt, level, typ, desc, start, len, subtyp
            for k,v in pairs( data['Scenes'] ) do
                if intf.main.actions[k] then txt = '*' else txt ='  ' end
                level = v['Severity']
                typ = intf.main.label[ v['Category'] ] or 'Unkown'
                if not v['SubCategory'] then v['SubCategory'] = 'u' end
                if v['SubCategory'] == 'u' then subtyp = '' else
                    subtyp = ' ('.. intf.main.label[ v['SubCategory'] ] ..')'
                    subtyp = string.gsub( subtyp, '- ', '' )
                end
                desc = v['AdditionalInfo'] or ''
                start = intf.to_hour( v['Start'], 1 )
                len = intf.to_hour( v['End'] - v['Start'], 1)

                if v['Category'] == 'syn' then
                    --intf.items['list']:add_value( 'Sync scene at '..start..' lasting '..len..' '..desc, k )
                else
                    intf.items['scene_list']:add_value( txt..typ..' level '..level..subtyp..' at '..start..' lasting'..len..' '..desc, k )
                end
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

            intf.items['l_change_lang'] = dlg:add_label( 'Language/Idioma', 1, 1, 1, 1 )
            intf.items['b_change_lang'] = dlg:add_button( lang.b_change_lang, intf.advanced.lang, 4, 1, 1, 1 )
            intf.items['language'] = dlg:add_dropdown( 3, 1, 1, 1)
            intf.items['language']:add_value( "Spanish", 2 )
            intf.items['language']:add_value( "English", 1 )

            intf.items['b_update'] = dlg:add_button( "Update", intf.advanced.update, 4, 7, 1, 1 )

            intf.items["message"] = dlg:add_label("", 2, 8, 3, 1)
            intf.items['b_main'] = dlg:add_button( lang.back, intf.main.show, 1, 8, 1, 1)
        end,

        update = function ( ... )
        -- Download fcinema.lua
            local params = ""
            --local url = 'https://raw.githubusercontent.com/fcinema/vlc-plugin/master/fcinema.lua'
            local url = 'http://fcinema.org/plugin/fcinema.lua'
            local status, response = net.post( params, url )
            intf.msg('')
            if not response then return false end
            system.write( config.path .. "fcinema.lua", response )
            assert( loadfile( config.path .. "fcinema.lua" ) )
            
            
        end,

        donate = function ( ... )
            intf.msg( lang.msg_donate )
            net.openurl( 'http://www.fcinema.org/collaborate' )
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

            intf.items['l_name'] = dlg:add_label( lang.name, 1, 1, 2, 1 )
            intf.items['name'] = dlg:add_text_input( "", 3, 1, 3, 1 )

            intf.items['l_mail'] = dlg:add_label( lang.email, 1, 2, 2, 1 )
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

        show = function ( )

            intf.manual_sync.get_scenes()

            if not fcinema.data['SyncScenes'][sync.steep] then
                intf.msg("No hay escenas de sincronización manual")
                return
            end

            intf.change_dlg()

            intf.items['l_now'] = dlg:add_label( lang.click_at_start , 1, 1, 5, 1 )
            intf.items['l_desc'] = dlg:add_label( (fcinema.data['SyncScenes'][sync.steep]['AdditionalInfo'] or ''), 1, 2, 5, 1 )
            
            intf.items['b_sync_now'] = dlg:add_button( lang.now, intf.manual_sync.now, 3, 3, 1, 1 )            

            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)
            intf.items['b_ok'] = dlg:add_button( lang.cancel, intf.advanced.show, 5, 10, 1, 1)

            intf.items['b_back2'] = dlg:add_button( "<<", intf.manual_sync.jump_backward_2, 1, 7, 1, 1)
            intf.items['b_back'] = dlg:add_button( "<", intf.manual_sync.jump_backward_1, 2, 7, 1, 1)
            intf.items['b_toggle'] = dlg:add_button( "Play / Pause", intf.editor.toggle, 3, 7, 1, 1)
            intf.items['b_next'] = dlg:add_button( ">", intf.manual_sync.jump_fordward_1, 4, 7, 1, 1)
            intf.items['b_next2'] = dlg:add_button( ">>", intf.manual_sync.jump_fordward_2, 5, 7, 1, 1)

            media.go_to( fcinema.data['SyncScenes'][sync.steep]['Start'] - 30 ) -- TODO not sure about this (30s)
            vlc.playlist.play()

        end,

        get_scenes = function ( ... )
            fcinema.data['SyncScenes'] = {}
            for k,v in pairs( fcinema.data['Scenes'] ) do
                if 'syn' == v['Category'] then
                    table.insert( fcinema.data['SyncScenes'] , v )
                end
            end
            vlc.msg.dbg('[Fcinema]'..json.encode(fcinema.data['SyncScenes']))
        end,

        jump_backward_1 = function() media.jump( -2/10 ) end,
        jump_fordward_1 = function() media.jump( 2/10 ) end,
        jump_backward_2 = function() media.jump( -2 ) end,
        jump_fordward_2 = function() media.jump( 2 ) end,

        improve = function ( ... )
            intf.change_dlg()

            intf.items['l_now'] = dlg:add_label( "¿Ves algo de la escena?" , 1, 1, 5, 1 )
            intf.items['l_desc'] = dlg:add_label( (fcinema.data['SyncScenes'][sync.steep]['AdditionalInfo'] or '') , 1, 2, 5, 1 )
            
            intf.items['b_sync_now'] = dlg:add_button( 'No, esta perfecto', intf.manual_sync.perfect, 2, 3, 1, 1 )            
            intf.items['b_visible_begin'] = dlg:add_button( "Si, el principio", intf.manual_sync.visible_begin, 1, 3, 1, 1)
            intf.items['b_visible_end'] = dlg:add_button( "Si, el final", intf.manual_sync.visible_end, 3, 3, 1, 1)

            intf.items['b_preview_o'] = dlg:add_button( lang.b_view_original , intf.manual_sync.preview_o, 4, 4, 2, 1 )
            intf.items['b_preview'] = dlg:add_button( lang.b_view_edited, intf.manual_sync.preview, 1, 4, 2, 1 )

            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)

            intf.manual_sync.preview()
        end,

        check = function ( ... )
            intf.change_dlg()

            intf.items['l_now'] = dlg:add_label( "¿Ves solo esta escena?" , 1, 1, 5, 1 )
            intf.items['l_desc'] = dlg:add_label( (fcinema.data['SyncScenes'][sync.steep]['AdditionalInfo'] or '') , 1, 2, 5, 1 )
            
            intf.items['b_perfect'] = dlg:add_button( 'Si', intf.manual_sync.perfect, 1, 3, 1, 1 )            
            intf.items['b_improve'] = dlg:add_button( "No", intf.manual_sync.improve, 2, 3, 1, 1)
            intf.items['b_mess'] = dlg:add_button( "No, ni siquiera esa escena", intf.manual_sync.show, 3, 3, 1, 1)

            --intf.items['b_preview_o'] = dlg:add_button( lang.b_view_original, intf.manual_sync.preview_o, 4, 4, 2, 1 )
            --intf.items['b_preview'] = dlg:add_button( lang.b_view_edited, intf.manual_sync.preview, 1, 4, 2, 1 )

            intf.items["message"] = dlg:add_label("", 1, 10, 7, 1)

            intf.manual_sync.preview()
            media.go_to( fcinema.data['SyncScenes'][sync.steep]['Start'] )
            edl.loop = true
            sync.steep = 2
        end,

        perfect = function ( ... )
            sync.apply_offset( sync.info['TimeOffset'], sync.info['TimeOffset'], 'Yes' ) -- TODO, just to set as confirmed
            if sync.steep == 1 and fcinema.data['SyncScenes'][2] then
                local diff = fcinema.data['SyncScenes'][2]['Start'] - fcinema.data['SyncScenes'][1]['Start']
                if math.abs( diff / vlc.input.item():duration() ) > 0.5 then
                    sync.steep = 2
                    intf.manual_sync.show()
                    return
                end
            end
            fcinema.share_sync()
            sync.status = 1
            sync.steep = 1
            intf.main.show()
        end,

        visible_begin = function ( ... )
            if sync.steep == 1 then
                sync.apply_offset( sync.info['TimeOffset'] - 0.1, sync.info['SpeedFactor'], 'Yes' )
            else
                sync.calculate_offsets( -0.1 )
            end
            intf.manual_sync.preview()
        end,

        visible_end = function ( ... )
            if sync.steep == 1 then
                sync.apply_offset( sync.info['TimeOffset'] + 0.1, sync.info['SpeedFactor'], 'Yes' )
            else
                sync.calculate_offsets( 0.1 )
            end
            intf.manual_sync.preview()
        end,

        now = function ( )

        -- Apply offset
            local t = media.get_time()
            if not t then return end
            local offset = t - fcinema.data['SyncScenes'][sync.steep]['Start']
            
            if sync.steep == 1 then    
                sync.apply_offset( offset + sync.info['TimeOffset'], sync.info['SpeedFactor'], 'No' )
            else
                sync.calculate_offsets( offset )
            end

            intf.manual_sync.improve()
        end,

        preview_o = function ( ... )
        -- Preview original scene
            media.go_to( fcinema.data['SyncScenes'][sync.steep]['Start'] - 4 )
            vlc.playlist.play()
        end,

        preview = function ( ... )
        -- Preview modified scene
            edl.start[1] = fcinema.data['SyncScenes'][sync.steep]['Start']
            edl.stop[1] = fcinema.data['SyncScenes'][sync.steep]['End']

            media.go_to( edl.start[1] - 4 )
            vlc.playlist.play()
            edl.loop = false
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

            intf.items['l_start'] = dlg:add_button( lang.b_start, intf.editor.go2start, 7, 3, 1, 1 )
            intf.items['Start'] = dlg:add_text_input( "", 8, 3, 2, 1 )
            intf.items['b_start'] = dlg:add_button( lang.now, intf.editor.get_time, 10, 3, 1, 1)

            intf.items['l_end'] = dlg:add_button( lang.b_end, intf.editor.go2end, 7, 4, 1, 1 )
            intf.items['Stop'] = dlg:add_text_input( "", 8, 4, 2, 1 )
            intf.items['b_end'] = dlg:add_button( lang.now, intf.editor.get_time2, 10, 4, 1, 1)

            intf.items['l_desc'] = dlg:add_label( lang.l_more_info, 7, 6, 1, 1 )
            intf.items['Desc'] = dlg:add_text_input( "",8, 6, 3, 1 )

            intf.items['l_type'] = dlg:add_label( lang.l_cat_and_level, 7, 5, 1, 1 )
            intf.items['Type'] = dlg:add_dropdown( 8, 5, 2, 1)
            intf.items['level'] = dlg:add_dropdown( 10, 5, 1, 1)
            for i=1,5 do
                intf.items['level']:add_value( i, i )
            end

            intf.items['l_action'] = dlg:add_label( lang.l_action, 7, 7, 1, 1 )
            intf.items['Action'] = dlg:add_dropdown( 8, 7, 1, 1)
            intf.items['Action']:add_value( lang.l_skip, 1 )
            intf.items['Action']:add_value( lang.l_mute, 2 )
            --intf.items['Action']:add_value( "Sin imagen", 3 )
            --intf.items['Action']:add_value( "Descripción", 4 )

            intf.items["message"] = dlg:add_label("", 1, 8, 7, 1)
            
            intf.editor.dropdown = {}
            for k,v in spairs( intf.main.label ) do
                table.insert( intf.editor.dropdown, k )
                local i = table.maxn( intf.editor.dropdown )
                intf.items['Type']:add_value( v, i )
            end

            intf.items['b_preview'] = dlg:add_button( lang.preview, intf.editor.preview, 8, 2, 2, 1)
            intf.items['b_add'] = dlg:add_button( lang.add_scene, intf.editor.add_scene, 10, 7, 1, 1)
            intf.items['b_delete'] = dlg:add_button( lang.delete_scene, intf.editor.delete_scene, 1, 7, 1, 1)
            intf.items['b_modify'] = dlg:add_button( lang.modify_scene, intf.editor.modify, 3, 7, 2, 1)

            intf.items['b_back2'] = dlg:add_button( "<<", intf.manual_sync.jump_backward_2, 7, 1, 1, 1)
            intf.items['b_back'] = dlg:add_button( "<", intf.manual_sync.jump_backward_1, 7, 2, 1, 1)
            intf.items['b_toggle'] = dlg:add_button( "Play / Pause", intf.editor.toggle, 8, 1, 2, 1)
            intf.items['b_next'] = dlg:add_button( ">", intf.manual_sync.jump_fordward_1, 10, 2, 1, 1)
            intf.items['b_next2'] = dlg:add_button( ">>", intf.manual_sync.jump_fordward_2, 10, 1, 1, 1)

            intf.items['b_upload'] = dlg:add_button( lang.share, intf.editor.request_pass, 8, 8, 2, 1)
            intf.items['b_ok'] = dlg:add_button( lang.b_ready, intf.main.show, 10, 8, 1, 1)
            
            collectgarbage()
            intf.editor.fill_list()

        end,
            
        request_pass = function ( ... )
        -- Deny, movie is not identified globaly (??)
            if string.match( fcinema.data['ImdbCode'], 'p' ) then
                intf.msg( lang.msg_sharing_without_id )
                return
            end

        -- Deny, no scene for manual sync
            local have_sync = false
            for k,v in pairs( fcinema.data['Scenes'] ) do
                if v['Category'] == 'syn' then
                    have_sync = true
                    break
                end
            end
            if not have_sync then
                intf.msg( lang.msg_include_sync )
                return
            end

        -- Deny, movie is out of sync
            if sync.lock() then return end
            
            intf.change_dlg()
            intf.items['l_name'] = dlg:add_label( lang.l_username, 1, 1, 1, 1 )
            intf.items['i_name'] = dlg:add_text_input( config.options.name, 2, 1, 1, 1 )
            intf.items['l_pass'] = dlg:add_label( lang.l_password, 1, 2, 1, 1 )
            intf.items['i_pass'] = dlg:add_password( "", 2, 2, 1, 1 )

            intf.items['l_new_user'] = dlg:add_label( "¿Aun no eres usuario? <a href='http://www.fcinema.org/'>Crear una cuenta</a>", 1, 3, 2, 1 )
            --intf.items['message'] = dlg:add_label( "", 1, 4, 2, 1 )
            intf.items['b_upload'] = dlg:add_button( lang.share, intf.editor.upload, 2, 4, 1, 1)
            intf.items['b_cancel'] = dlg:add_button( lang.cancel, intf.editor.show, 1, 4, 1, 1)

        end,

        upload = function ( ... )
            local pass = intf.items['i_pass']:get_text()
            local user = intf.items['i_name']:get_text()
            config.options.name = user
            if fcinema.upload( user, pass ) then
                intf.editor.show()
                intf.msg( style.ok( lang.l_thanks_for_sharing ) )
            else
                intf.editor.request_pass()
                intf.items['l_name']:set_text( style.err( lang.l_username ))
                intf.items['l_pass']:set_text( style.err( lang.l_password ))
            end
        end,

        -- nextframe = function ( ... )
        --     intf.msg("")
        --     local len = intf.items["len"]:get_value()
        --     media.jump( len*2/10 )
        -- end,

        -- previousframe = function ( ... )
        --     intf.msg("")
        --     local len = intf.items["len"]:get_value()
        --     media.jump( -len*2/10 )
        -- end,

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
            edl.loop = false
            if edl.preview_active == 0 then
                vlc.var.add_callback( vlc.object.input(), "intf-event", edl.one_time_preview )
            end
            vlc.msg.dbg("[Fcinema] Preview started")
            edl.preview_active = 1
        end,        

        get_time = function ()
            intf.msg("")
            local str = intf.to_hour( media.get_time(), 1000 )
            intf.items["Start"]:set_text( str )        
        end,

        get_time2 = function ()
            intf.msg("")
            local str = intf.to_hour( media.get_time(), 1000 )
            intf.items["Stop"]:set_text( str )            
        end,

        go2start = function ()
            intf.msg("")
            local start = intf.to_sec( intf.items["Start"]:get_text() )
            if not start then
                intf.msg( style.err( lang.l_error ) .." Salta al comienzo de la escena")
                return
            end
            media.go_to( start )
        end,

        go2end = function ()
            intf.msg("")
            local stop = intf.to_sec( intf.items["Stop"]:get_text() )
            if not stop then
                intf.msg( style.err( lang.l_error ) .." Salta al final de la escena")
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
                intf.msg( style.err( lang.l_error ) .. lang.invalid_data )
                return
            elseif stop < start then
                intf.msg( style.err( lang.l_error ) .. lang.l_editor_check_length )
                return
            end
        
        local subtyp
        if typ == 'se' or typ == 'sn' or typ == 'st' or typ == 'so'  or typ == 'si' then
            subtyp = typ
            typ = 's'
        elseif typ == 'ps' or typ == 'pb' then
            subtyp = typ
            typ = 'p'
        else
            subtyp = 'u'
        end

        -- Add the scene
            if fcinema.add_scene( start, stop, typ, subtyp, desc, level, action ) == -1 then return end
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
            for k,v in spairs( intf.main.label ) do
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
            if not intf.items['list'] then return end
            intf.items['list']:clear()
            local data = fcinema.data
            local txt, level, typ, desc, start, len, subtyp
            for k,v in pairs( data['Scenes'] ) do
                level = v['Severity']
                typ = intf.main.label[ v['Category'] ] or 'Unkown'
                if not v['SubCategory'] then v['SubCategory'] = 'u' end
                if v['SubCategory'] == 'u' then subtyp = '' else
                    subtyp = ' ('.. intf.main.label[ v['SubCategory'] ] ..')'
                    subtyp = string.gsub( subtyp, '- ', '' )
                end
                desc = v['AdditionalInfo'] or ''
                start = intf.to_hour( v['Start'], 1 )
                len = intf.to_hour( v['End'] - v['Start'], 1)
                if v['Category'] == 'syn' then
                    intf.items['list']:add_value( 'Sync scene at '..start..' lasting'..len..' '..desc, k )
                else
                    intf.items['list']:add_value( typ..' level '..level..subtyp..' at '..start..' lasting'..len..' '..desc, k )
                end
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
        --if dlg then 
            --dlg:delete() -- Throw an error
        --    dlg:hide()
        --    dlg = nil
        --end
    
        --dlg = nil
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
        sec = round( sec, precision )
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
        lang = "eng", --os.getenv("LANG"),
        --token = "1234",
        name = "",
        start_margin = 2/10,
        end_margin = 1/10,
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
        if config.options.lang ~= "eng" then -- Language is not the default, load translation
            config.load_lang( config.options.lang )
        end
    end,

    load_lang = function ( language )
    -- Set user interface language
        local data = fcinema.read( config.path .. language .. ".json" )
        if not data then 
            fcinema.get_language_pack( language )
            data = fcinema.read( config.path .. language .. ".json" )
        end
        if data then
            for k,v in pairs(data) do
                lang[k] = data[k]
            end
            intf.advanced.show()
        else
            intf.msg( style.err( lang.l_error ) .. "Language pack not found" )
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
    last_time = 0,

    activate = function( )
    -- Activate callback for edl, 'edl.check' will be called around 3-5 times/second
        if edl.active then
            if not edl.from_user() then return end
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
                table.insert( edl.start, fcinema.data['Scenes'][k]['Start'] - 3/10)--config.options.start_margin )
                table.insert( edl.stop, fcinema.data['Scenes'][k]['End'] + 1/10)--config.options.end_margin ) -- FIXME
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


        if edl.loop then
            if t > edl.stop[1] - 3/10 then
                media.go_to( edl.start[1] )
            end
            return
        end

    -- Check if current time is in "dark zone"
        if t < edl.stop[1] and t > edl.start[1] then
            if edl.action[1] == 2 then --'Mute'
                media.mute()
            elseif edl.action[1] == 'Dark' then 
                media.dark()
            elseif edl.action[1] == 'Label' then
                media.label('')
            else
                if t < edl.stop[1] - 2/10 then -- avoid loops (jump might go few ms before objective)
                    media.go_to( edl.stop[1] )
                end
            end
            return
        end
    -- Stop preview (this is a one tiem preview )
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
        if edl.pressed and edl.last_pressed < t-7/10 then
            edl.pressed = false
            fcinema.add_scene( edl.first_pressed - 8/10, edl.last_pressed-1/10,'u', 'u', 'Escena sin clasificar', 1, 1 )
            media.unmute()
        end

    -- Check if current time is in "dark zone"
        for i, stop in ipairs( edl.stop ) do
            if t < stop and t > edl.start[i] then
                if edl.action[i] == 2 then --'Mute'
                    media.mute()
                elseif edl.action[i] == 'Dark' then 
                    media.dark()
                elseif edl.action[i] == 'Label' then
                    media.label('')
                else
                    if t < stop - 2/10 then -- avoid loops (jump might go few ms before objective)
                        media.go_to( stop )
                    end
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
                -- TODO: is ok this stuff below
                fcinema.load_movie( data )
                fcinema.add2index( config.path .. config.hash2id_db )
                fcinema.save()
            end
            return data
        end
        
    end,

    load_movie = function ( data )
    
    -- Clean everthing
        sync.status = 0
        sync.syncing = false
        sync.info = {}
        sync.info['TimeOffset'] = 0
        sync.info['SpeedFactor'] = 1
        sync.steep = 1

    -- Compatibility layer
        -- PreviousSync improvements 16/7/14
        if data['PreviousSync'] and not data['PreviousSync'][1] then
            local PreviousSync = {}
            local Sync = {}
            for k,v in pairs( data['PreviousSync'] ) do
                Sync['SpeedFactor'] = 1
                Sync['TimeOffset'] = v
                Sync['Hash'] = k
                Sync['Confirmed'] = 'Yes'
                table.insert( PreviousSync, Sync )
            end
            data['PreviousSync'] = PreviousSync
        end

    -- Load data
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
            intf.msg( "Por favor, comprueba tu conexión a internet")
        end
    end,

    upload = function ( user, pass  )
        local data = json.encode( sync.unsynced_data() )
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
            local data = string.match(response, '{(.+)}')
            if data then
                data = json.decode( '{'..data..'}' )
                if data.Status and data.Status == "Ok" then
                    if data.token then config.options.token = data.token end
                    return true
                end
            end
        end
        
        return false
        
    end,

    share_sync = function ( ... )
        if not config.options.autoshare then return end 
        local params = ""
        params = params .. "action=ShareSync"
        params = params .. "&agent=" .. config.agent
        params = params .. "&version=" .. config.version
        params = params .. "&imdb_code=" .. fcinema.data['ImdbCode']
        params = params .. "&hash="..media.file.hash
        params = params .. "&time_offset="..sync.info['TimeOffset']
        params = params .. "&speed_factor="..sync.info['SpeedFactor']
        params = params .. "&username=" .. config.options.name or ""
        params = params .. "&token=" .. config.options.token or ""

        --params = params .. "&password=" .. pass or ""
                
        local status, response = net.post( params, fcinema.api_url )
        intf.msg('')
        if response then
            local data = string.match(response, '{(.+)}')
            if data then
                data = json.decode( '{'..data..'}' )
                if data.Status and data.Status == "Ok" then
                    if data.token then config.options.token = data.token end
                    return true
                end
            end
        end
        
        return false
    end,

    get_language_pack = function ( language )
        
        local params = ""
        local url = 'fcinema.org/lang/'..language..'.json'
        
        local status, response = net.post( params, url )
        intf.msg('')
        if response then
            vlc.msg.err( response )
            local data = string.match(response, '{(.+)}')
            if data then
                vlc.msg.dbg('[Fcinema] Language pack correctly dowloaded')
                data = json.decode( '{'..data..'}' )
                system.write( config.path .. language .. ".json", json.encode(data) )
                return true
            end
        end
        
        return false
        
    end,

    save = function ( )
    -- Save current movie content

    -- Safety measures
        edl.deactivate()
        if not config.path or config.path == '' then return end
        if not fcinema.data then return end

    -- Restore to orignal
        local data = json.encode( sync.unsynced_data() )

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
    
    add_scene = function ( start, stop, typ, subtyp, desc, level, action )
    -- Add scene to movie content

        local scene = {}
        scene['Start'] = round( start, 1000 )
        scene['End'] = round( stop, 1000 )
        scene['Category'] = typ
        scene['SubCategory'] = subtyp
        scene['Severity'] = level
        scene['Action'] = action
        scene['AdditionalInfo'] = desc or ''
        scene['AddedBy'] = 'Me'

        if not fcinema.data['Scenes'] then
            fcinema.data['Scenes'] = {}
        elseif sync.lock() then return -1 end

    -- Get index
        local i = table.maxn( fcinema.data['Scenes'] ) + 1

    -- Insert values
        fcinema.data['Scenes'][i] = scene

        vlc.msg.dbg( "[Fcinema] New scene added" )

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
    steep = 1,
    info = { ['SpeedFactor'] = 1, ['TimeOffset'] = 0 },

    lock = function ( ... )
    -- Return 'true' if movie is out of sync. Used by some actions that require movie to be synced
        sync.auto()
        if sync.status > 0 and sync.info['Confirmed'] == 'Yes' then 
            return false
        elseif sync.status > 0 then
            intf.manual_sync.check()
            intf.msg( "Comprueba que esta bien calibrado" )
            return true
        elseif sync.syncing == true then
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

    -- Try to complete autosync information if there is no info
        if not fcinema.data['Shots'] and not sync.auto_failed then
            if sync.syncing then
                if sync.status > 0 then
                    local sync_info = sync.read_sync_info()
                    if sync_info then
                        -- Shots must be according to refernce version
                        vlc.msg.dbg('[Fcinema] Including autosync info on filter')
                        local offset = sync.info['TimeOffset'] / sync_info['fps']
                        local speed = sync.info['SpeedFactor']
                        for i,v in ipairs(sync_info['Frame']) do
                            sync_info['Frame'][i] = math.floor( ( v - offset ) / speed )
                        end
                        fcinema.data['Shots'] = sync_info
                        fcinema.save()
                    end
                end
            else
                sync.request_sync_info()
            end
        end

    -- Already synced, return
        if sync.status > 0 then return end

    -- No scenes -> first used this movie -> sync has no sense, set as ref
        if not fcinema.data['Scenes'][1] then
        -- Update applied offset
            sync.info = {}
            sync.info['Hash'] = media.file.hash
            sync.info['SpeedFactor'] = 1
            sync.info['TimeOffset'] = 0
            sync.info['Confirmed'] = 'Yes'

        -- Update sync reference
            fcinema.data['PreviousSync'] = {}
            fcinema.data['PreviousSync'][1] = sync.info
            sync.status = 1
            fcinema.save()
            vlc.msg.dbg('[Fcinema] No scenes, set current as ref')
            return
        end

    -- Look if this file/hash has being synced before
        if fcinema.data['PreviousSync'] and sync.status <= 0 then
            for k,v in pairs(fcinema.data['PreviousSync']) do
                if v['Hash'] == media.file.hash then
                    local confirmed = v['Confirmed'] or 'No'
                    sync.apply_offset( v['TimeOffset'], v['SpeedFactor'], confirmed )
                    sync.status = 3
                    intf.msg( style.ok( "Calibrado ").." gracias a la base de datos")
                    return
                end
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
                sync.apply_offset( offset, sync.info['SpeedFactor'], 'Yes' )
                sync.status = 2
            end
        end
        
    end,


    request_sync_info = function ( )
    -- Launch something that computes shot edges and stores them

    -- If we are syncing there is no need to sync
        if sync.syncing then return end

    -- Clean files, just in case
        os.remove( config.path.."StartShots.log")
        os.remove( config.path.."EndShots.log")
        os.remove( config.path.."begin.avi")
        os.remove( config.path.."end.avi")

    -- Call program according to OS
        if config.os == "win" then
            local vlc_path = vlc.config.datadir()
            local script = vlc_path..'\\lua\\extensions\\fcinema\\GetShots.vbs'
            local endstart = vlc.input.item():duration() - 300
            local cmd = 'start "" "'..script..'" "'..media.file.uri..'" "'..config.path..'" "'..endstart..'" '
            vlc.msg.dbg("[Fcinema] Executing ".. cmd )
            local status = os.execute( cmd )
            if status == 0 then
                vlc.msg.dbg( "[Fcinema] Sync proccess started")
                sync.syncing = true
            else
                sync.status = -1
                sync.auto_failed = true
                vlc.msg.dbg( "[Fcinema] Unable to auto sync" )
            end
        elseif config.os == "lin" then
            sync.status = -1
            sync.auto_failed = true
            vlc.msg.dbg( "[Fcinema] Unable to auto sync" )
        end
    end,

    read_sync_info = function ( ... )
        local sync_info = { ['Frame'] = {}, ['Probability'] = {}, ['Frame2'] = {}, ['Probability2'] = {}, ['fps'] = media.get_fps() }

        if config.os == "win" then
            local log = system.read( config.path.."StartShots.log" )
            if not log or log == "" then return end
            for frame, prob in string.gfind( log, "([^%s]+)%s+([^%s]+)%s+[01]") do
                if prob+0 > 1/10 then
                   table.insert( sync_info['Frame'] , frame+0 )
                   table.insert( sync_info['Probability'] , math.floor(prob*100) )
                end
            end

            local log = system.read( config.path.."EndShots.log" )
            if not log or log == "" then return end
            for frame, prob in string.gfind( log, "([^%s]+)%s+([^%s]+)%s+[01]") do
                if prob+0 > 1/10 then
                   table.insert( sync_info['Frame2'] , frame+0 )
                   table.insert( sync_info['Probability2'] , math.floor(prob*100) )
                end
            end

        elseif config.os == "lin" then
            --os.execute()
            return
        end
        sync.syncing = false
        sync.sync_info = sync_info
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
        for kr,vr in pairs( ref_info['Frame'] ) do
            pr = ref_info['Probability'][kr]
            for ko,vo in pairs( our_info['Frame'] ) do
                po = our_info['Probability'][ko]
                d = vr/fps_r - vo/fps_o
                d = round( d, 25 ) + 5/10/25
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

    calculate_offsets = function ( o2 )
    -- We have first scene fixed, and we want to move second scene o2 extra seconds
        -- (c-> scene times in Current version, r-> scenes times in Reference version, s->speed, o->offset)
        -- c1 = r1*s + o
        -- c2 = r2*s + o + o2
    -- So we want to arrive at
        -- c1 = r1*s_n + o_n
        -- c2 = r2*s_n + o_n
    -- Solving equations we get
        -- s_n = ( r1*s - r2*s - o2 ) / (r1 - r2)
        -- o_n = r1*s + o - r1*s_n

        local r1 = fcinema.data['SyncScenes'][1]['Start']
        local r2 = fcinema.data['SyncScenes'][2]['Start']
        local s = sync.info['SpeedFactor']
        local o = sync.info['TimeOffset']
        local s_n = ( r1*s - r2*s - o2 ) / (r1 - r2)
        local o_n = r1*s + o - r1*s_n
        sync.apply_offset( o_n, s_n, 'Yes' )
    end,

    apply_offset = function ( offset, speed, confirmed )
    -- Apply an offset of 'offset' seconds to all scenes
        if not type( offset ) == 'number' then return end
        local offset = round( offset, 1000 )
        --local speed = round( speed, 10000000 )

    -- Unsync (before doing anything)
        local data = sync.unsynced_data()

    -- Apply synchronization
        for k,v in pairs( data['Scenes']) do
            fcinema.data['Scenes'][k]['Start'] = data['Scenes'][k]['Start']*speed + offset
            fcinema.data['Scenes'][k]['End'] = data['Scenes'][k]['End']*speed + offset
        end

    -- Update applied offset
        sync.info = {}
        sync.info['Hash'] = media.file.hash
        sync.info['SpeedFactor'] = speed
        sync.info['TimeOffset'] = offset
        sync.info['Confirmed'] = confirmed or 'No'

    -- Update sync reference
        if not fcinema.data['PreviousSync'] then
            fcinema.data['PreviousSync'] = {}
        end
        local i = table.maxn( fcinema.data['PreviousSync'] ) + 1
        for k,v in pairs(fcinema.data['PreviousSync']) do
            if v['Hash'] == media.file.hash then
                i = k
                break
            end
        end
        fcinema.data['PreviousSync'][i] = sync.info
        fcinema.save()
    
    -- Display info
        vlc.msg.dbg( "[Fcinema] Synced. Time offset is "..offset.."s and speed factor ." )
        intf.msg( "Calibración total de "..offset.."s y factor de velocidad "..round( speed,10000).."." )
        return true
    end,

    unsynced_data = function ( )
    -- Restore scene sync to original, undo applied offsets (this must be done before sharing/saving the file)
        if not fcinema.data then return end
        local data = deepcopy( fcinema.data ) -- create a copy of the table
        for k,v in pairs( data['Scenes']) do
            data['Scenes'][k]['Start'] = ( data['Scenes'][k]['Start'] - sync.info['TimeOffset'] ) / sync.info['SpeedFactor']
            data['Scenes'][k]['End'] = ( data['Scenes'][k]['End'] - sync.info['TimeOffset'] ) / sync.info['SpeedFactor']
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

    err = 3/10,

    jump = function ( diff )
    -- Jump specified time

    -- Calculate where we want to go
        local t = media.get_time_by_pos()
        if not t then return end
        vlc.msg.dbg("[Fcinema] Jumping "..diff.."s from "..t.."s.")
        local objective = t + diff - media.err

    -- Jump to objective time
        vlc.var.set( vlc.object.input(), "time", objective )

    -- Wait until video is stable
        local a = 0
        for i=1,50000000 do
            a = a + 1
        end

    -- Calculate jumping error
        local time = media.get_time_by_pos()
        local err = time - objective
        media.err = media.err * 8/10 + err * 2/10
        media.err = math.min( math.max( media.err, 1/10 ), 4/10 )
        vlc.msg.dbg( "[Fcinema] Jumping error is " .. media.err )
    end,

    get_time_by_pos = function ( ... )
        local duration = vlc.input.item():duration()
        local position = vlc.var.get( vlc.object.input(), "position" )
        local time = duration * position
        return time
    end,
    get_time = function()
        --TODO: if media.file.hasInput == false then return end
        return vlc.var.get( vlc.object.input(), "time" )
    end,

    get_fps = function ()
        local info = vlc.input.item():info()
        local fps
        for k,v in pairs(info) do
            if tonumber(k) then
                fps = tonumber(k)
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
            if not data_start or not file:seek("end", -chunk_size) then
                vlc.msg.dbg("[Fcinema] Imposible leer fichero")
                media.file.hash = 'n'..media.file.stat.creation_time
                return false
            end
            size = file:seek("end", -chunk_size) + chunk_size
            data_end = file:read(chunk_size)
            file = nil
        end
        
    -- Compute hash
        vlc.msg.dbg("[Fcinema] Computing hash")
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

function load_update(  )
    if not file_exist( config.path .. "fcinema.lua" ) then return end
    local conf = config
    loaded_chunk = assert( loadfile( config.path .. "fcinema.lua" ) )
    loaded_chunk()
    config = conf
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
        if file_exist( v .. fcinema_path .. slash..config.hash2id_db ) then
            config.path = v .. fcinema_path .. slash
            vlc.msg.dbg('[Fcinema] Cache already exist')
            load_update()
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
            vlc.msg.dbg('[Fcinema] New path for cache finded')
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

function spairs(t, order)
-- thaks to Michal Kottman on http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function round( value, precision )
    return math.floor(value*precision)/precision
end
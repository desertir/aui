--[[--------------------------------------------------
FileName: utils.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------
utils = {} -- таблица для сервисных функций

------------------------------------------------------------------------------------------------------------------
--[[local function setEditMode(bool)
    aui.EDIT_MODE = bool
end]]

------------------------------------------------------------------------------------------------------------------
-- 
_G.class '_cui_script_wnd' (CUIScriptWnd)

function _cui_script_wnd:__init(obj) super()
    self.obj = obj
end

function _cui_script_wnd:__finalize() end

function _cui_script_wnd:OnKeyboard(dik, keyboard_action) --CUIScriptWnd.OnKeyboard(self,dik,keyboard_action)
    if self.obj.OnKeyboard then
        self.obj:OnKeyboard(dik, keyboard_action)
    end
end

function _cui_script_wnd:Update()
    CUIScriptWnd.Update(self)
    
    if self.obj.Update then
        self.obj:Update()
    end
end

utils._cui_script_wnd = _G._cui_script_wnd
_G._cui_script_wnd = nil


------------------------------------------------------------------------------------------------------------------
-- при создании, данное окно добавляется в таблицу наследников родительского окна
function utils.add_child_to_parent (wnd, pos)
    local parent = utils.get_parent(wnd)
    local childs = utils.get_childs_array(parent)
    pos = pos or #childs+1
    table.insert(childs, pos, wnd)
    return wnd
end

------------------------------------------------------------------------------------------------------------------
-- для всего дерева наследников окна выполняется функция 'f' с аргументами '...'
-- сканирование по наследникам производиться от главного окна к самому 'младшему' наследнику
-- окно отступа (padding) тоже находиться в таблице наследников, но его не нужно учитывать как наследника
-- оно обрабатывается особым образом, т.к. в контексте AUI является неотделимой частью главного окна
function utils.all_childs_down (wnd, f, ...)
    local childs = utils.get_childs_array(wnd)
    for i = 1, #childs do
        local obj = childs[i]
        local id  = utils.get_id(wnd)
        if id ~= aui.ID_BG and id ~= aui.ID_PAD then
            f(obj, ...)
            utils.all_childs_down(obj, f, ...)
        end
    end
end

------------------------------------------------------------------------------------------------------------------
-- см. utils.all_childs_down, но сканирование производиться от 'младших' наследников к главному окну
function utils.all_childs_up (wnd, f, ...)
    local childs = utils.get_childs_array(wnd)
    for i = 1, #childs do
        local obj = childs[i]
        local id  = utils.get_id(wnd)
        if id ~= aui.ID_BG and id ~= aui.ID_PAD then
            utils.all_childs_up(obj, f, ...)
            f(obj, ...)
        end
    end
end

------------------------------------------------------------------------------------------------------------------
function utils.create_cxml ()
    local cxml = CScriptXmlInit()
    cxml:ParseFile(aui.XML_NAME..".xml")
    return cxml
end

------------------------------------------------------------------------------------------------------------------
function utils.create_luaxml (wnd)
    local new = xml.new("aui")
    local luaxml = utils.get_luaxml(wnd)
    new:append(luaxml)
    new:save(aui.XML_PATH) -- table.print(x)
    return luaxml
end

------------------------------------------------------------------------------------------------------------------
-- производится сам факт создания CUI окна без добавления его к родителю
function utils.create_cui_wnd (wnd)
    local luaxml = utils.assert(utils.create_luaxml(wnd), is_table)
    local cxml   = utils.assert(utils.create_cxml(), is_userdata)
    local db     = utils.get_db(wnd)
    local id     = utils.assert(luaxml[0], is_string)
    local parent = utils.get_obj(db.parent)
    if db.class == 'window' then
        db.obj = cxml:InitWindow(id, db.num, parent)
    else
        db.obj = cxml[db.func](cxml, id, parent)
    end
    
    if aui.window.AUTO_DELETE then
        db.obj:SetAutoDelete(true)
    end
    
    return wnd
end

------------------------------------------------------------------------------------------------------------------
-- функция 'f' с аргументами '...' выполняется только для всех 'прямых' наследников окна
function utils.each_child (wnd, f, ...)
    local childs = utils.get_childs_array(wnd)
    for i = 1, #childs do
        local obj = childs[i]
        local id = utils.get_id(obj)
        if id ~= aui.ID_BG and id ~= aui.ID_PAD then
            f(obj, ...)
        end
    end
end

------------------------------------------------------------------------------------------------------------------
-- поиск субтаблицы LuaXML в базе данных окна по тегу
function utils.find_luaxml_tag (wnd, tag)
    local luaxml = utils.get_luaxml(wnd)
    return luaxml:find(tag)
end

------------------------------------------------------------------------------------------------------------------
function utils.format_text (text, wnd)
    --text = '    abcd e\nfghij klm nopqrs\nt uvwxyz abcd\ne fghij klm\n    nopqrs t\n uvwxyz'
    --if true then return text end
    local font = aui.window.DEFAULT_FONT
    local f = utils.find_luaxml_tag(wnd,'font')
    if f then font = f.font end
    local f = utils.find_luaxml_tag(wnd,'text')
    if f then font = f.font end
    ------------------------------------------------------------------------------------------------------------------
    local t = {''}
    local count = 0
    local width = math.floor(utils.get_xml_rect_width(wnd)*aui.WIDTH_RATIO)
    --print(utils.get_xml_rect_width(wnd),width)
    local CW = aui.DEVICE_RATIO >= 1.6 and 3 or aui.DEVICE_WIDTH >= 1024 and 2 or 1
    local space_symbol = '-'
    local space_len = (font == 'small' and 8) or (font == 'medium' or font == 'di') and fonts[font][032] or fonts[font][032][CW]
    local new_s = text:gsub(' ',space_symbol)

    local new   = true
    local word  = false
    local word_hash1 = {'',0}
    local word_hash2 = {'',0}
-- "arial_14"
-- "graffiti19"
-- "graffiti22"
-- "graffiti32"
-- "graffiti50"
-- "letterica16"
-- "letterica18"
-- "letterica25"
-- "medium"
-- "di"
-- "small"
    local function _char_len(char)
        if font == 'small' then
            return 8
        elseif font == 'medium' or font == 'di' then
            return fonts[font][char:byte()]
        else
            return fonts[font][char:byte()][CW]
        end
    end
    
    local function fill_space()
        local rest = width - count
        local count_spaces = math.floor(rest/space_len)
        t[#t] = t[#t] .. (space_symbol):rep(count_spaces)
        count = 0
    end

    local function fill_word()
        if word_hash1[2] + word_hash2[2] > width then
            t[#t] = t[#t] .. word_hash1[1]
            t[#t+1] = word_hash2[1]
            count = word_hash2[2]
        elseif word_hash2[2] > 0 then
            fill_space()
            if not t[#t]:match('[^'..space_symbol..']') then table.remove(t,#t) end
            t[#t+1] = word_hash1[1] .. word_hash2[1]
            count = word_hash1[2] + word_hash2[2]
        else
            t[#t] = t[#t] .. word_hash1[1]
            count = count + word_hash1[2]
        end
        word_hash1 = {'',0}
        word_hash2 = {'',0}
    end

    local function parse_text(text)
        for i = 1, #text+1 do -- +1 для посдежнего вызова функции 'fill_word'
            local char = text[i]
            if word then
                fill_word()
                word = false
            end

            if char == '' then return end -- оптимизация тут
        --print(width , count , space_len)
            if char == '\n' then
                fill_space()
                new = true
                t[#t+1] = ''
            elseif char == space_symbol then 
                if new then
                    if width - count >= space_len then
                        t[#t] = t[#t] .. space_symbol
                        count = count + space_len
                    else
                        t[#t+1] = ''
                        new   = false
                        count = 0
                    end
                    --
                elseif width - count >= space_len then
                    t[#t] = t[#t] .. space_symbol
                    count = count + space_len
                end
            else
                word = true
                new  = false
                local len = fonts[font][char:byte()][CW]
                --print('>',char,char:byte())
                local w = word_hash1[2] + len
                if count + w <= width then
                    word_hash1 = {word_hash1[1] .. char, w}
                else 
                    local add = word_hash2[2] + len
                    if add <= width then 
                        word_hash2 = {word_hash2[1] .. char, add}
                    else
                        fill_word()
                        count = 0
                        t[#t+1] = char
                    end
                end
            end
        end
    end

    parse_text(new_s)
    return table.concat(t,' ')
end

------------------------------------------------------------------------------------------------------------------
-- получение AUI объекта статика, определяющего цвет фона основного окна
function utils.get_background (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.bg, is_userdata)
end

------------------------------------------------------------------------------------------------------------------
-- получение массива, значениями которого являются AUI объекты окон-наследников
function utils.get_childs_array (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.childs, is_table)
end

------------------------------------------------------------------------------------------------------------------
-- получение базы данных объекта 'window'. У каждого объекта, созданного(создаваемого) с помощью 'window'
-- присутствует база данных. Её отсутствие - критическая ошибка.
-- не получение базы данных необходимо пресекать на корню.
function utils.get_db (wnd)
    utils.assert(wnd, is_userdata)
    return utils.assert(wnd[aui.ID_DB], is_table)
end

------------------------------------------------------------------------------------------------------------------
-- получение названия тега
function utils.get_id (wnd)
    local luaxml = utils.get_luaxml(wnd)
    return utils.assert(luaxml[0], is_string)
end

------------------------------------------------------------------------------------------------------------------
-- получение таблицы - объекта LuaXML
function utils.get_luaxml (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.luaxml, is_table)
end

------------------------------------------------------------------------------------------------------------------
-- получение объекта LuaXML с тегом 'tag', если нет такого тэга, то он создаётся и возвращается
function utils.get_luaxml_tag (wnd, tag)
    local luaxml = utils.get_luaxml(wnd)
    return luaxml:get(tag)
end

------------------------------------------------------------------------------------------------------------------
-- получение CUI (оригинального) объекта окна
function utils.get_obj (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.obj, is_userdata)
end

------------------------------------------------------------------------------------------------------------------
 -- получение AUI объекта окна 'padding'
function utils.get_pad (wnd)
    local db = utils.get_db(wnd)
    return db.pad
end

------------------------------------------------------------------------------------------------------------------
--  получение таблицы с размерами отступа для наследуемых окон
function utils.get_padding (wnd)
    local style = utils.get_style(wnd)
    return utils.assert(style.padding, is_table)
end

------------------------------------------------------------------------------------------------------------------
-- получение AUI объекта родительского окна
function utils.get_parent (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.parent, is_userdata)
end

------------------------------------------------------------------------------------------------------------------
-- получение AUI объекта окна 'script_wnd'
function utils.get_super (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.super, is_userdata)
end

------------------------------------------------------------------------------------------------------------------
-- получение таблицы с настройками окна
function utils.get_style (wnd)
    local db = utils.get_db(wnd)
    return utils.assert(db.style, is_table)
end

------------------------------------------------------------------------------------------------------------------
-- получение таблицы с исходными(задаваемыми при создании) размерами окна
function utils.get_source_rect (wnd)
    local style = utils.get_style(wnd)
    return utils.assert(style.rect, is_table)
end

------------------------------------------------------------------------------------------------------------------
function utils.get_source_rect_x (wnd)
    local rect = utils.get_source_rect(wnd)
    return rect.x
end

------------------------------------------------------------------------------------------------------------------
function utils.get_source_rect_y (wnd)
    local rect = utils.get_source_rect(wnd)
    return rect.y
end

------------------------------------------------------------------------------------------------------------------
function utils.get_source_rect_width (wnd)
    local rect = utils.get_source_rect(wnd)
    return rect.w
end

------------------------------------------------------------------------------------------------------------------
function utils.get_source_rect_height (wnd)
    local rect = utils.get_source_rect(wnd)
    return rect.h
end

------------------------------------------------------------------------------------------------------------------
-- получение таблицы с пересчитанными размерами окна
function utils.get_xml_rect (wnd)
    return  {   utils.get_xml_rect_x(wnd),
                utils.get_xml_rect_y(wnd),
                utils.get_xml_rect_width(wnd),
                utils.get_xml_rect_height(wnd)
            }
end

------------------------------------------------------------------------------------------------------------------
function utils.get_xml_rect_x (wnd)
    local luaxml = utils.get_luaxml(wnd)
    return luaxml.x
end

------------------------------------------------------------------------------------------------------------------
function utils.get_xml_rect_y (wnd)
    local luaxml = utils.get_luaxml(wnd)
    return luaxml.y
end

------------------------------------------------------------------------------------------------------------------
function utils.get_xml_rect_width (wnd)
    local luaxml = utils.get_luaxml(wnd)
    return luaxml.width
end

------------------------------------------------------------------------------------------------------------------
function utils.get_xml_rect_height (wnd)
    local luaxml = utils.get_luaxml(wnd)
    return luaxml.height
end

------------------------------------------------------------------------------------------------------------------
-- создаётся новое CUI окно и в родителя добавляется ссылка
-- также создаётся статики фона и отступа
-- статик фона накладывается под!!! основное окно.
function utils.init (wnd)
    local id = utils.get_id(wnd)
    if id ~= aui.ID_BG --[[and id ~= aui.ID_PAD]] then
        local db     = utils.get_db(wnd)
        local parent = utils.get_parent(wnd)
        local rect   = utils.get_xml_rect(wnd)
        
        db.bg  = aui.static(parent, aui.ID_BG, rect)
                    :set_texture(aui.BG_DEFAULT_TEXTURE, rect)
                    :set_colour(0,255,255,255)
        -- WARNING!!! Эту проверку сделал для теста, чтобы подсвечивать статик паддинга.
        -- В принципе можно и оставить насовсем. Ну или удалить, но раскомментить --[[and id ~= aui.ID_PAD]]
        -- в проверке выше
        if id ~= aui.ID_PAD then
            db.pad = aui.static(parent, aui.ID_PAD, rect)
            utils.add_child_to_parent(wnd)
        end
    end
    
    utils.create_cui_wnd(wnd)
    
    return wnd
end

------------------------------------------------------------------------------------------------------------------
function utils.msg (msg)
    print('>>> MESSAGE >>> : '..msg)
end

------------------------------------------------------------------------------------------------------------------
function utils.new_id ()
    aui.XML_TAG_COUNTER = aui.XML_TAG_COUNTER + 1
    return aui.XML_TAG_PREFIX .. aui.XML_TAG_COUNTER
end

------------------------------------------------------------------------------------------------------------------
function utils.normalize_args (args)
    local parent, id, rect, source, num --(num только для класса window)
    if is_userdata(args[1]) then parent = table.remove(args,1) end
    for i = 1, #args do
        local arg = args[i]
        if     is_string  (arg) then id     = arg
        elseif is_table   (arg) then rect   = arg
        elseif is_userdata(arg) then source = arg
        elseif is_number  (arg) then num    = arg
        end
    end
    
    return parent, id, rect, source, num
end

------------------------------------------------------------------------------------------------------------------
-- перерисовка окна. Установка стиля, текста, угла поворота статика
function utils.refresh (wnd)
    local style = utils.get_style(wnd)
    utils.set_rect(wnd)
    if style.text  then wnd:set_text (style.text) end
    if style.angle then wnd:set_texture_angle (style.angle) end
end

------------------------------------------------------------------------------------------------------------------
function utils.reinit_childs (wnd, bool)  -- При вызове без 'bool' все наследники данного окна деаттачаться, а уже их наследники нет
                                        -- Нет необходиости, т.к. они автоматически деаттачаться с родителем
                                        -- Для изменения только наследников вызывать просто utils.reinit_childs(wnd)
    local childs = utils.get_childs_array(wnd)
    for i = 1, #childs do 
        local child = childs[i] --print(utils.get_id(w))
        if utils.get_db(child).update then
            if not bool then
                utils.get_obj(utils.get_parent(child)):DetachChild(utils.get_obj(child))
            end
            utils.create_cui_wnd(child)
            utils.refresh(child)
            utils.reinit_childs(child,true)
            --collectgarbage()
        end
    end
    return wnd
end

------------------------------------------------------------------------------------------------------------------
function utils.reinit (wnd)
    if utils.get_db(wnd).update then
        utils.get_obj(utils.get_parent(wnd)):DetachChild(utils.get_obj(wnd))
        if utils.get_db(wnd).class == 'script_wnd' then
            utils.reinit_childs(wnd,true)
        else
            utils.create_cui_wnd(wnd)
            utils.refresh(wnd)
            utils.reinit_childs(wnd,true) --!!! если есть наследнинки, то тоже перерисовать
        end
        --collectgarbage()
    end
    return wnd
end

------------------------------------------------------------------------------------------------------------------
function utils.remove_child_from_parent (wnd)
    local childs = utils.get_childs_array(utils.get_parent(wnd))
    if not is_table(childs) then return end
        for i = 1, #childs do
            if utils.get_id(childs[i]) == utils.get_id(wnd) then
                return table.remove(childs,i)
            end
        end
end

------------------------------------------------------------------------------------------------------------------
function utils.set_db (wnd, parent, id, rect, source, num)
    wnd[aui.ID_DB] = {}
    
    rect = rect or {}
    local db = wnd[aui.ID_DB]
    
    db.class = wnd.class ; wnd.class = nil -- сохранить служебные данные и  зачистить их
    db.func  = wnd.func  ; wnd.func  = nil
    db.num   = num -- только для класса 'aui.window'
    db.super = parent and utils.get_super(parent) or wnd -- первый объект - это объект 'script_wnd'
    
    parent = parent or db.super
    
    db.parent = utils.get_pad(parent) or parent --or db.super -- если 'parent' не указан, то родителем будет объект 'script_wnd'
    
    local update = utils.get_db(db.parent).update -- может быть - true, false или nil
    db.update = update or (is_nil(update) and aui.UPDATE) or update
    db.childs = {} -- массив со ссылками да дочерние объекты в порядке их создания (Заполнять при аттаче)
    db.style  = source and table.copy(source.style) or
                {   -- text
                    -- bg_colour
                    rect    = {x = rect[1], y = rect[2], w = rect[3], h = rect[4]},
                    margin  = {}   ,
                    padding = {left=0,top=0,right=0,bottom=0}   ,
                    --angle            = 0,
                }

    db.luaxml = source and table.copy(source.luaxml, 1) or xml.new{} -- обязательные значения при создании объекта LuaXML, потом могут меняться
    db.luaxml[0] = id or utils.new_id()
    
    utils.set_rect(wnd)
    
    return db
end

------------------------------------------------------------------------------------------------------------------
function utils.set_rect (wnd, x, y, w, h)
--print(utils.get_id(wnd))
    local parent       = utils.get_parent(wnd)
    local parent_db    = utils.get_db(parent)
    local parent_style = parent_db.style
    local parent_rect  = parent_style.rect
    
    local self_db     = utils.get_db(wnd)
    local self_style  = self_db.style
    local self_rect   = self_style.rect
    local self_margin = self_style.margin
    
    local is_self = (utils.get_id(wnd) == utils.get_id(parent))
    local parent_w = is_self and aui.BAZE_WIDTH  or parent_rect.w
    local parent_h = is_self and aui.BAZE_HEIGHT or parent_rect.h
    
    x = self_style.margin.left or x or self_rect.x or 0
    y = self_style.margin.top or y or self_rect.y or 0
    w = w or self_rect.w or parent_w or aui.BAZE_WIDTH
    h = h or self_rect.h or parent_h or aui.BAZE_HEIGHT
    
    if self_margin.right then
        w = parent_w - x - self_margin.right
    end
    
    if self_margin.bottom then
        h = parent_h - y - self_margin.bottom
    end
    
    self_style.rect = {x=x,y=y,w=w,h=h}
    
    if self_db.bg then
        if self_db.class ~= "script_wnd" then
            utils.set_rect(self_db.bg, x, y, w, h)
        end
    end
    -- LuaXml -----------------------------------------
    local wide = utils.get_super(wnd):get_wide_scale()
    x = x/wide
    w = w/wide
    
    self_db.luaxml.x      = x
    self_db.luaxml.y      = y
    self_db.luaxml.width  = w
    self_db.luaxml.height = h
    
    if self_db.obj then
        self_db.obj:SetWndRect(x,y,w,h)
    end
end

------------------------------------------------------------------------------------------------------------------
-- запись цепочки вызовов в лог
function utils.trace (msg, level)
    print('--------- AUI ERROR ---------\n'..debug.traceback(msg or '', level or 2)..'\n------- END AUI ERROR -------')
end

------------------------------------------------------------------------------------------------------------------
-- проверяет, соответствует ли 'obj' значению 'val'.
-- если соответствует, то возвращает 'obj', иначе следует запись в лог, а затем остановка работы скрипта.
-- 'val' может быть функцией проверки значения'obj'
function utils.assert (obj, val, msg)
    local cond = is_function(val) and val(obj) or (obj == val)
    if cond then
        return obj
    end
    utils.trace(msg, 3) -- записать в лог
    assert(false)   -- остановить Lua
end

------------------------------------------------------------------------------------------------------------------
--[[local function utils.create_cui_wnd (db)
    local wnd = db.super
    utils.get_obj(wnd):Init(unpack(utils.get_xml_rect(wnd)))
    utils.reinit_childs(wnd,true)
    return wnd
end]]
------------------------------------------------------------------------------------------------------------------
--[[local function _copyChilds ()
    
end]]
------------------------------------------------------------------------------------------------------------------
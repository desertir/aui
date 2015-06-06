--[[--------------------------------------------------
FileName: window.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

local utils = aui.utils

------------------------------------------------------------------------------------------------------------------
class 'window'

window.AUTO_DELETE  = true
window.DEFAULT_FONT = "letterica16"

------------------------------------------------------------------------------------------------------------------
function window:__init (...)
    self.class = 'window'
    self.func = 'InitWindow'
    
    utils.set_db(self, utils.normalize_args{...})
    utils.init(self)
end

------------------------------------------------------------------------------------------------------------------
function window:__finalize () end

------------------------------------------------------------------------------------------------------------------
local function set_update (obj, bool_childs)
        utils.get_db(obj).update = to_boolean(bool_childs)
    end

function window:update_ui (update_self, update_childs)
    --[[if bool_self == false then
        utils.get_db(self).update = false
        utils.each_child(set_update,self,bool_childs)
    else
        utils.get_db(self).update = true
        utils.each_child(set_update,self,is_false(bool_childs) and false or true)
        utils.reinit(self)
    end
    return self]]
    local upd_self = not is_false(update_self)
    utils.get_db(self).update = upd_self
    
    update_childs = upd_self and not is_false(update_childs) or update_childs
    utils.all_childs_down(self, set_update, update_childs)
    
    if upd_self then
        utils.reinit(self)
    end

    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_parent (parent)
    self:show(false)
    parent = is_userdata(parent) and parent or is_string(parent) and self:get_obj_by_id(parent) or nil
    
    if parent then
        utils.get_db(self).parent = parent
        utils.reinit_childs(utils.init(self),true)
    end
    
    return self
end

------------------------------------------------------------------------------------------------------------------
--[[function window:attach_child(wnd)
    utils.add_child_to_parent(wnd)
    utils.get_obj(self):AttachChild(utils.get_obj(wnd))
end]]

------------------------------------------------------------------------------------------------------------------
--[[function window:detach_child(wnd)
    local function f(wnd)
        local x = utils.get_childs_array(wnd)
        for _,obj in ipairs(x) do
            f(obj)
            local child = utils.remove_child_from_parent(obj)
            if child then print('XXX')
                utils.get_obj(wnd):DetachChild(utils.get_obj(child))
            end
        end
    end
    f(wnd)
    local child = utils.remove_child_from_parent(wnd)
    if child then
        utils.get_obj(self):DetachChild(utils.get_obj(child))
    end
end]]

------------------------------------------------------------------------------------------------------------------
function window:enable (bool)
    utils.get_obj(self):Enable(bool)
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:get_font ()
    return utils.get_obj(self):GetFont()
end

------------------------------------------------------------------------------------------------------------------
--[[function window:get_window_name ()
    return utils.get_obj(self):WindowName()
end]]

-- set POS and SIZE ----------------------------------------------------------------------------------------------
function window:set_margin (left,top,right,bottom)
    local margin = utils.get_style(self).margin
    
    margin.left   = left   or margin.left
    margin.top    = top    or margin.top
    margin.right  = right  or margin.right
    margin.bottom = bottom or margin.bottom
    
    utils.set_rect(self)
    utils.all_childs_down(self, utils.refresh)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_margin_left   (left)   return self:set_margin(left)                  end
function window:set_margin_top    (top)    return self:set_margin(nil, top)              end
function window:set_margin_right  (right)  return self:set_margin(nil, nil, right)       end
function window:set_margin_bottom (bottom) return self:set_margin(nil, nil, nil, bottom) end

------------------------------------------------------------------------------------------------------------------
function window:set_padding (left,top,right,bottom)
    local db = utils.get_db(self)
    local bg    = db.bg
    local style = db.style
    local padding  = style.padding
    
    padding.left   = left   or padding.left
    padding.top    = top    or padding.top
    padding.right  = right  or padding.right
    padding.bottom = bottom or padding.bottom
    
    local w = utils.get_xml_rect_width(bg) - padding.left - padding.right
    local h = utils.get_xml_rect_height(bg) - padding.top - padding.bottom
  
    db.pad:set_wnd_rect(padding.left, padding.top, w, h)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_padding_left   (left)   return self:set_padding(left)                  end
function window:set_padding_top    (top)    return self:set_padding(nil, top)              end
function window:set_padding_right  (right)  return self:set_padding(nil, nil, right)       end
function window:set_padding_bottom (bottom) return self:set_padding(nil, nil, nil, bottom) end

------------------------------------------------------------------------------------------------------------------
function window:set_wnd_rect (x,y,w,h)
    if  is_userdata(x) then
        x,y,w,h = x.x1, x.y1, x.x2, x.y2
    elseif is_table(x) then
        x,y,w,h = unpack(x)
    end
    
    local style = utils.get_style(self)
    
    if is_number(x) then style.margin.left   = nil end
    if is_number(y) then style.margin.top    = nil end
    if is_number(w) then style.margin.right  = nil end
    if is_number(h) then style.margin.bottom = nil end
    
    utils.set_rect(self,x,y,w,h)
    utils.all_childs_down(self, utils.refresh)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_wnd_pos  (x,y) return self:set_wnd_rect(x, y)             end
function window:set_wnd_size (w,h) return self:set_wnd_rect(nil, nil, w, h)   end
function window:set_wnd_x    (x)   return self:set_wnd_rect(x)                end
function window:set_wnd_y    (y)   return self:set_wnd_rect(nil, y)           end
function window:set_width    (w)   return self:set_wnd_rect(nil, nil, w)      end
function window:set_height   (h)   return self:set_wnd_rect(nil, nil, nil, h) end

------------------------------------------------------------------------------------------------------------------
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
function window:set_font (font,a,r,g,b) -- устанавливается в тег <font>
    if is_table(a) then
        a,r,g,b = unpack(a,r,g,b)
    end
    
    local f = utils.get_luaxml_tag(self,'font')
    
    if is_string(font) then
        f.font = font
    end
    
    if is_number(a) then f.a = a end
    if is_number(r) then f.r = r end
    if is_number(g) then f.g = g end
    if is_number(b) then f.b = b end

    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_font_colour (a,r,g,b)
    self:set_font(nil,a,r,g,b)
    return self
end

-- get POS and SIZE ----------------------------------------------------------------------------------------------
function window:get_rect       () return utils.get_xml_rect(self) end
function window:get_x          () return utils.get_xml_rect_x(self) end
function window:get_y          () return utils.get_xml_rect_y(self) end
function window:get_width      () return utils.get_xml_rect_width(self) end
function window:get_height     () return utils.get_xml_rect_height(self) end
function window:get_parent     () return utils.get_parent(self) end
function window:get_id         () return utils.get_id(self) end -- потом может объденить с window_name
function window:is_auto_delete () return utils.get_obj(self):IsAutoDelete() end
function window:is_enabled     () return utils.get_obj(self):IsEnabled() end
function window:is_shown       () return utils.get_obj(self):IsShown() end

------------------------------------------------------------------------------------------------------------------
function window:get_pos ()
    return utils.get_xml_rect_x(self),utils.get_xml_rect_y(self)
end

------------------------------------------------------------------------------------------------------------------
function window:get_size ()
    return utils.get_xml_rect_width(self),utils.get_xml_rect_height(self)
end

------------------------------------------------------------------------------------------------------------------
function window:reset_pp_mode ()
    utils.get_obj(self):ResetPPMode()
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_auto_delete (bool)
    utils.get_obj(self):SetAutoDelete(bool)
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_pp_mode ()
    utils.get_obj(self):SetPPMode()
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:show (bool)
    utils.get_obj(self):Show(bool)
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_id (str)
    utils.get_luaxml(self)[0] = str
    return self
end

------------------------------------------------------------------------------------------------------------------
--[[function window:set_window_name (str)
    if is_empty(str) then return end -- is_empty также проверяет строка ли это
    utils.get_obj(self):SetWindowName(str)
    return self
end]]

------------------------------------------------------------------------------------------------------------------
function window:get_obj_by_id (str)
    local childs = utils.get_childs_array(self)
    for i = 1, #childs do
        local w = childs[i]
        if w:get_id() == str then
            return w
        else
            local wnd = w:get_obj_by_id(str)
            if wnd then return wnd end
        end
    end
end

------------------------------------------------------------------------------------------------------------------
function window:copy_from_wnd (wnd, all)
    --self:show(false)
    local db_source = utils.get_db(wnd)
    local db_target = utils.get_db(self)
    local mem_id = db_target.luaxml[0]

    db_target.style  = table.copy(db_source.style)
    db_target.luaxml = table.copy(db_source.luaxml,1)
    
    if db_target.bg then db_target.bg:set_wnd_rect(utils.get_xml_rect(wnd)) end
    db_target.luaxml[0] = mem_id
    
    if all then
        local childs_source = utils.get_childs_array(wnd)
        for i = 1, #childs_source do
            local child_source = childs_source[i]
            aui[utils.get_db(child_source).class](self, utils.get_id(child_source)):copy_from_wnd(child_source, true)
        end
    end

    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
local function _connect (func, ...)
    local arg = {...}
    return  function (obj)
                local x = arg
                func(obj, unpack(x))
            end
end

function window:connect (event, func, ...)
    utils.get_obj(  utils.get_super(self)):AddCallback(utils.get_id(self),
                    event,
                    _connect(func, ...),
                    utils.get_super(self)
                )
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_bg_texture (texture,x,y,w,h)
    utils.get_background(self):SetTexture(texture,x,y,w,h)
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_bg_colour (a,r,g,b)
    if is_table(a) then
        a,r,g,b = unpack(a)
    end
    
    local db = utils.get_db(self)
    --db.style.bg_colour = {a,r,g,b}
    db.bg:set_colour(a,r,g,b)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_bg_light (anim, cyclic, text, texture, alpha)
    local bg_static = utils.get_background(self)
    bg_static:set_light(anim, cyclic, text, texture, alpha)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_bg_xform (anim, cyclic)
    utils.get_background(self):SetXform(anim, cyclic)
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:set_pos_on_parent (pos)
    utils.add_child_to_parent(utils.remove_child_from_parent(self), pos)
    utils.reinit_childs(utils.get_parent(self))
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function window:get_child_at_pos (pos)
    return utils.get_childs_array(self)[pos]
end

------------------------------------------------------------------------------------------------------------------
function window:get_pos_on_parent ()
    local childs = utils.get_childs_array(utils.get_parent(self))
    if not is_table(childs) then return end
    for i = 1, #childs do
        if utils.get_id(childs[i]) == utils.get_id(self) then
            return i
        end
    end
end

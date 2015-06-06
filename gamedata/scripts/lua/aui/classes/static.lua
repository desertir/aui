--[[--------------------------------------------------
FileName: static.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

local utils = aui.utils

class 'static' (aui.window)

static.IS_STRETH  = true
static.IS_CLIPPER = true

------------------------------------------------------------------------------------------------------------------
function static:__init (...)
    self.class = 'static'
    self.func = 'InitStatic'
    
    local db = utils.set_db(self, utils.normalize_args{...})
    local xml = db.luaxml
    
    xml.stretch = self.IS_STRETH  and 1 -- изначально текстуры будут растягиваться
    xml.clipper = self.IS_CLIPPER and 1 -- изначально текстуры будут обрезаться
    
    utils.init(self)
end

------------------------------------------------------------------------------------------------------------------
function static:__finalize() end

------------------------------------------------------------------------------------------------------------------
function static:get_clipper_state   () return utils.get_obj(self):GetClipperState()   end
function static:get_colour          () return utils.get_obj(self):GetColor()          end
function static:get_heading         () return utils.get_obj(self):GetHeading()        end
function static:get_stretch_texture () return utils.get_obj(self):GetStretchTexture() end
function static:get_text            () return utils.get_obj(self):GetText()           end
function static:get_text_align      () return utils.get_obj(self):GetTextAlign()      end
function static:get_text_x          () return utils.get_obj(self):GetTextX()          end
function static:get_text_y          () return utils.get_obj(self):GetTextY()          end

------------------------------------------------------------------------------------------------------------------
function static:set_texture (texture,x,y,w,h)
    utils.get_luaxml_tag(self,'texture')[1] = texture
    utils.get_obj(self):InitTexture(texture)
    
    if is_table(x) then
        x,y,w,h = x[1],x[2],x[3],x[4]
    end
    
    if x then
        self:set_sub_texture(x,y,w,h)
    end
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_sub_texture (x,y,w,h)
    local tex = utils.get_luaxml_tag(self, 'texture')
    
    if is_table(x) then
        x,y,w,h = x[1],x[2],x[3],x[4]
    end
    
    tex.x      = x
    tex.y      = y
    tex.width  = w
    tex.height = h
    
    utils.get_obj(self):SetOriginalRect(x,y,w,h)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_colour (a,r,g,b)
    local tex = utils.get_luaxml_tag(self,'texture')
    
    if is_table(a) then
        a,r,g,b = a[1],a[2],a[3],a[4]
    end
    
    tex.a = a
    tex.r = r
    tex.g = g
    tex.b = b
    
    utils.get_obj(self):SetColor(GetARGB(a,r,g,b))
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_stretch_texture (bool) --'stretch' устанавливается в тэг 'texture'
    utils.get_luaxml_tag(self,'texture').stretch = is_boolean(bool) and bool and 1
    utils.get_obj(self):SetStretchTexture(bool)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_stretch (bool) -- 'stretch' устанавливается в тэг статика
    utils.get_luaxml(self).stretch = bool and 1
    utils.get_obj(self):SetStretchTexture(bool)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_clipper (bool)
    utils.get_luaxml(self).clipper = bool and 1
    local obj = utils.get_obj(self)
    
    if bool then
        obj:ClipperOn()
    else
        obj:ClipperOff()
    end
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_rotate (bool) -- SetHeading
    utils.get_luaxml(self).heading = bool and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_texture_offset (x,y)
    local offset = utils.get_luaxml_tag(self,'texture_offset')
    offset.x = x
    offset.y = y
    
    utils.get_obj(self):SetTextureOffset(x,y)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:get_texture_offset ()
    local offset = utils.find_luaxml_tag(self,'texture_offset')
    if offset then
        return offset.x, offset.y
    end
    return nil
end

------------------------------------------------------------------------------------------------------------------
function static:set_texture_angle (angle)
    utils.get_luaxml(self).heading = '1'
    utils.get_style(self).angle = angle -- сохранить для установки в заданное положение угла поворота
    
    utils.reinit(self) -- <<< Refresh >>> --
    utils.get_obj(self):SetHeading(math.rad(angle))
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:get_texture_angle ()
    return utils.get_style(self).angle
end

------------------------------------------------------------------------------------------------------------------
function static:set_light(anim, cyclic, text, texture, alpha)
    local luaxml = utils.get_luaxml(self)
    
    luaxml.light_anim = luaxml.light_anim or is_string (anim)    and anim
    luaxml.la_cyclic  = luaxml.la_cyclic  or is_boolean(cyclic)  and cyclic  and 1
    luaxml.la_text    = luaxml.la_text    or is_boolean(text)    and text    and 1
    luaxml.la_texture = luaxml.la_texture or is_boolean(texture) and texture and 1
    luaxml.la_alpha   = luaxml.la_alpha   or is_boolean(alpha)   and alpha   and 1
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_light_anim (anim)
    utils.get_luaxml(self).light_anim = is_string(anim) and anim
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_light_ciclic (cyclic)
    utils.get_luaxml(self).la_cyclic = is_boolean(cyclic) and cyclic and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_light_text (text)
    utils.get_luaxml(self).la_text = is_boolean(text) and text and
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_light_texture (texture)
    utils.get_luaxml(self).la_texture = is_boolean(texture) and texture and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_light_alpha (alpha)
    utils.get_luaxml(self).light_anim = is_boolean(alpha) and alpha and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_highlight_text (enable,a,r,g,b)
    local luaxml = utils.get_luaxml(self)
    
    if is_table(a) then
        a,r,g,b = a[1],a[2],a[3],a[4]
    end
    
    luaxml.highlight_text = luaxml.highlight_text or is_boolean(enable) and enable and 1
    luaxml.hA = luaxml.hA or is_boolean(a) and a and 1
    luaxml.hR = luaxml.hR or is_boolean(r) and r and 1
    luaxml.hG = luaxml.hG or is_boolean(g) and g and 1
    luaxml.hB = luaxml.hB or is_boolean(b) and b and 1
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_highlight_text_enable (bool)
    utils.get_luaxml(self).highlight_text = is_boolean(bool) and bool and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_highlight_text_a (bool)
    utils.get_luaxml(self).hA = is_boolean(bool) and bool and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_highlight_text_r (bool)
    utils.get_luaxml(self).hR = is_boolean(bool) and bool and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_highlight_text_g (bool)
    utils.get_luaxml(self).hG = is_boolean(bool) and bool and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_highlight_text_b (bool)
    utils.get_luaxml(self).hB = is_boolean(bool) and bool and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_xform (anim, cyclic)
    local luaxml = utils.get_luaxml(self)
    luaxml.xform_anim = luaxml.xform_anim or is_string(anim) and anim
    luaxml.xform_anim_cyclic = luaxml.xform_anim_cyclic or is_boolean(cyclic) and cyclic and 1
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_xform_anim (anim)
    utils.get_luaxml(self).xform_anim = is_string(anim) and anim
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_xform_ciclic (cyclic)
    utils.get_luaxml(self).xform_anim_cyclic = is_boolean(cyclic) and cyclic and 1
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_word_wrap (bool) -- для статика
    local luaxml = utils.get_luaxml(self)
    luaxml.complex_mode = is_boolean(bool) and bool and 1
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_word_wrap (bool) -- для текста <text>
    local text = utils.get_luaxml_tag(self,'text')
    text.complex_mode = is_boolean(bool) and bool and 1
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_color (a,r,g,b)
    local text = utils.get_luaxml_tag(self,'text')
    
    if is_table(a) then
        a,r,g,b = a[1],a[2],a[3],a[4]
    end
    
    text.a = a
    text.r = r
    text.g = g
    text.b = b
    
    utils.get_obj(self):SetTextColor(a,r,g,b)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_color_ed (e,d) -- table - a,r,g,b
    local text_colour = utils.get_luaxml_tag(self,'text_color')
    local colour_e = text_colour:get('e')
    colour_e.a = e[1]
    colour_e.r = e[2]
    colour_e.g = e[3]
    colour_e.b = e[4]
    
    local colour_d = text_colour:get('d')
    colour_d.a = d[1]
    colour_d.r = d[2]
    colour_d.g = d[3]
    colour_d.b = d[4]
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_color_e (a,r,g,b) -- table - a,r,g,b
    local text_colour = utils.get_luaxml_tag(self,'text_color')
    local colour_e = text_colour:get('e')
    
    if is_table(a) then
        a,r,g,b = a[1],a[2],a[3],a[4]
    end
    
    colour_e.a = a
    colour_e.r = r
    colour_e.g = g
    colour_e.b = b
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_color_d (a,r,g,b)
    local text_colour = utils.get_luaxml_tag(self,'text_color')
    local colour_d = text_colour:get('d')
    
    if is_table(a) then
        a,r,g,b = a[1],a[2],a[3],a[4]
    end
    
    colour_d.a = a
    colour_d.r = r
    colour_d.g = g
    colour_d.b = b
    
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text (text, bool)
    bool = not is_false(bool)
    local db = utils.get_db(self)
    db.text = text
    
    if bool then
        if is_string(text) and text:match('\n') then
            self:set_word_wrap(true)
        end
        text = utils.format_text(text, self)
    end
    
    utils.get_obj(self):SetText(text)
    --self:set_bg_colour(utils.get_style().bg_colour)
    --print(utils.get_style().bg_colour)
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_font (font,a,r,g,b) -- устанавливается в тег <text> (в отличии от aui.window:set_font)
    local f = utils.get_luaxml_tag(self,'text')
    
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
local t_align = {[0]='l',[1]='r',[2]='c',l=0,r=1,c=2}

function static:set_text_align (pos)
    utils.get_luaxml_tag(self,'text').align = is_string(pos) and pos or t_align[pos]
    utils.get_obj(self):SetTextAlign(is_number(pos) and pos or t_align[pos])
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_v_align (pos)
    utils.get_luaxml_tag(self,'text').vert_align = pos
    utils.reinit(self)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_st (text)
    utils.get_luaxml_tag(self,'text')[1] = text
    utils.get_obj(self):SetTextST(text)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_x (x)
    utils.get_luaxml_tag(self,'text').x = x
    utils.get_obj(self):SetTextX(x)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function static:set_text_y (y)
    utils.get_luaxml_tag(self,'text').y = y
    utils.get_obj(self):SetTextY(y)
    
    return self
end
------------------------------------------------------------------------------------------------------------------
--[[function static:set_text_font (name)
    utils.get_luaxml_tag(self,'text').font = name
    utils.reinit(self)
    
    return self
end]]

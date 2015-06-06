--[[--------------------------------------------------
FileName: button.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

local utils = aui.utils

--################################################################################################################
--################################################################################################################
class 'button' (aui.static)

button.DEFAULT_TEXTURE = 'ui\\ui_btn_01_e'
button.DEFAULT_RECT_X = 0
button.DEFAULT_RECT_Y = 0
button.DEFAULT_RECT_WIDTH  = 120
button.DEFAULT_RECT_HEIGHT = 30
button.AUTO_SIZE     = true -- разрешается автоматическое назначение размера self.DEFAULT_RECT_X(Y,W,H) при отсутствии размеров при создании
button.AUTO_REGISTER = true
button.AUTO_TEXTURE  = true

------------------------------------------------------------------------------------------------------------------
function button:__init(...)
    self.class = 'button'
    self.func = 'InitButton'
    
    local parent, id, rect, source, num = utils.normalize_args{...}
    
    if self.AUTO_SIZE then
        rect = rect or  {   self.DEFAULT_RECT_X,
                            self.DEFAULT_RECT_Y,
                            self.DEFAULT_RECT_WIDTH,
                            self.DEFAULT_RECT_HEIGHT,
                        }
    end
    
    local db = utils.set_db(self, parent, id, rect, source, num)
    local xml = db.luaxml
    
    xml.stretch = aui.static.IS_STRETH  and 1 -- изначально текстуры будут растягиваться
    xml.clipper = aui.static.IS_CLIPPER and 1 -- изначально текстуры будут обрезаться
    
    utils.init(self)
    
    if self.AUTO_REGISTER then
        utils.get_super(self):register(self)
    end
    
    if self.AUTO_TEXTURE then
        self:set_texture(self.DEFAULT_TEXTURE)
    end
end

------------------------------------------------------------------------------------------------------------------
function button:__finalize() end

------------------------------------------------------------------------------------------------------------------
function button:enable_text_highlighting (boolean)
    utils.get_obj(self):EnableTextHighlighting(boolean)
    return self
end

------------------------------------------------------------------------------------------------------------------
function button:set_highlight_colour (number)
    utils.get_obj(self):SetHighlightColor(number)
    return self
end

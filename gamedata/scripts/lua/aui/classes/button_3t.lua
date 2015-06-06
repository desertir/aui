--[[--------------------------------------------------
FileName: button_3t.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

local utils = aui.utils

--################################################################################################################
class 'button_3t' (aui.button)

button_3t.DEFAULT_TEXTURE = 'ui\\ui_btn_01'

------------------------------------------------------------------------------------------------------------------
function button_3t:__init(...)
    self.class = 'button_3t'
    self.func = 'Init3tButton'
    
    local parent, id, rect, source, num = utils.normalize_args{...}
    
    if self.AUTO_SIZE then
        rect = rect or  {   self.DEFAULT_RECT_X,
                            self.DEFAULT_RECT_Y,
                            self.DEFAULT_RECT_WIDTH,
                            self.DEFAULT_RECT_HEIGHT,
                        }
    end
    
    utils.set_db(self, parent, id, rect, source, num)
    utils.init(self)
    
    if self.AUTO_REGISTER then
        utils.get_super(self):register(self)
    end
    
    if self.AUTO_TEXTURE then
        self:set_texture(self.DEFAULT_TEXTURE)
    end
end

------------------------------------------------------------------------------------------------------------------
function button_3t:__finalize() end

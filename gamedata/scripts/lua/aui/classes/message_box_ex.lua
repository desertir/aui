--[[--------------------------------------------------
FileName: message_box_ex.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

local utils = aui.utils

--################################################################################################################

--[[class 'message_box_ex' (aui.dialog)
function message_box_ex:__init(...)
    
end
function message_box_ex:__finalize() end

function message_box_ex:get_host    ()    self:utils.get_db().obj:GetHost    ()    end
function message_box_ex:get_password()    self:utils.get_db().obj:GetPassword()    end
function message_box_ex:_Init       (str) self:utils.get_db().obj:Init       (str) end -- !!! Может сбить подобные? !!!
function message_box_ex:set_text    (str) self:utils.get_db().obj:SetText    (str) end -- !!! Может сбить подобные? !!!]]
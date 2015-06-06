--[[--------------------------------------------------
FileName: global.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------
local utils = aui.utils

function CDialogHolder:show_menu(wnd, bool)
    --[[if is_string(wnd) then
        local data = aui.MENU_IDS[wnd]
        if not data then return end
        wnd = utils.create_cui_wnd(data)
    end]]
    wnd = wnd[aui.ID_DB] and wnd[aui.ID_DB].obj or wnd
    self:start_stop_menu(wnd, bool or true)
end
------------------------------------------------------------------------------------------------------------------
level.show_menu = function (wnd, bool)
    --[[if is_string(wnd) then
        local data = aui.MENU_IDS[wnd]
        if not data then return end
        wnd = utils.create_cui_wnd(data)
    end]]
    wnd = wnd[aui.ID_DB] and wnd[aui.ID_DB].obj or wnd
    level.start_stop_menu(wnd, bool or true)
end

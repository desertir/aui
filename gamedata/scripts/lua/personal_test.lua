debug.reboot('aui')

local _ = aui.utils -- для теста функций ядра пусть пока будет

--################################################################################################################
-- TEST
--################################################################################################################

class "aui_test" (aui.script_wnd)

function aui_test:__init() super()
    self:InitControls()
end

function aui_test:__finalize() end

function aui_test:InitControls() 
    self:set_bg_colour(100,255,255,0)
        :set_padding(50,50,50,50)
        --:set_wide_scale()
        --:set_padding_right(10)
    padding = _.get_db(self).pad
    padding:set_bg_colour(100,0,255,0)
end

function aui_test:on_quit(v)
    if _G.MAIN_MENU_WND then
        self:get_holder():show_menu(self,true)
    else
        level.show_menu(self, true)
    end
end

function aui_test:OnKeyboard(dik, keyboard_action) --CUIScriptWnd.OnKeyboard(self.db.obj,dik,keyboard_action)
    if keyboard_action == ui_events.WINDOW_KEY_PRESSED then
        if dik == DIK_keys.DIK_T then
            self:on_quit()
        end
    end
    return true
end

--################################################################################################################
-- RUN
--################################################################################################################
-- когда будем тестировать с апдейтами, то нужно будет выходить из меню в игру.
-- значение 'false' - тестируем без апдейта (можно и без загрузки сейва) в главном меню
-- значение 'true' - главное меню закрывается, выходим в игру и окно отображается там.
local INTO_GAME = false

function start()
    local spawn = aui_test()
    if INTO_GAME and db.actor then
        get_console():execute("main_menu off")
        level.show_menu(spawn, true)
    else
        _G.MAIN_MENU_WND:GetHolder():show_menu(spawn, true)
    end
end

start()





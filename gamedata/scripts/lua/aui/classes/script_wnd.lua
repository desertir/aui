--[[--------------------------------------------------
FileName: script_wnd.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

local utils = aui.utils

------------------------------------------------------------------------------------------------------------------
class 'script_wnd' (aui.dialog) -- CUIScriptWnd

------------------------------------------------------------------------------------------------------------------
-- в отличии от других окон, тут фон накладывается!!! на окно script_wnd.
function script_wnd:__init(...)
    self.class = 'script_wnd'
    
    aui.MENU_ID_ACTIVE = nil -- подготовить для следующего окна
    
    local db = utils.set_db(self, utils.normalize_args{...})
    
    db.style.wide = 1 -- изначально на широкоэкранниках сжиматься не будет
    db.obj = utils._cui_script_wnd(self)
    
    local rect = utils.get_xml_rect(self)
    db.obj:Init(unpack(rect))
    
    db.bg = aui.static(self, aui.ID_BG, rect)
                :set_texture(aui.BG_DEFAULT_TEXTURE, rect)
                :set_colour(0,255,255,255)
    
    db.pad = aui.static(db.bg, aui.ID_PAD, rect)
            --[[:set_texture(aui.BG_DEFAULT_TEXTURE, rect)
            :set_colour(0,255,255,255)]]
    
    aui.MENU_ID_ACTIVE = utils.get_id(self)
    aui.MENU_IDS[aui.MENU_ID_ACTIVE] = self -- сохранить ссылку на объект 'script_wnd' по его ID
end

------------------------------------------------------------------------------------------------------------------
function script_wnd:__finalize() end

------------------------------------------------------------------------------------------------------------------
function script_wnd:AddCallback(...)
    utils.get_obj(self):AddCallback(...)
    return self
end

------------------------------------------------------------------------------------------------------------------
function script_wnd:register(wnd,str)
    utils.get_obj(self):Register(utils.get_obj(wnd),str or wnd:get_id())
    return self
end

------------------------------------------------------------------------------------------------------------------
function script_wnd:set_wide_scale(scale) -- проценты : 100 - сжимается максимально, 0 - не сжимается
    local scale = is_number(scale) and scale or 100
    
    utils.get_style(self).wide = 1 + (scale*(aui.WIDE_RATIO - 1)/100)
    utils.set_rect(self) -- нужно ли само окно обработки сжимать? наверное нет.
    utils.all_childs_down(self, utils.refresh)
    
    return self
end

------------------------------------------------------------------------------------------------------------------
function script_wnd:get_wide_scale()
    return utils.get_style(self).wide or 1
end

------------------------------------------------------------------------------------------------------------------
function script_wnd:get_button        (str) return utils.get_obj(self):GetButton       (str) end
function script_wnd:get_check_button  (str) return utils.get_obj(self):GetCheckButton  (str) end
function script_wnd:get_dialog_wnd    (str) return utils.get_obj(self):GetDialogWnd    (str) end
function script_wnd:get_edit_box      (str) return utils.get_obj(self):GetEditBox      (str) end
function script_wnd:get_frame_line_wnd(str) return utils.get_obj(self):GetFrameLineWnd (str) end
function script_wnd:get_frame_window  (str) return utils.get_obj(self):GetFrameWindow  (str) end
function script_wnd:get_list_wnd      (str) return utils.get_obj(self):GetListWnd      (str) end
function script_wnd:get_list_wnd_ex   (str) return utils.get_obj(self):GetListWndEx    (str) end
function script_wnd:get_message_box   (str) return utils.get_obj(self):GetMessageBox   (str) end
function script_wnd:get_progress_bar  (str) return utils.get_obj(self):GetProgressBar  (str) end
function script_wnd:get_properties_box(str) return utils.get_obj(self):GetPropertiesBox(str) end
function script_wnd:get_radio_button  (str) return utils.get_obj(self):GetRadioButton  (str) end
function script_wnd:get_static        (str) return utils.get_obj(self):GetStatic       (str) end
function script_wnd:get_tab_control   (str) return utils.get_obj(self):GetTabControl   (str) end
function script_wnd:load              (str) return utils.get_obj(self):Load            (str) end

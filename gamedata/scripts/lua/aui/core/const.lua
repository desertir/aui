--[[--------------------------------------------------
FileName: const.lua
Author  : 
Version : 1.0
------------------------------------------------------
Description:
--]]--------------------------------------------------

UPDATE = true -- 

-- BG --
BG_DEFAULT_TEXTURE = 'ui\\aui_background'
BG_DEFAULT_COLOR   = {0,255,255,255}

-- IDS ------
ID_DB = '_unique_data_base_id_'  -- ключ для базы данных
ID_BG = '_unique_background_id_' -- ID для определения статика как фона
ID_PAD = '_unique_padding_id_'   -- ID определения статика окна паддинга

-- тут храняться ссылки на все создаваемые объекты 'script_wnd', которые можно открыть с предыдущими настройками
MENU_IDS = {}
MENU_ID_ACTIVE = nil -- ('string') ID

-- rect and w/h ratio --
DEVICE_WIDTH  = device().width
DEVICE_HEIGHT = device().height
DEVICE_RATIO  = DEVICE_WIDTH/DEVICE_HEIGHT

BAZE_X = 0
BAZE_Y = 0
BAZE_WIDTH  = 1024
BAZE_HEIGHT = 768
BAZE_RATIO  = BAZE_WIDTH / BAZE_HEIGHT

WIDTH_RATIO  = DEVICE_WIDTH / BAZE_WIDTH
HEIGHT_RATIO = DEVICE_HEIGHT / BAZE_HEIGHT
WIDE_RATIO   = WIDTH_RATIO / HEIGHT_RATIO

-- XML -------------
XML_TAG_PREFIX = '_unique_tag_' -- префикс для автоматического создания имен тегов окон
XML_TAG_COUNTER = 0             -- 
XML_ROOT   = '$game_config$'
XML_FOLDER = 'ui'
XML_NAME   = 'aui'
XML_PATH   = getFS():update_path(XML_ROOT, XML_FOLDER.."\\")..XML_NAME..'.xml'




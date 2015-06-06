local _match    = string.match
local _find     = string.find
local _sub      = string.sub
local _gsub     = string.gsub
local _lower    = string.lower
local _upper    = string.upper
local _concat   = table.concat

LUA_EX_PRINT_DIR  = "$logs$"
LUA_EX_PRINT_FILE = 'LuaEx_log.txt'
LUA_EX_PRINT_MODE = 'a'
LUA_EX_PRINT_SEP  = ' = '
LUA_EX_PRINT_PATH = getFS():update_path(LUA_EX_PRINT_DIR, LUA_EX_PRINT_FILE)

--===================== Проверки =====================================================
function is_table   (val) return type(val) == 'table'    end
function is_boolean (val) return type(val) == 'boolean'  end
function is_number  (val) return type(val) == 'number'   end
function is_function(val) return type(val) == 'function' end
function is_string  (val) return type(val) == 'string'   end
function is_userdata(val) return type(val) == 'userdata' end
function is_thread  (val) return type(val) == 'thread'   end
function is_nil     (val) return       val == nil        end
function is_true    (val) return       val == true       end
function is_false   (val) return       val == false      end
function is_int     (val) return is_number(val) and math.modf(val) == val end
function is_float   (val) return    not is_int(val)   end
function is_nan     (val) return is_number(val) and val ~= val     end
function is_positive(val) return is_number(val) and val > 0        end
function is_negative(val) return not is_positive(val) and val ~= 0 end
function to_boolean (val) return       not not val                end

function is_array(val)
    if not is_table(val) then return false end
    return table.size(val) == #val
end

function is_empty(obj, space)
    if is_string(obj) then
        if space then return not obj:match('[^%s\160]+') end
        return #obj == 0
    end
    if is_table(obj) then return next(obj) == nil end
    return false
end

--===========================================================================================

function print(...)
    local count = select('#',...)
    local arg  = {...}
    for i = 1, count do
        if not ( is_number(arg[i]) or is_string(arg[i]) or is_boolean(arg[i]) ) then arg[i] = type(arg[i]) end
        arg[i] = tostring(arg[i])
    end
    local f = io.open(LUA_EX_PRINT_PATH, LUA_EX_PRINT_MODE)
    f:write(table.concat(arg, LUA_EX_PRINT_SEP)..'\n')
    f:flush()
    f:close()
end

--===========================================================================================
local function call_timer(tab, name)
    local timer = {timer = profile_timer(), name = name or ''}
    
    function timer:start()
        self.timer:start()
        return self -- не нужно было бы тратить уже отсчитывающееся время на лишние действия
    end
    
    function timer:stop(msg)
        self.timer:stop()
        self:print(msg)
        return self
    end
    
    function timer:point(name)
        self:stop("POINT '"..(name or '').."'"):start()
    end
    
    function timer:print(msg)
        print("TIMER '"..self.name.."' > "..(msg or 'STOP')..' >  TIME = '..self.timer:time())
    end
    
    return timer
end

debug.timer = setmetatable({}, {__call = call_timer})

--===========================================================================================

function debug.reboot(script_name)
    if package.loaded[script_name] then   -- для файлов *.lua
        package.loaded[script_name] = nil
        require (script_name)
    else
        _G[script_name] = nil             -- для файлов *.script
         if _G[script_name] then end
    end
end

--#######################################   T A B L E   ########################################################
function table.copy(src, mode)
    if not is_table(src) then return end
    
    local function tcopy(src, mode)
        if type(src)~='table' then return src end
        local new = {}
        if mode == 2 then
            for k, v in pairs(src) do
                new[tcopy(k, mode)] = tcopy(v, mode)
            end
            setmetatable(new, tcopy(getmetatable(src), mode))
        else
            for k, v in pairs(src) do new[k] = tcopy(v, mode) end
            if mode == 1 then
                setmetatable(new, getmetatable(src))
            end
        end
        return new
    end
    return tcopy(src, mode)
end

--=========================================================
function table.tree(t, indent, mode)
    if not is_table(t) then return end
    
    if type(indent)=='boolean' then indent, mode =  mode, indent end
    indent = is_string(indent) and indent or is_number(indent) and (' '):rep(indent) or '  '
    indent = indent or '    '

    local mem = setmetatable({t=( t==_G and '_G' or 'main'), [_G]='_G' },{__mode='k'})
        
    local function f(index, tab, s, p)
        local space = s..indent
        local w = {}
        if type(tab) == 'table' then
            w[#w+1]='\n'..s..'{\n'
            for k,v in pairs(tab) do
                local key = k
                local x = type(k)
                local isObject = (x == 'userdata' or x == 'function' or x == 'thread')
                local isLogic  = (x == 'boolean'  or x == 'nil')
                    
                if     x == 'number'   then k = not mode and k or '['..k..']'
                elseif x == 'string'   then k = (_find(k,'\n') and '[['..k:gsub('\n','\n'..space)..']]') or (not mode and k) or '["'..k..'"]'
                elseif isObject then k = '*'..x
                elseif isLogic  then k = tostring(k)
                end
                    
                if not mem[v] then
                    local o = p
                    if type(v) == 'table' then
                        o = p..(is_string(key) and '.'..key or is_number(key) and '['..key..']') -- !!!!!!!!!!!!!!!!
                        mem[v] = o
                    end
                    w[#w+1] = space .. k .. ' = ' .. f(not mode and k or key, v, space..indent, o) ..',\n'
                else
                    w[#w+1] = space .. k .. ' = <' .. mem[v] ..'>,\n'
                end
                    
            end
            w[#w+1]=s..'}'
        else
            local x = type(tab)
            if     x == 'string'   then tab = _find(tab,'\n') and '[['..tab..']]' or '"'..tab..'"'
            elseif x == 'boolean'  then tab = tostring(tab)
            elseif x == 'userdata' or  x == 'function' or x == 'thread' then
                if not mem[tab] then
                    mem[tab] = p..'.'..index
                    tab = '*'..x
                else
                    tab = '<'..mem[tab]..'>'
                end
            elseif x == 'number'   then tab = tab
            else tab = '-nil-'
            end
            return tab
        end
        return _concat(w)
    end
        
    local s = f(nil, t, '', mem.t):gsub('^\n','')
    return s
end
--------------------------------------------------------------------------------------
function table.print(t, indent, mode)
    print(table.tree(t, indent, mode))
end
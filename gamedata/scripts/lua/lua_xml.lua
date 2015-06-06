require("LuaXML_lib")
local print=print
local xml    = xml
local io     = io
local select = select
local pairs  = pairs
local ipairs = ipairs
local type   = type
local tostring     = tostring
local coroutine    = coroutine
local setmetatable = setmetatable

module("xml")

-- symbolic name for tag index, this allows accessing the tag by var[xml.TAG]
TAG = 0

-- sets or returns tag of a LuaXML object
function tag(var,tag)
    if type(var) ~= "table" then return end
    if not tag then 
        return var[TAG]
    end
    var[TAG] = tag
end

-- creates a new LuaXML object either by setting the metatable of an existing Lua table or by setting its tag
function new(arg)
    if type(arg) == "table" then 
        return setmetatable(arg, {__index = xml, __tostring = xml.str})
    end
    local var = setmetatable({}, {__index = xml, __tostring = xml.str})
    if type(arg) == "string" then var[TAG] = arg end
    return var
end

-- appends a new subordinate LuaXML object to an existing one, optionally sets tag
function append(var,tag)
    if type(var) ~= "table" then return end
    local newVar = new(tag)
    var[#var+1] = newVar
    return newVar
end

-- converts any Lua var into an XML string
function str(var,indent,tagValue)
    if not var then return end
    local indent = indent or 0
    local indentStr = ""
    for i = 1,indent do indentStr = indentStr.."  " end
    local tableStr = ""
    
    if type(var)=="table" then
        local tag = var[0] or tagValue or type(var)
        local s = indentStr.."<"..tag
        for k,v in pairs(var) do -- attributes 
            if type(k)=="string" then
                if type(v)=="table" and k~="_M" then --  otherwise recursiveness imminent
                    tableStr = tableStr..str(v,indent+1,k)
                else
                    s = s.." "..k.."=\""..encode(tostring(v)).."\""
                end
            end
        end
        if #var==0 and #tableStr==0 then
            s = s.." />\n"
        elseif #var==1 and type(var[1])~="table" and #tableStr==0 then -- single element
            s = s..">"..encode(tostring(var[1])).."</"..tag..">\n"
        else
            s = s..">\n"
            for k,v in ipairs(var) do -- elements
                if type(v)=="string" then
                    s = s..indentStr.."  "..encode(v).." \n"
                else
                    s = s..str(v,indent+1)
                end
            end
            s=s..tableStr..indentStr.."</"..tag..">\n"
        end
        return s
    else
        local tag = type(var)
        return indentStr.."<"..tag.."> "..encode(tostring(var)).." </"..tag..">\n"
    end
end


-- saves a Lua var as xml file
function save(var,filename)
    if not var then return end
    if not filename or #filename==0 then return end
    local file = io.open(filename,"w")
    -- Fix by Gun12 -------------------------
    --file:write("<?xml version=\"1.0\"?>\n<!-- file \"",filename, "\", generated by LuaXML -->\n\n")
    file:write("<?xml version=\"1.0\" encoding=\"windows-1251\"?>\n\n")
    -- END Fix by Gun12 ----------------------
    file:write(str(var))
    io.close(file)
end

-- Fix by Gun12 -------------------------
-- Function 'get' -------------------------
function get(obj, tag) -- ������������ ��������� ���, � ��� ��� ���������� �������� ����� � ������������
    return obj:find(tag) or obj:append(tag)
end

-- Function 'remove' ----------------------
function remove(obj, tag)
    if type(obj)~="table" then return end
    if type(tag)=="string" and #tag==0 then tag=nil end
    local _,index = obj:find(tag)
    if not index then return end
    return table.remove(obj,index)
end
-- Function 'find' ----------------------
local function checkValue(obj,value)
    for k in pairs(obj) do
        if obj[k]==value then return true end
    end
end

local function checkKey(obj,key,value)
    if value then
        if obj[key]==value then return true end
    elseif obj[key] then
        return true
    end
end

local function checkTag(obj,tag,key,value)
    if obj[0]==tag then
        if key then
            if checkKey(obj,key,value) then return true end
        elseif value then
            if checkValue(obj,value) then return true end
        else
            return true
        end
    end
end

local function setmt(obj)
    return setmetatable(obj,{__index=xml, __tostring=xml.str})
end

local function checkXml(obj,tag,key,value)
    if tag then
        if checkTag(obj,tag,key,value) then return setmt(obj) end
    elseif key then
        if checkKey(obj,key,value) then return setmt(obj) end
    elseif value then
        if checkValue(obj,value) then return setmt(obj) end
    else
        return setmt(obj)
    end
end

local function check(obj,tag,key,value)
    if type(obj)~="table" then return end
    
    for k,v in ipairs(obj) do
        if type(v)=="table" then -- �� ������������ ��������, �.�. ��� ��������� ��������� �������� ������� �������� LuaXML
            if checkXml(v,tag,key,value) then coroutine.yield(v,k) end
        end
    end
end

local thread = nil

function find(obj,tag,key,value)
    thread = coroutine.create(check)
    return select(2,coroutine.resume(thread,obj,tag,key,value))
end
-- Function 'next' ----------------------
function next()
    if coroutine.status(thread)=='dead' then return end
    return select(2,coroutine.resume(thread))
end
-- END Fix by Gun12 ----------------------
--- Cemi UI [Name] Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

--- Description
---@class temp : Widget
local temp = setmetatable({}, Widget)

---@class temp_Template : Widget_Template

---@param template? temp_Template
---@return temp
function temp:new(template)
    
    local t = setmetatable(Widget:new(template), temp) ---@cast t temp
    self.__index = self
    
    if template == nil then
        return t
    end
    
    for key, value in pairs(template) do
        if value ~= nil then
            t[key] = value
        end
    end
    
    return t
end

function temp:__tostring()
    return string.format("<temp: %i>", self.id) ---@diagnostic disable-line
end

return temp
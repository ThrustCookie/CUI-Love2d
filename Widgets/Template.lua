--- Cemi UI [Name] Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget


--- Description
---@class Type : Widget
    
local Type = setmetatable({}, Widget)



---@class Type_Template : Widget_Template

---@param template? Type_Template
---@return Text
function Type:new(template)
    
    local t = setmetatable(Widget:new(template), Type) ---@cast t Text
    self.__index = self
    
    t.color = {1, 1, 1}
    t.size.height.mode = 'Fixed'
    t.size.width.mode = 'Fixed'
    
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

function Type:__tostring()
    return string.format("<Text: %i>", self.id)
end

return Type
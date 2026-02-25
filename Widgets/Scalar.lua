--- Cemi UI [Name] Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget


--- Description
---@class Scalar : Widget
---@field Scalar {x:number, y:number}
local Scalar = setmetatable({}, Widget)
Scalar.scale = {x = 1, y = 1}


---@class Scalar_Template : Widget_Template
---@field scale?
---| number
---| {[1]: number,[2]:number}
---| {x: number,y:number}

---@param template? Scalar_Template
---@return Scalar
function Scalar:new(template)

    local t = setmetatable(Widget:new(template), Scalar) ---@cast t Scalar
    self.__index = self

    t.scale = {x = 1, y = 1}

    if template == nil then
        return t
    end

    local s = template.scale
    if s ~= nil then
        
        if type(s) == 'number' then
            t.scale.x = s
            t.scale.y = s
        elseif s.x  and s.y then
            t.scale.x = s.x
            t.scale.y = s.y
        elseif
            #s == 2 
            and type(s[1]) == 'number'
            and type(s[2]) == 'number'
        then
            t.scale.x = s[1]
            t.scale.y = s[2]
        else
            error("Scale set incorrectly for widget "..tostring(self))
        end
        template.scale = nil
    end
    
    for key, value in pairs(template) do
        if value ~= nil then
            t[key] = value
        end
    end
    
    return t
end

function Scalar:__tostring()
    return string.format("<Scalar: %i>", self.id)
end

--- ad a sizing or set size func here

return Scalar
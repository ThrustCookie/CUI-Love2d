--- Cemi UI Box Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

--- definitions ---

--- Box Widget is a colored rectangle
---@class Box : Widget
    ---@field fill_mode 'fill' | 'line'
    ---@field color {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field rounding {x:number, y:number}
local Box = setmetatable({}, Widget)
local default_size = 100

---@class Box_Template : Widget_Template
    ---@field fill_mode?
        ---|'fill'
        ---|'line'
    ---@field rounding?
        ---| number
        ---| {x:number,y:number}
        ---| {[1]:number,[2]:number}
    ---@field color? {[1]:number,[2]:number,[3]:number,[4]:number?}

---@param template? Box_Template
---@return Box
function Box:new(template)
    template = template or {size = default_size}
    template.size = template.size or default_size
    
    local t = setmetatable(Widget:new(template), Box) ---@cast t Box
    self.__index = Box

    --- default values
    t.fill_mode = 'fill'
    t.rounding = {x = 0, y = 0}
    t.color = {1, 1, 1, 1}
    
    if template.fill_mode then
        t.fill_mode = template.fill_mode
    end
    if template.rounding then
        ---@diagnostic disable
        if type(template.rounding) == 'number' then
            t.rounding.x = template.rounding
            t.rounding.y = template.rounding
        elseif 
            template.rounding.x ~= nil
            and template.rounding.y ~= nil
        then
            t.rounding = template.rounding
        elseif #template.rounding == 2 then
            assert(
                type(template[1]) == 'number'
                and type(template[2]) == 'number',
                "Rounding set incorrectly for: "..tostring(t)
            )
        else
            error("Rounding set incorrectly for "..tostring(t))
        end
        ---@diagnostic enable
    end
    if template.color then
        t.color = template.color
    end
    
    return t
end

---@param template Box_Template
---@return Box
function Box:__call(template)
    return self:new(template)
end

function Box:__tostring()
    return string.format("<Box: %i>", self.id)
end

function Box:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
        self.fill_mode,
        self.global_position.x,
        self.global_position.y,
        self.size.width.value, 
        self.size.height.value,
        self.rounding.x,
        self.rounding.y
    )
end

Box.fit = Widget.fit
Box.place_children = Widget.place_children

return Box
--- Cemi UI Box Widget ---

---@alias color {[1]:number,[2]:number,[3]:number,[4]:number?}

--- Box Widget is a colored rectangle
---@class Box : Widget
---@field protected __color color
---@field protected __rounding {x:number, y:number}
---@field mode 'fill' | 'line'
---@field color number | color | widget_field
---@field rounding vector | widget_field
local box = require[[Widgets.Widget]]:extend()

---------------
--- Format Functions
---------------

function box.format.color(value)
    if type(value) == 'number' then
        return {value, value, value}
    end

    return value
end

box.format.rounding = box.format.vector

---@class Box_Template : Widget_Template
---@field mode? 'fill' | 'line'
---@field color? number | color | widget_field
---@field rounding? vector | widget_field

---@param t? Box_Template
---@return Box
function box.new(t)
    t = t or {}
    t.name = t.name or "Box"

    local b = box:child_new(t)

    b.__rounding    = box.format.rounding(0)
    b.__color       = box.format.color(.75)

    --- default values
    b.mode        = t.mode      or 'fill'
    b.rounding    = t.rounding  or 0
    b.color       = t.color     or 1

    return b
end

function box:visual()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
        'fill',
        self.__global_position.x,
        self.__global_position.y,
        self.size.width.value,
        self.size.height.value,
        self.rounding.x,
        self.rounding.y
    )
end

return box
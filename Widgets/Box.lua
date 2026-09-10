--- Cemi UI Box Widget ---

--- Box Widget is a colored rectangle
---@class Box : Widget
---@field private __fill_mode 'fill' | 'line'
---@field private __color {[1]:number,[2]:number,[3]:number,[4]:number?}
---@field private __rounding {x:number, y:number}
---@field mode
---| 'fill'
---| 'line'
---| widget_field
---@field color
---| number
---| {[1]:number,[2]:number,[3]:number,[4]:number?}
---| widget_field
---@field rounding
---| number
---| {[1]:number,[2]:number}
---| {x:number, y:number}
---| widget_field
local box = require ("Widgets.Widget"):extend()

---------------
--- Format Functions
---------------

function box.format.color(value)
    if type(value) == 'number' then
        return {value, value, value}
    end

    return value
end

function box.format.rounding(value)
    if type(value) == 'number' then
        return {x = value, y = value}
    end
    
    if not type(value) == 'table' then error("Rounding set Incorrectly") end

    if value[1] and value[2] then
        return {x = value[1], y = value[2]}
    end

    return value
end

---@class Box_Template : Widget_Template
---@field mode?
---| 'fill'
---| 'line'
---| widget_field
---@field rounding?
---| number
---| {x:number,y:number}
---| {[1]:number,[2]:number}
---| widget_field
---@field color?
---| number
---| {[1]:number,[2]:number,[3]:number,[4]:number?}
---| widget_field

---@param t? Box_Template
---@return Box
function box.new(t)
    t = t or {}
    t.name = t.name or "Box"

    local new_box = box:child_new(t)

    new_box.__fill_mode   = 'fill'
    new_box.__rounding    = box.format.rounding(0)
    new_box.__color       = {.5, .5, .5}

    --- default values
    new_box.mode        = t.mode or 'fill'
    new_box.rounding    = t.rounding or 0
    new_box.color       = t.color or 1

    return new_box
end

function box:visual()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
        'fill',
        self.__global_position.x,
        self.__global_position.y,
        self.size.width.value,
        self.size.height.value
    )
end

return box
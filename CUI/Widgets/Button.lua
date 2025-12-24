--- Cemi UI Button Widget ---

local Widget = require "Cemi_UI.Widgets.Widget"

local id = 1

-- Button Widget is a clickable* rectangle
---@class Button : Widget
---@field color tablelib
---@field hovered_color tablelib
---@field pressed_color tablelib
---@field rounding {x:number,y:number}
---@field hovered boolean
---@field OnHovered function
---@field OnUnhovered function
---@field pressed boolean
---@field OnPressed function
---@field OnReleased function
local Button = Widget:new("Button", false)

Button.color = {1, 1, 1, 1}
Button.basic_color = {1, 1, 1, 1}
Button.hovered_color = {0.75, 0.75, 0.75, 1}
Button.pressed_color = {0.5, 0.5, 0.5, 1}
Button.rounding = {x=5,y=5}

Button.mouse_button_index = 1

Button.bHovered = false
Button.OnHovered = function(self) end
Button.OnUnhovered = function (self) end

Button.bPressed = false
Button.OnPressed = function (self) end
Button.OnReleased = function (self) end

---@param x number
---@param y number
---@return boolean
function Button:Hovered(x,y)
    return 
        x > self.__internal_position.x
    and y > self.__internal_position.y 
    and x < self.__internal_position.x + self.size.width.value
    and y < self.__internal_position.y + self.size.height.value
end

function Button:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
        "fill",
        self.__internal_position.x,
        self.__internal_position.y,
        self.size.width.value, 
        self.size.height.value,
        self.rounding.x,
        self.rounding.y
    )
end

--- overrides ---

---@param name string | nil
function Button:new(name)
    local t = Widget:new("Button", false)
    setmetatable(t, self)
    self.__index = self

    t.name = name or t.name
    t.id = id ---@diagnostic disable-line
    id = id + 1

    return t
end

function Button:__tostring()
    return "<".. self.name ..": ".. self.id ..">" ---@diagnostic disable-line
end

return Button
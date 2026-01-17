--- Cemi UI Button Widget ---

local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

-- Button Widget is a clickable* rectangle
---@class Button : Widget
    ---@field color {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field basic_color {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field hovered_color {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field pressed_color {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field rounding {x:number,y:number}
    ---@field hovered boolean
    ---@field OnHovered function
    ---@field OnUnhovered function
    ---@field pressed boolean
    ---@field OnPressed function
    ---@field OnReleased function
local Button = setmetatable({}, Widget)

---@class Template_Button : Widget_Template
    ---@field color? {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field hovered_color? {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field pressed_color? {[1]:number,[2]:number,[3]:number,[4]:number?}
    ---@field rounding?
        ---| number
        ---| {[1]:number,[2]:number}
        ---| {x:number,y:number}
    ---@field OnHovered? function
    ---@field OnUnhovered? function
    ---@field OnPressed? function
    ---@field OnReleased? function

---@param template? Template_Button
---@return Button
function Button:new(template)
    local t = setmetatable(Widget:new(template), Button)---@cast t Button
    self.__index = Button

    t.color = {1, 1, 1}
    t.basic_color = t.color
    t.hovered_color = {0.75, 0.75, 0.75}
    t.pressed_color = {0.5, 0.5, 0.5}
    t.rounding = {x=5,y=5}
    

    if template == nil then
        return t
    end

    for key, value in pairs(template) do
        if value == nil then
            -- dont do anything
            
        elseif key == [[rounding]] then
            if type(value) == 'number' then
                t.rounding.x = value
                t.rounding.y = value

            elseif value.x ~= nil and value.y ~= nil then
                t.rounding = value

            elseif #value == 2 then
                t.rounding.x = value[1]
                t.rounding.y = value[2]
            end
        else
            t[key] = value
            if key == [[color]] then
                t.basic_color = value
            end
        end
    end

    return t
end

function Button:__tostring()
    return string.format("<Button: %i>", self.id)
end

--- Button Logic & Overrides ---

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
        x > self.global_position.x
    and y > self.global_position.y
    and x < self.global_position.x + self.size.width.value
    and y < self.global_position.y + self.size.height.value
end

function Button:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
        'fill',
        self.global_position.x,
        self.global_position.y,
        self.size.width.value, 
        self.size.height.value,
        self.rounding.x,
        self.rounding.y
    )
end

return Button
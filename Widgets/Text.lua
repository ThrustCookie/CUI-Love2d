-- Cemi UI Text widget --

---@class Text : Widget
---@field protected __content string | widget_field
---@field protected __internal_text_lines string[]
---@field protected __wrap_limit number
---@field protected __color {[1]:number,[2]:number,[2]:number,[4]?:number}
---@field content string | widget_field
---@field wrap_limit number | widget_field
---@field font table
---@field color number | {[1]:number,[2]:number,[2]:number,[4]?:number} | widget_field
local text = require [[Widgets.Widget]]:extend()

---------------
--- Format Functions
---------------

function text.format.color(value)
    if type(value) == 'number' then
        return {value, value, value}
    end

    return value
end

---@class Text_Template : Widget_Template
---@field content? string | widget_field
---@field wrap_limit? number | widget_field
---@field font? table
---@field color? number | {[1]:number,[2]:number,[2]:number,[4]?:number} | widget_field

local default_font = love.graphics.newFont(12)


---@param t? Text_Template
---@return Text
function text.new(t)
    t = t or {}
    t.name = t.name or "Text"

    local a = text:child_new(t)

    a.__content     = "Default Text"
    a.__wrap_limit  = 500
    a.__color       = .85

    a.font          = t.font        or default_font
    a.content       = t.content     or "Default Text"
    a.wrap_limit    = t.wrap_limit  or 500
    a.color         = t.color       or .85


    return a
end

function text:child_new(t)
    return setmetatable(
        self.super.new(t), ---@diagnostic disable-line
        {
            __index = function (new_self, key)
                
                if self[key] then return self[key] end

                return self.super.__index(new_self, key)
            end,
            __newindex = function (new_self, key, value)
                self.__newindex(new_self, key, value)

                if key == 'content'
                or key == 'wrap_limit'
                or key == 'font'
                then
                    new_self:update()
                end
            end,
            __tostring = self.__tostring,
        }
    )
end


function text:update()
    if not self.font then return end
    if not self.wrap_limit then return end
    if not self.content then return end
    
    local width, textList = self.font:getWrap(self.content, self.wrap_limit)
    self.__internal_text_lines = textList
    self.size = ({width = width, height = #textList * self.font:getHeight()})
end


function text:visual()
    love.graphics.setColor(self.color)
    if love.graphics.getFont() ~= self.font then
        love.graphics.setFont(self.font)
    end

    for i, line in ipairs(self.__internal_text_lines) do
        love.graphics.print(
            line,
            self.__global_position.x,
            self.__global_position.y + ((i-1) * self.font:getHeight())
        )
    end
end


return text
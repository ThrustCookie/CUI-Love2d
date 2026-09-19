-- Cemi UI Text widget --

---@class Image : Widget
---@field protected __source table
---@field protected __tint color
---@field source string | table
---@field tint color | widget_field
local image = require [[Widgets.Widget]]:extend()


---@param source string | table
function image:set_image_source(source)
    local img_obj
    if type(source) == 'string' then
        local image_data = love.image.newImageData(source)
        local width, height = image_data:getDimensions()
        self.size = {width = width, height = height}
        img_obj = love.graphics.newImage(image_data)

    else --- IDK
        img_obj = love.graphics.newImage(source)
    end

    self.__source = img_obj
end

---------------
--- Format Functions
---------------

function image.format.tint(value)
    if type(value) == 'number' then
        return {value, value, value}
    end

    return value
end

---@class Image_Template
---@field name? string
---@field position? vector
---@field scale? vector
---@field shear? vector
---@field rotation? number
---@field margin? vector | {top?:number,down?:number,left?:number,right?:number}
---@field OnHovered? fun(self:Widget)
---@field OnUnhovered? fun(self:Widget)
---@field OnPressed? fun(self:Widget)
---@field OnReleased? fun(self:Widget)
---@field OnClicked? fun(self:Widget)
---@field children? Widget[]
---
---@field source string | widget_field
---@field tint? number | {[1]:number,[2]:number,[2]:number,[4]?:number} | widget_field


---@param t? Image_Template
---@return Image
function image.new(t)
    t = t or {}
    t.name = t.name or "Image"

    local i = image:child_new(t)

    i.__tint = image.format.tint(1)
    i.__source = ""
    
    i.tint = t.tint or 1
    i.source = t.source or ""

    return i
end

function image:child_new(t)
    return setmetatable(
        self.super.new(t), ---@diagnostic disable-line
        {
            __index = function (new_self, key)
                if self[key] then return self[key] end

                return self.super.__index(new_self, key)
            end,
            __newindex = function (new_self, key, value)
                self.__newindex(new_self, key, value)

                if key == 'source' then
                    new_self:set_image_source(value)
                    return
                end
            end,
            __tostring = self.__tostring,
        }
    )
end


function image:visual()
    love.graphics.setColor(self.tint)
    love.graphics.draw(
        self.__source,
        self.__global_position.x,
        self.__global_position.y
    )
end


return image
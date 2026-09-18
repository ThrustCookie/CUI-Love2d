-- Cemi UI Text widget --

---@class Image : Widget
---@field __source table
---@field __tint color
---@field source string | widget_field
---@field tint color | widget_field
local image = require [[Widgets.Widget]]:extend()

---@param self Image
---@param new_img any
local function set_image_source(self, new_img)
    local img_obj
    if type(new_img) == 'string' then
        local image_data = love.image.newImageData(new_img)
        local width, height = image_data:getDimensions()
        self.size = {width = width, height = height}
        img_obj = love.graphics.newImage(image_data)

    else --- IDK
        img_obj = love.graphics.newImage(new_img)
    end
    rawset(self, [[img]], img_obj)
end

---------------
--- Format Functions
---------------

function image.format.color(value)
    if type(value) == 'number' then
        return {value, value, value}
    end

    return value
end

---@class Image_Template : Widget_Template
---@field image? string | widget_field
---@field tint? number | {[1]:number,[2]:number,[2]:number,[4]?:number} | widget_field


---@param t? Text_Template
---@return Text
function image.new(t)
    t = t or {}
    t.name = t.name or "Text"

    local i = image:child_new(t)



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


function image:update()
    
end


function image:visual()
    love.graphics.setColor(self.tint)
    love.graphics.draw(
        self.source,
        self.__global_position.x,
        self.__global_position.y
    )
end


return image
--- Cemi UI Image Widget ---


local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

--- definitions ---

--- Image Widget displays an image with a specified path
---@class Image : Widget
---@field img any
---@field tint {[1]:number,[2]:number,[3]:number,[4]:number|nil}
local Image = setmetatable({}, Widget)
Image.img = nil ---@TODO add an __index() function that checks and creates if nessesary a new love.Image
Image.tint = {1,1,1}

---@class Image_Template : Widget_Template
    ---@field img? string| any
    ---@field tint? {[1]:number,[2]:number,[3]:number,[4]:number?}

---@param template? Image_Template
---@return Image
function Image:new(template)
    local t = setmetatable(Widget:new(template), Image) ---@cast t Image
    self.__index = Image

    --- default values
    if template == nil then
        return t
    end
    
    if template.img then
        if type(template.img) == 'string' then
            local image_data = love.image.newImageData(template.img)
            local width, height = image_data:getDimensions()
            t:set_size({width = width, height = height})
            t.img = love.graphics.newImage(image_data)
        else
            t.img = love.graphics.newImage(template.img)
        end
    end

    if template.tint then
        t.tint = template.tint
    end
    return t
end

---@param template Image_Template
---@return Image
function Image:__call(template)
    return self:new(template)
end

function Image:__tostring()
    return string.format("<Image: %i>", self.id)
end

function Image:draw()
    love.graphics.setColor(self.tint)
    love.graphics.draw(
        self.img,
        self.global_position.x,
        self.global_position.y
    )
end


return Image
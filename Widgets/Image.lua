--- Cemi UI Image Widget ---


local relative_root = require "root_path"
local Widget = require (relative_root.."Widgets.Widget") ---@type Widget

---comment
---@param self Image
---@param new_img any
local function set_image(self, new_img)
    local img_obj
    if type(new_img) == 'string' then
        local image_data = love.image.newImageData(new_img)
        local width, height = image_data:getDimensions()
        self:set_size({width = width, height = height})
        img_obj = love.graphics.newImage(image_data)

    else --- IDK
        img_obj = love.graphics.newImage(new_img)
    end
    rawset(self, [[img]], img_obj)
end

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
        set_image(t, template.img)
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

function Image:__index(key, value)
    if key == [[img]] then
        set_image(self, value)
    else
        rawset(self, key, value)
    end
    
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
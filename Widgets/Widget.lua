--- abstract logic for other UI elements ---

local id = 1

----@alias sizing_options 'Fixed'|'Fill'|"size_to_content"

---@alias direction_options 'width' | 'height'
---@alias sizing_options 'Fixed'|'Fill'|'Fit'

---@class Padding
    ---@field left number
    ---@field right number
    ---@field top number
    ---@field down number

---@class Sizing
    ---@field width {value: number, mode: sizing_options, min: nil | number, max: nil | number}
    ---@field height {value: number, mode: sizing_options, min: nil | number, max: nil | number}
local Sizing = {
    new = function()
        return {
            width = { value = 0, mode = 'Fixed', min = nil, max = nil },
            height = { value = 0, mode = 'Fixed', min = nil, max = nil }
        }
    end
    
}

---@class Widget
    ---@field protected id number
    ---@field position {x:number,y:number} -- the x and y position of the widget
    ---@field __internal_position {x:number,y:number} 
    ---@field size Sizing
    ---@field padding Padding
    ---@field children Widget[] -- child widgets contained within this widget
local Widget = {}

Widget.id = 0
Widget.position = {x=0,y=0}
Widget.__internal_position = {x=0,y=0}
Widget.size = Sizing.new()
Widget.padding = { left = 0, right = 0, top = 0, down = 0 }
Widget.children = {}


-- initalize widget
---@param incrementID boolean | nil
---@return Widget
function Widget:new(incrementID)
    local t = {} -- t for template
    setmetatable(t, self)
    self.__index = self

    -- Setup debug text
    t.id = id
    if incrementID or incrementID == nil then
        id = id + 1
    end
    

    -- make new tables for all the variables with references
    -- this makes it so they dont keep referencing the same table and modifiying it
    t.position = {x=0,y=0}
    t.__internal_position = {x=0,y=0}
    t.size = Sizing.new()
    t.padding = { left = 0, right = 0, top = 0, down = 0 }
    t.children = {}
    return t
end

function Widget:__tostring()
    return string.format("< Widget: %i>", self.id)
end

---@param padding number | Padding | {x:number,y:number}
function Widget:set_padding(padding)
    if type(padding) == "number" then -- if only one number is given
        for index, _ in next, self.padding do -- set all sides to that number
            self.padding[index] = padding 
        end
    
    elseif 
        padding.x ~= nil 
        and padding.y ~= nil 
    then
    
        self.padding.left = padding.x
        self.padding.right = padding.x
        self.padding.top = padding.y
        self.padding.down = padding.y

    elseif 
        padding.left ~= nil 
        and padding.right ~= nil 
        and padding.top ~= nil 
        and padding.down ~= nil 
    then
        self.padding.left = padding.left
        self.padding.right = padding.right
        self.padding.top = padding.top
        self.padding.down = padding.down
    else
        error( tostring(self) .. " padding is set incorrectly with value of " .. tostring(padding))
    end
end

---@alias sizeMinMax {mode: 'Fill'|'Fit', min: nil|number, max: nil|number}

---@param value 
---| number 
---| 'Fill'
---| 'Fit'
---| sizeMinMax
---| {width: number|'Fill'|'Fit'|sizeMinMax, height: number|'Fill'|'Fit'|sizeMinMax}
function Widget:set_size(value)
    local dirs = {'width', 'height'} ---@type direction_options[]

    if type(value) == "number" then
        self.size.width.value = value
        self.size.width.mode = 'Fixed'
        self.size.height.value = value
        self.size.height.mode = 'Fixed'

    elseif type(value) == "string" then
        self.size.width.value = 0
        self.size.width.mode = value
        self.size.height.value = 0
        self.size.height.mode = value
    
    elseif value.mode ~= nil then
        for i = 1, 2, 1 do
            self.size[dirs[i]].value = 0
            self.size[dirs[i]].mode = value.mode

            if value[dirs[i]].min ~= nil then
                self.size[dirs[i]].value = value[dirs[i]].min
                self.size[dirs[i]].min = value[dirs[i]].min
            end
            
            if value[dirs[i]].max ~= nil then
                self.size[dirs[i]].max = value[dirs[i]].max
            end
        end
        
    elseif value.width ~= nil and value.height ~= nil then
        for i = 1, 2, 1 do
            
            if type(value[dirs[i]]) == 'number' then
                self.size[dirs[i]].value = value[dirs[i]]
                self.size[dirs[i]].mode = 'Fixed'

            elseif type(value[dirs[i]]) == "string" then
                self.size[dirs[i]].value = 0
                self.size[dirs[i]].mode = value[dirs[i]]
            
            elseif value[dirs[i]].mode ~= nil then
                self.size[dirs[i]].value = 0
                self.size[dirs[i]].mode = value.mode
    
                if value.min ~= nil then
                    self.size[dirs[i]].value = value.min
                    self.size[dirs[i]].min = value.min
                end
                
                if value.max ~= nil then
                    self.size[dirs[i]].max = value.max
                end
            else
                error("wrong size bro, fix!")
            end
        end
        

    else
        error("you setting size wrong bro! --2am programming")

    end
    
end

local relative_root = "External."
local CUI = require (relative_root.."CUI.Internal")

--- Setup children, returns added child index
---@param child Widget
---@return integer
function Widget:add_child(child)
    self.children[#self.children+1] = child
    
    CUI.refresh_tree()
    return #self.children
end


---@param direction direction_options
function Widget:fit(direction)
    --- calculations for adequate padding and axis to make my life easier
    local axis
    local pad_dir
    if direction == 'width' then
        axis = "x"
        pad_dir = {"right", "left"}
    else -- if direction is height
        axis = "y"
        pad_dir = {'top', 'down'}
    end
    
    -- basic size is padding
    local calc_size = self.padding[pad_dir[1]] + self.padding[pad_dir[2]]
    
    --- get farthest child ---
    local biggestChildSize = 0
    for _, child in next, self.children do ---@param child Widget
        biggestChildSize = 
            math.max(
                biggestChildSize,
                child.position[axis] + child.size[direction].value
            )
    end
    calc_size = calc_size + biggestChildSize

    self.size[direction].value = calc_size
end

---@param self Widget
---@param direction direction_options
function Widget:place_children(direction)
    local offset = 0
    local axis
    if direction == 'width' then 
        axis = 'x'
        offset = offset + self.padding.left
    else -- if direction is height
        axis = 'y'
        offset = offset + self.padding.top
    end

    

    offset = offset + self.__internal_position[axis]

    for _, child in ipairs(self.children) do
        child.__internal_position[axis] = 
            child.position[axis]
            + offset
    end
end

return Widget
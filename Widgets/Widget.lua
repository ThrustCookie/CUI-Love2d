--- abstract logic for other UI elements ---

local id = 0

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
            width = { value = 0, mode = 'Fit', min = nil, max = nil },
            height = { value = 0, mode = 'Fit', min = nil, max = nil }
        }
    end
}

---@class Widget
    ---@field protected id number
    ---@field relative_position {x:number,y:number} -- the x and y relative_position of the widget
    ---@field global_position {x:number,y:number} 
    ---@field size Sizing
    ---@field padding Padding
    ---@field children Widget[] -- child widgets contained within this widget
local Widget = {}

function Widget:__tostring()
    return string.format("<Widget: %i>", self.id)
end

---comment
---@param self Widget
---@param template Widget_Template
---@return Widget
function Widget:__call(template)
    return self:new(template)
end

---@param padding number | Padding | {x:number,y:number}
function Widget:set_padding(padding)
    if type(padding) == 'number' then -- if only one number is given
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
        error(string.format(
            "%s padding is set incorrectly with value of %s",
            tostring(self),
            tostring(padding)
        ))
    end
end

---@alias sizeMinMax {mode:'Fill'|'Fit',min:number?,max:number?}

---@param size 
---| number 
---| 'Fill'
---| 'Fit'
---| sizeMinMax
---| {[1]:number|'Fill'|'Fit'|sizeMinMax,[2]:number|'Fill'|'Fit'|sizeMinMax}
---| {width:number|'Fill'|'Fit'|sizeMinMax,height:number|'Fill'|'Fit'|sizeMinMax}
function Widget:set_size(size)
    
    local dirs = {'width', 'height'} ---@type direction_options[]

    if type(size) == 'number' then
        self.size.width.value = size
        self.size.width.mode = 'Fixed'
        self.size.height.value = size
        self.size.height.mode = 'Fixed'

    elseif type(size) == 'string' then
        self.size.width.value = 0
        self.size.width.mode = size
        self.size.height.value = 0
        self.size.height.mode = size
    
    elseif size.mode ~= nil then
        for i = 1, 2, 1 do
            self.size[dirs[i]].value = 0
            self.size[dirs[i]].mode = size.mode

            if size[dirs[i]].min ~= nil then
                self.size[dirs[i]].value = size[dirs[i]].min
                self.size[dirs[i]].min = size[dirs[i]].min
            end
            
            if size[dirs[i]].max ~= nil then
                self.size[dirs[i]].max = size[dirs[i]].max
            end
        end
        
    elseif size.width ~= nil and size.height ~= nil then
        --- TODO: rework this code at some point, its too complicated

        for i = 1, 2, 1 do
            
            if type(size[dirs[i]]) == 'number' then
                self.size[dirs[i]].value = size[dirs[i]]
                self.size[dirs[i]].mode = 'Fixed'

            elseif type(size[dirs[i]]) == 'string' then
                self.size[dirs[i]].value = 0
                self.size[dirs[i]].mode = size[dirs[i]]
            
            elseif size[dirs[i]].mode ~= nil then
                self.size[dirs[i]].value = 0
                self.size[dirs[i]].mode = size.mode
    
                if size.min ~= nil then
                    self.size[dirs[i]].value = size.min
                    self.size[dirs[i]].min = size.min
                end
                
                if size.max ~= nil then
                    self.size[dirs[i]].max = size.max
                end
            else
                error("Sizing set incorrectly for "..tostring(self))
            end
        end
    else 
        error("Sizing set incorrectly for "..tostring(self)) 
    end
    
end

---@param position
---|number
---|{[1]:integer,[2]:integer}
---|{x:integer,y:integer}
function Widget:set_position(position)
    if type(position) == 'number' then
        self.relative_position = {x = position, y = position}

    elseif 
        position.x ~= nil
        and position.y ~= nil
    then
        self.relative_position = {x = position.x, y = position.y}

    elseif #position == 2 then
        assert (
        type(position[1]) == 'number' and type(position[1]) == 'number',
        "Position set incorrectly"
        )
        self.relative_position = {x = position[1], y = position[2]}

    else 
        error("Position set incorrectly")
    end
end

local relative_root = require "root_path"
local ICUI = require (relative_root.."Internal")

--- Setup children,
--- returns the first added child index and how many were added
---@param ... Widget
---@return integer, integer
function Widget:add_child(...)
    for _, widget in ipairs({...}) do
        self.children[#self.children+1] = widget
    end

    ICUI.refresh_tree()
    return #self.children - #{...}, #{...}
end


--- Internal functions

---@param direction direction_options
function Widget:fit(direction)
    --- calculations for adequate padding and axis to make my life easier
    local axis
    local pad_dir
    if direction == 'width' then
        axis = 'x'
        pad_dir = {'right', 'left'}
    else -- if direction is height
        axis = 'y'
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
                child.relative_position[axis] + child.size[direction].value
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

    

    offset = offset + self.global_position[axis]

    for _, child in ipairs(self.children) do
        child.global_position[axis] = 
            child.relative_position[axis]
            + offset
    end
end

---@class Widget_Template
    ---@field position?
        ---|number
        ---|{[1]:number,[2]:number}
        ---|{x:number,y:number}
    ---@field size?
        ---|number 
        ---|'Fill'
        ---|'Fit'
        ---|sizeMinMax
        ---|{width:number|'Fill'|'Fit'|sizeMinMax,height:number|'Fill'|'Fit'|sizeMinMax}
--- TODO: make padding not need to have any direction could be nil ej. just top and left 
    ---@field padding?
        ---|number
        ---|Padding
        ---|{[1]:number,[2]:number}
        ---|{x:number,y:number}
    ---@field children?
        ---|Widget[]

-- initalize widget
---@param template Widget_Template | nil
---@return Widget
function Widget:new(template)

    local t = {}
    setmetatable(t, Widget)
    self.__index = Widget

    -- Setup debug identifier
    t.id = id
    id = id+1
    
    -- makes new tables for all the variables with references
    -- this makes it so they dont keep referencing the same table and modifiying it

    t.relative_position = {x=0,y=0}
    t.global_position = {x=0,y=0}
    t.size = Sizing.new()
    t.padding = { left = 0, right = 0, top = 0, down = 0 }
    t.children = {}

    if template == nil then return t end

    if template.padding then
        t:set_padding(template.padding)
        template.padding = nil
    end

    if template.size then
        t:set_size(template.size)
        template.size = nil
    end

    if template.position then
        t:set_position(template.position)
        template.position = nil
    end

    if template.children then
        for _, child in ipairs(template.children) do
            t:add_child(child)
        end
        template.children = nil
    end

    return t
end

return Widget
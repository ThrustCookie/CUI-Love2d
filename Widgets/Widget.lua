--- Cemi UI basic widget ---

---@alias reference {table:table, key:string}

---@alias widget_field reference | function

---------------
-- Stored values
---------------

---@class Margin 
---@field left number
---@field right number
---@field top number
---@field down number

---@class Sizing
---@field width {
    ---value: number,
    ---mode: sizing_options,
    ---min?: number,
    ---max?: number}
---@field height {
    ---value: number,
    ---mode: sizing_options,
    ---min?: number,
    ---max?: number}

---@class Widget : Object
---@field protected __name string
---@field protected __id number
---@field protected __position {x:number,y:number}
---@field protected __global_position {x:number,y:number}
---@field protected __size Sizing
---@field protected __margin Margin
---@field visual? fun(self)
---@field format {[string]:fun(value: any): any?, string?}

--------------------
-- Setter variables
--------------------

---@alias sizing_options 'fixed'|'fill'|'fit'
---@alias _sizing
---| number
---| 'fill'
---| 'fit'
---| {mode: 'fill'|'fit', min?:number, max?:number} 

---@class Widget : Object
---@field position
    ---| number
    ---| {[1]:number,[2]:number}
    ---| {x:number,y:number}
    ---| widget_field
---@field size
    ---| _sizing --- sets both height and width
    ---| {width: _sizing, height: _sizing}
    ---| {x: _sizing, y: _sizing}
    ---| {[1]: _sizing, [2]: _sizing}
    ---| Sizing
    ---| widget_field
---@field margin
    ---| number
    ---| {x: number,y: number}
    ---| {[1]:number,[2]:number}
    ---| {top?:number,down?:number,left?:number,right?:number}
    ---| Margin
    ---| widget_field
---@field children
    ---| Widget[]
local widget = require [[object]]:extend()


local id = 1

---------------
--- Format Functions
---------------
widget.format = {}

function widget.format.position(value)
    if type(value) == 'number' then
        return {x=value, y=value}
    end

    if not type(value) == 'table' then
        return nil, "Position set incorrectly with value of "..tostring(value)
    end

    if value[1] and value[2] then
        return {x=value[1], y=value[2]}
    end

    if value.x and value.y then
        return {x=value.x, y=value.y}
    end
end

function widget.format.size(value)
    if type(value) == 'number' then
        return { ---@type Sizing
            height = {mode = 'fixed', value = value},
            width = {mode = 'fixed', value = value}
        }

    elseif value == 'fill' or value == 'fit' then
        return { ---@type Sizing
            height = {mode = value, value = 0},
            width = {mode = value, value = 0}
        }

    elseif not type(value) == 'table' then
        return nil, "Sizing set incorrectly with value "..tostring(value)

    elseif value.mode == 'fill' or value.mode == 'fit' then
        return { ---@type Sizing
            height = {
                mode = value.mode,
                value = 0,
                max = value.max,
                min = value.min
            },
            width = {
                mode = value.mode,
                value = 0,
                max = value.max,
                min = value.min
            },
        }
    end

    if value.x and value.y then
        value.width = value.x
        value.height = value.y

    elseif value[1] and value[2] then
        value.width = value[1]
        value.height = value[2]
    end

    ---@type Sizing
    local sizing = {
        height = {mode='fixed',value=0},
        width = {mode='fixed',value= 0}
    }

    for _, key in ipairs({'width', 'height'}) do
        if type(value[key]) == 'number' then
            sizing[key] = {mode='fixed', value=value[key]}

        elseif value[key] == 'fill' or value[key] == 'fit' then
            sizing[key] = {mode=value[key], value=0}

        elseif not type(value[key]) == 'table' then
            error("Sizing set incorrectly at side "..key.." with value "..tostring(value[key]))

        elseif value[key].mode == 'fill' or value[key].mode == 'fit' then
            sizing[key] = {
                mode=value[key].mode,
                value=0,
                max=value[key].max,
                min=value[key].min,
            }
        end
    end

    return sizing
end

---@return Margin?, string?
function widget.format.margin(value)
    if type(value) == 'number' then
        return {top=value, down=value, left=value, right=value}
    elseif type(value) == 'table' then
        if value.x and value.y then
            return {
                top=value.y, down=value.y,
                left=value.x, right=value.x
            }
        end
        if value[1] and value[2] then
            return {
                top=value[2], down=value[2],
                left=value[1], right=value[1]
            }
            
        end

        local margin = {}
        for _, key in ipairs({'top', 'down', 'left', 'right'}) do
            if value[key] then
                margin[key] = value[key]
            else
                margin[key] = 0

            end
        end
        return margin
    end

    return nil, "margin is set incorrectly with value of "..tostring(value)
end


--The following set and get funcs are used to easily set and get the ui's functions without calling external functions

----------------------
--- Set Protection
----------------------
function widget:__newindex(key, value)

    if rawget(self, "__"..key) == nil then
        rawset(self, key, value)
        return
    end

    if type(value) == 'function' then
        rawset(self, '__'..key, value)
        return
    elseif type(value) == 'table' then
        if value.table and value.key then
            rawset(self, '__'..key, value)
            return
        end
    end

    if not self.format[key] then
        rawset(self, '__'..key, value)
        return
    end

    local v, e = self.format[key](value)
    assert(v, self, e)

    rawset(self, '__'..key, v)
end

----------------------
--- Get Protection
----------------------
---@param key string
---@return any
function widget:__index(key)
    --if key == 'format' then return widget.format end

    local value = rawget(self, '__'..key) -- private key value

    -- if no private key exists
    if value == nil then return self.super[key] end

    if type(value) == 'table' then -- get value from reference
        if value.table and value.key then
            return self.format[key](value.table[value.key])
        end
    elseif type(value) == 'function' then
        return self.format[key](value())
    end

    return value
end

------------
--- debugging
------------
function widget:__tostring()
    return string.format("<%s: %i>", self.__name, self.__id)
end

----------
--- Constructors
----------

---@class Widget_Template
---@field name? string
---@field position?
---| number
---| {[1]:number,[2]:number}
---| {x:number,y:number}
---| widget_field
---@field size?
---| _sizing
---| {width:_sizing,height:_sizing}
---| {x:_sizing,y:_sizing}
---| {[1]:_sizing,[2]:_sizing}
---| widget_field
---@field margin?
---| number
---| {x:number,y:number}
---| {[1]:number,[2]:number}
---| {top?:number,down?:number,left?:number,right?:number}
---| widget_field
---@field children? Widget[]

-- initalize widget
---@param t? Widget_Template
---@return Widget
function widget.new(t)
    local w = widget:extend() ---@type Widget

    t = t or {}

    w.__name    = t.name or "Widget"
    w.__id      = id
    id = id+1

    ---@diagnostic disable
    w.__global_position = widget.format.position(0)
    w.__position        = widget.format.position(0)
    w.__size            = widget.format.size('fit')
    w.__margin          = widget.format.margin(0)
    ---@diagnostic enable

    --initalize all values
    w.position  = t.position    or 0
    w.size      = t.size        or 'fit'
    w.margin    = t.margin      or 0
    w.children  = t.children    or {}

    return w
end

function widget:child_new(t)
    return setmetatable(
        self.super.new(t), ---@diagnostic disable-line
        {
            __index = function (new_self, key)
                if self[key] then return self[key] end

                return self.super.__index(new_self, key)
            end,
            __newindex = self.__newindex,
            __tostring = self.__tostring,
        }
    )
end

--------------
--- Method Functions
--------------

--- Setup children,
--- returns the first added child index and how many were added
---@param ... Widget
---@return integer, integer
function widget:add_child(...)
    for _, w in ipairs({...}) do
        self.children[#self.children+1] = w
    end

    return #self.children - #{...}, #{...}
end

--- Setup children,
--- returns the first added child index and how many were added
---@param index integer
---@param ... Widget
---@return integer, integer
function widget:add_child_at(index, ...)
    for i, w in ipairs({...}) do
        table.insert(self.children, i-1 + index, w)
    end

    return #self.children - #{...}, #{...}
end

--- Remove children,
--- returns the first added child index and how many were added
---@param child Widget
function widget:remove_child(child)

    for index, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, index)
            return
        end
    end

    error(string.format(
        "Widget %s not found as child of %s",
        tostring(widget),
        tostring(self))
    )
end

--- draws a widget as the root
--- this runs all the sizing and position logic
---@param isroot? boolean
function widget:draw(isroot)

    self:__sizing_pass('width')
    self:__sizing_pass('height')

    if isroot == nil or isroot == true then
        self.__global_position.x = self.position.x
        self.__global_position.y = self.position.y
    end

    self:__place_pass('width')
    self:__place_pass('height')

    self:__draw_pass()
end

-------------------------
--- Internal functions
-------------------------

---@alias direction_options 'width' | 'height'

---@param direction direction_options
function widget:__sizing_pass(direction)
    if self.size[direction].mode == 'fit' then
        self:__fit(direction)
    end

    for _, child in ipairs(self.children) do
       child:__sizing_pass(direction)
    end
    
    
    if self:__do_children_have_sizing(direction, 'fill') then
        self:__fill_children(direction)
    end
end

---@param direction direction_options
function widget:__fit(direction)
    --- calculations for adequate margin and axis to make my life easier
    local axis
    local pad_dir
    if direction == 'width' then
        axis = 'x'
        pad_dir = {'right', 'left'}
    else -- if direction is height
        axis = 'y'
        pad_dir = {'top', 'down'}
    end
    
    -- basic size is margin
    local calc_size = self.margin[pad_dir[1]] + self.margin[pad_dir[2]]
    
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

---@param direction direction_options
function widget:__fill_children(direction)

    local leftover_size = self.size[direction].value

    local margin_direction
    if direction == 'height' then
        margin_direction = {'top', 'down'}
    else -- if direction == 'width'
        margin_direction = {'left', 'right'}
    end
    local margin = {
        self.margin[margin_direction[1]] or 0,
        self.margin[margin_direction[2]] or 0
    }

    leftover_size = leftover_size - margin[1] - margin[2]

    for _, child in ipairs(self.children) do
        if child.size[direction].mode == 'fill' then
            child.size[direction].value = leftover_size
        end
    end
end

---returns true if any of child has fill sizing
---@param self Widget
---@param direction direction_options
---@param mode sizing_options
---@return boolean
function widget:__do_children_have_sizing(direction, mode)
    for _, child in ipairs(self.children) do
        if child.size[direction].mode == mode then
            return true
        end
    end

    return false
end


---@param direction direction_options
function widget:__place_pass(direction)
    if #self.children == 0 then return end

    self:__place_children(direction)
    for _, child in ipairs(self.children) do
        child:__place_pass(direction)
    end
end

---@param self Widget
---@param direction direction_options
function widget:__place_children(direction)
    local offset = 0
    local axis
    if direction == 'width' then
        axis = 'x'
        offset = offset + self.margin.left
    else -- if direction is height
        axis = 'y'
        offset = offset + self.margin.top
    end
    
    offset = offset + self.__global_position[axis]

    for _, child in ipairs(self.children) do
        child.__global_position[axis] = child.position[axis] + offset
    end
end

function widget:__draw_pass()
    if self.visual then self:visual() end

    for _, child in ipairs(self.children) do
        child:__draw_pass()
    end
end

return widget
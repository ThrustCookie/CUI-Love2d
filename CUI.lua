---@TODO factor scale in the sizing calculations

---@class CUI
local CUI = {}

local r = ""

---@type fun(template?: Widget_Template): Widget
CUI.widget      = require(r..[[Widgets.Widget]]    ).new

---@type fun(template?: Box_Template): Box
CUI.box         = require(r..[[Widgets.Box]]       ).new

---@type fun(template?: Alignment_Template): Alignment
CUI.alignment   = require(r..[[Widgets.Alignment]] ).new

---@type fun(template?: Text_Template): Text
CUI.text        = require(r..[[Widgets.Text]]      ).new

---@type fun(template?: Image_Template): Image
CUI.image       = require(r..[[Widgets.Image]]     ).new

CUI.to_button = function (widget) ---@param widget Widget
    
    ---@cast widget Box | table
    widget.base_color = widget.color

    local function tint_base_color(col)
        return {col[1]*widget.base_color[1], col[2]*widget.base_color[2], col[3]*widget.base_color[3], widget.base_color[4]}
    end
    
    if not widget.hovered_color then
        widget.hovered_color = tint_base_color({.75,.75,.5})
    end
    if not widget.pressed_color then
        widget.pressed_color = tint_base_color({.35,.2,.35})
    end

    widget.OnHovered = function (self)
        self.color = self.hovered_color
    end

    widget.OnUnhovered = function (self)
        ---@cast self Box | table
        self.color = self.base_color
    end

    widget.OnPressed = function (self)
        ---@cast self Box | table
        self.color = self.pressed_color
    end
    
    widget.OnReleased = function (self)
        ---@cast self Box | table
        if self.hovered then
            self.color = self.hovered_color
        end
    end

    return widget
end

---return a basic grid ui
---@param list Widget[]
---@param item_wrap_limit integer
---@param t Alignment_Template?
function CUI.grid(
    list,
    item_wrap_limit,
    t
)
    if t then
        assert(t.children == nil, "Children not allowed for grid template")
    end

    local tangent_direction = 'left to right'
    if t then if t.direction == 'left to right' then
        tangent_direction = 'top to bottom'
    end end
    

    local g = CUI.alignment(t)
    

    for i, item in ipairs(list) do
        if (i-1)%item_wrap_limit == 0 then
            local a = CUI.alignment(t)
            a.direction = tangent_direction
            g:add_child(a)
        end

        local line = g.children[#g.children]
        line:add_child(item)
    end

    return g
end


return CUI
---@TODO factor scale in the sizing calculations

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

return CUI
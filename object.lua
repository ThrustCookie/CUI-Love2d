--||--
--This Object implementation was taken from SNKRX (MIT license). Slightly modified, this is a very simple OOP base

--Taken from the balatro source code, modified further

---@class Object
---@field super Object
Object = {}
Object.__index = Object

function Object:extend()
  local cls = {}
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end

return Object
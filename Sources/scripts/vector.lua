vector = {
x = 0,
y = 0,
z = 0
}

function vector:new(o)
this = o or {}
setmetatable(this, self)
self.__index = self
return this
end

function vector:new(x, y, z, o)
this = o or {}
setmetatable(this, self)
self.__index = self
this.x = x
this.y = y
this.z = z
return this
end

function vector:unit()
this = o or {}
setmetatable(this, self)
self.__index = self

local azimuth = math.random() * 2.0 * math.pi
local x = math.cos(azimuth)
local y = math.sin(azimuth)
local z = (2.0 * math.random()) - 1.0

this.x = x * math.sqrt(1.0 - z * z)
this.y = y * math.sqrt(1.0 - z * z)
this.z = z
return this
end

function vector:dot(v)
return self.x * v.x + self.y * v.y + self.z * v.z
end

function vector:scale(s)
self.x = self.x * s
self.y = self.y * s
self.z = self.z * s
end

function vector:cross(v)
local cp = vector:new()
cp.x = self.y * v.z - self.z * v.y
cp.y = self.z * v.x - self.x * v.z
cp.z = self.x * v.y - self.y * v.x
return cp
end

function vector:normalize()
local d = math.sqrt(self:dot(self))

if  (math.abs(d - 1.0) > 1.0e-6) then
local s = 1.0 / d

self.x = s * self.x
self.y = s * self.y
self.z = s * self.z
end
end
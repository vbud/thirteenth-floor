require ("universe")
require ("math")


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


local points = points()
local velocities = velocities()
local totalcount = universe.particleCount()
local scale  = universe.scale();
local vscale = universe.vscale();


local universe1 = {
    {
        pratio = 0.1,
        radii = { 1.8, 1.905 },
        vel = { 1.0, 2.0 }
    },
    {
        pratio = 0.6,
        radii = { 2.5, 2.501 },
        vel = { 0.4, 1.0 }
    },
    {
        pratio = 0.3,
        radii = { 3.5, 3.801 },
        vel = { 0.4, 1.0 }
    }
}

local universe2 = {
    {
        pratio = 0.3,
        radii = { 0.0, 1.005},
        vel = { 0.1, 0.2 }
    },
    {
        pratio = 0.3,
        radii = { 3.1, 3.2},
        vel = { 0.4, 1.0 }
    },
    {
        pratio = 0.4,
        radii = { 4.1, 4.2},
        vel = { 0.4, 1.0 }
    }
}

local multiverse = {
    {
        pratio = 0.3333,
        atom = universe1,
        offset = vector:new(-5.0, 0.0, 0.0),
        vel = vector:new(1.0, 1.0, 0.0)
    },
    {
        pratio = 0.3333,
        atom = universe2,
        offset = vector:new(5.0, 0.0, 0.0),
        vel = vector:new(-1.0, -1.0, 0.0)
    },
    {
        pratio = 0.3333,
        atom = universe2,
        offset = vector:new(0.0, 8.66, 0.0),
        vel = vector:new(-1.0, -1.0, 0.0)
    }
}

local p = 0
local v = 0
local remaining = totalcount
print(totalcount, " particles in the multiverse")
for i, universe in pairs(multiverse) do
    local pinUniverse = math.floor(totalcount * universe.pratio)
    print(pinUniverse, " particles in universe ", i)
    for j, layer in pairs(universe.atom) do
        local layerCount = math.min(remaining, math.floor(pinUniverse * layer.pratio))
        remaining = remaining - layerCount
        print(layerCount, " particles in layer ", j)
        local inner = layer.radii[1]-- * scale
        local outer = layer.radii[2]-- * scale
        local velMin = layer.vel[1]
        local velMax = layer.vel[2]
        print("inner = ", inner, "outer = ", outer)
        for k=0,math.floor(layerCount/4) do

            local point = vector:unit()
            point:scale(math.random(inner, outer))

            points[p] = point.x + universe.offset.x; p = p + 1
            points[p] = point.y + universe.offset.y; p = p + 1
            points[p] = point.z + universe.offset.z; p = p + 1
            points[p] = 1.0; p = p + 1

            local velocity = point:cross(vector:unit())
            velocity:scale(math.random(velMin, velMax))

            velocities[v] = velocity.x + universe.vel.x; v = v + 1
            velocities[v] = velocity.y + universe.vel.y; v = v + 1
            velocities[v] = velocity.z + universe.vel.z; v = v + 1
            velocities[v] = 1.0; v = v + 1
        end
    end
end

print("Placed ", p, " particles")


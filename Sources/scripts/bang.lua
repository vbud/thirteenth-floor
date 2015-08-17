require ("system")
require ("universe")
require ("math")

local points = points()
local velocities = velocities()
local count = universe.particleCount()


function unitVector()
    local azimuth = math.random() * 2 * math.pi
    local x = math.cos(azimuth)
    local y = math.sin(azimuth)
    local z = (2 * math.random()) - 1

    return x * math.sqrt(1 - z * z), y * math.sqrt(1 - z * z), z
end



local scale  = universe.scale();
local vscale = universe.vscale();
local inner  = 2.5 * scale;
local outer  = 4.0 * scale;


local p = 0
local v = 0
for i=1,count do
    local x,y,z = unitVector()

    local scalar = math.random(inner, outer)

    points[p] = x * scalar; p = p + 1
    points[p] = y * scalar; p = p + 1
    points[p] = z * scalar; p = p + 1
    points[p] = 1.0; p = p + 1

    local scalar = math.random(inner, outer) * 50.0

    velocities[p] = x * scalar; v = v + 1
    velocities[p] = y * scalar; v = v + 1
    velocities[p] = z * scalar; v = v + 1
    velocities[p] = 1.0; v = v + 1
end

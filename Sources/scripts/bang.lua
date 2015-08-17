require ("system")
require ("universe")

local points = points()
local velocities = velocities()
local count = universe.particleCount()

print("I have ", count,  " particles!")
print(points[0])
print(points[1])
print(points[3])

points[3] = 100.0


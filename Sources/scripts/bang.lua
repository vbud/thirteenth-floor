require ("system")
require ("universe")
require ("os")


print "hello world!"


function Joel()
    local j = {
        --1 = "J",
        --2 = "o",
        --3 = "e",
        --4 = "l",
        ["handsome"] = true,
        ["sexy"] = 10,
        uber = function ()
        print "You have entered the uber zone!"
        end
    }

    return j
end

print (system.user())

print (type(universe))

print(tostring(universe.deltaTime()))

print("fps = " .. tostring(universe.fps()))
print("dt = " .. tostring(universe.deltaTime()))

local j = Joel()
j.uber()


print (os.time())
print (os.date())

--Joel["uber"]()
--Joel["uber"]()
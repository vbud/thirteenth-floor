#ifndef __UNIVERSE_H__
#define __UNIVERSE_H__

struct lua_State;

int luaopen_universe(lua_State* L);

int universe_particleCount(lua_State* L);
int universe_scale(lua_State* L);
int universe_vscale(lua_State* L);


// metatable method for handling "points[index]"
int array_index (lua_State* L);
// metatable method for handle "points[index] = value"
int array_newindex (lua_State* L);

void create_points_type(lua_State* L);

int expose_points(lua_State* L, float array[]);

// metatable method for handling "velocities[index]"
int velocities_index (lua_State* L);
// metatable method for handle "velocities[index] = value"
int velocities_newindex (lua_State* L);

void create_velocities_type(lua_State* L);

int expose_velocities(lua_State* L, float array[]);

int luaopen_array (lua_State* L);

class UniverseScript
{
public:
    UniverseScript();
    ~UniverseScript();
    
    void Update(const float fDeltaTime);
    
private:
};

#endif // __UNIVERSE_H__
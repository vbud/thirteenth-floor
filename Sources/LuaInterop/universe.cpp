#include "universe.h"

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lstring.h"
};


// hack the planet!
extern lua_State* gLua;
extern float* gPoints;
extern float* gVelocities;
extern float gScale;
extern float gVScale;
extern unsigned int gParticleCount;

static const luaL_Reg CoreLibs[] = {
    {"universe",     luaopen_universe},
    {NULL, NULL}
};

static const luaL_Reg UniverseLibs[] = {
    {"particleCount", universe_particleCount},
    {"scale",         universe_scale},
    {"vscale",        universe_vscale},
    {NULL, NULL}
};

int universe_particleCount(lua_State* L) {
    int num_args = lua_gettop(L);
    if (num_args > 0)
    {
        lua_pushstring(L, "too many arguments for universe.particleCount()");
        lua_error(L);
    }
    lua_pushnumber(L, gParticleCount);
    return 1;
}

int universe_scale(lua_State* L) {
    int num_args = lua_gettop(L);
    if (num_args > 0)
    {
        lua_pushstring(L, "too many arguments for universe.scale()");
        lua_error(L);
    }
    lua_pushnumber(L, gScale);
    return 1;
}

int universe_vscale(lua_State* L) {
    int num_args = lua_gettop(L);
    if (num_args > 0)
    {
        lua_pushstring(L, "too many arguments for universe.vscale()");
        lua_error(L);
    }
    lua_pushnumber(L, gVScale);
    return 1;
}


int luaopen_universe(lua_State* L)
{
    luaL_newlib(L, UniverseLibs);
    return 1;
}


UniverseScript::UniverseScript()
{
    for (const luaL_Reg* lib = CoreLibs; lib->func; ++lib)
    {
        luaL_requiref(gLua, lib->name, lib->func, 1);
        lua_pop(gLua, 1);
    }
}

UniverseScript::~UniverseScript()
{
}

void UniverseScript::Update(const float fDeltaTime)
{
}

// metatable method for handling "points[index]"
int points_index (lua_State* L) {
    float** parray = static_cast<float**>(luaL_checkudata(L, 1, "points"));
    int index = luaL_checkint(L, 2);
    lua_pushnumber(L, (*parray)[index-1]);
    return 1;
}

// metatable method for handle "points[index] = value"
int points_newindex (lua_State* L) {
    float** parray = static_cast<float**>(luaL_checkudata(L, 1, "points"));
    int index = luaL_checkint(L, 2);
    int value = luaL_checkint(L, 3);
    (*parray)[index-1] = value;
    return 0;
}

// metatable method for handling "velocities[index]"
int velocities_index (lua_State* L) {
    float** parray = static_cast<float**>(luaL_checkudata(L, 1, "velocities"));
    int index = luaL_checkint(L, 2);
    lua_pushnumber(L, (*parray)[index-1]);
    return 1;
}

// metatable method for handle "velocities[index] = value"
int velocities_newindex (lua_State* L) {
    float** parray = static_cast<float**>(luaL_checkudata(L, 1, "velocities"));
    int index = luaL_checkint(L, 2);
    int value = luaL_checkint(L, 3);
    (*parray)[index-1] = value;
    return 0;
}

void create_points_type(lua_State* L) {
    const struct luaL_Reg array[] = {
        { "__index",  points_index  },
        { "__newindex",  points_newindex  },
        NULL, NULL
    };
    luaL_newmetatable(L, "points");
    luaL_openlib(L, NULL, array, 0);
}

void create_velocities_type(lua_State* L) {
    const struct luaL_Reg array[] = {
        { "__index",  velocities_index  },
        { "__newindex",  velocities_newindex  },
        NULL, NULL
    };
    luaL_newmetatable(L, "velocities");
    luaL_openlib(L, NULL, array, 0);
}

// expose an array to lua, by storing it in a userdata with the array metatable
int expose_points(lua_State* L, float array[]) {
    float** parray = static_cast<float**>(lua_newuserdata(L, sizeof(float**)));
    *parray = array;
    luaL_getmetatable(L, "points");
    lua_setmetatable(L, -2);
    return 1;
}

// expose an array to lua, by storing it in a userdata with the array metatable
int expose_velocities(lua_State* L, float array[]) {
    float** parray = static_cast<float**>(lua_newuserdata(L, sizeof(float**)));
    *parray = array;
    luaL_getmetatable(L, "velocities");
    lua_setmetatable(L, -2);
    return 1;
}

// test routine which exposes our test array to Lua
int getarrayP (lua_State* L) {
    return expose_points( L, gPoints );
}

// test routine which exposes our test array to Lua
int getarrayV (lua_State* L) {
    return expose_velocities( L, gVelocities );
}

int luaopen_array (lua_State* L) {
    create_points_type(L);
    lua_register(L, "points", getarrayP);
    
    create_velocities_type(L);
    lua_register(L, "velocities", getarrayV);
    return 0;
}

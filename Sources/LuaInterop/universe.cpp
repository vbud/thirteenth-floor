#include "universe.h"

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lstring.h"
};

extern lua_State* gLua;


float _fps;
float _deltaTime;

static const luaL_Reg CoreLibs[] = {
    {"universe",     luaopen_universe},
    {"system",   luaopen_system},
    {NULL, NULL}
};

static const luaL_Reg UniverseLibs[] = {
    {"fps",        universe_fps},
    {"deltaTime",  universe_deltaTime},
    {NULL, NULL}
};

static const luaL_Reg SysLibs[] = {
    {"user",        system_user},
    {NULL, NULL}
};

int universe_fps(lua_State* L)
{
    int num_args = lua_gettop(L);
    if (num_args > 0)
    {
        lua_pushstring(L, "too many arguments for universe.fps()");
        lua_error(L);
    }
    
    lua_pushnumber(L, (lua_Number)_fps);
    return 1;
}

int universe_deltaTime(lua_State* L)
{
    int num_args = lua_gettop(L);
    if (num_args > 0)
    {
        lua_pushstring(L, "too many arguments for universe.deltaTime()");
        lua_error(L);
    }
    
    lua_pushnumber(L, (lua_Number)_deltaTime);
    return 1;
}

int system_user(lua_State* L)
{
    int num_args = lua_gettop(L);
    if (num_args > 0)
    {
        lua_pushstring(L, "too many arguments for game.user()");
        lua_error(L);
    }
    
    char userName[100];
#ifdef WIN32
    DWORD nUserName = sizeof(userName);
    GetUserName(userName, &nUserName);
#elif defined(__APPLE__)
#endif
    lua_pushstring(L, userName);
    return 1;
}

int luaopen_universe(lua_State* L)
{
    luaL_newlib(L, UniverseLibs);
    return 1;
}

int luaopen_system(lua_State* L)
{
    luaL_newlib(L, SysLibs);
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
    _deltaTime = fDeltaTime;
    _fps = 60.0f;
}

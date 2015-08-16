#ifndef __UNIVERSE_H__
#define __UNIVERSE_H__

struct lua_State;

int luaopen_universe(lua_State* L);
int luaopen_system(lua_State* L);
int universe_deltaTime(lua_State* L);
int universe_fps(lua_State* L);
int system_user(lua_State* L);

class UniverseScript
{
public:
    UniverseScript();
    ~UniverseScript();
    
    void Update(const float fDeltaTime);
    
private:
};

#endif // __UNIVERSE_H__
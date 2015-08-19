/*
     File: NBodySimulationRandom.mm
 Abstract: 
 Functor for generating random data sets for the cpu or gpu bound simulator.
 
  Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import <fstream>
#import <iostream>

#import <sys/time.h>


#import "GLMSizes.h"
#import "GLMVector3.h"

#import "NBodySimulationRandom.h"

#include "universe.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Constants

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long int u64;
typedef char i8;
typedef short i16;
typedef int i32;
typedef long int i64;

typedef GLM::Vector3 Vec3;

static const GLchar *kGalaxyDataFiles[] =
{
    "bodies_16k.dat",
    "bodies_24k.dat",
    "bodies_32k.dat",
    "bodies_64k.dat",
    "bodies_80k.dat",
};

//static const GLfloat kBodyCountScale = 1.0f / 16384.0f;
static const GLfloat kBodyCountScale = 1.0f / 32768.0f;

lua_State* gLua = nullptr;
UniverseScript* universeScript = nullptr;

float gScale;
float gVScale;
float* gPoints;
float* gVelocities;
unsigned int gParticleCount;

template<class T>
T nextRange(T min, T max)
{
    return (GLfloat(rand()/(GLfloat)RAND_MAX) * (max - min)) + min;
}

void placeParticle(GLfloat*& pPosition, GLfloat*& pVelocity, GLfloat minRadius, GLfloat maxRadius, GLfloat vscale, const Vec3& center)
{
    GLM::Vector3 point = GLM::Vector3::unit();
    //point = GLM::normalize(point);
    
    GLfloat scalar = nextRange(minRadius, maxRadius);

    GLM::Vector3 position = point * scalar;
    
    *pPosition++ = position.x + center.x;
    *pPosition++ = position.y + center.y;
    *pPosition++ = position.z + center.z;
    *pPosition++ = 1.0f;//ftcscale;
    
    GLM::Vector3 axis = GLM::Vector3(false);
    axis = GLM::normalize(axis);
    GLfloat dot  = GLM::dot(point, axis);
    
    if((1.0f - dot) < 1e-6)
    {
        axis.x = point.y;
        axis.y = point.x;
        
        axis = GLM::normalize(axis);
    } // if
    
    
    GLM::Vector3 velocity = position;
    velocity = GLM::cross(velocity, axis);
    velocity = GLM::scale(vscale, velocity);

    *pVelocity++ = velocity.x;
    *pVelocity++ = velocity.y;
    *pVelocity++ = velocity.z;
    *pVelocity++ = 1.0f;//fvcscale;
}

void placeStuff(size_t totalBodies, int numerator, int divisor, int& i, GLfloat*& pPosition, GLfloat*& pVelocity, GLfloat inner, GLfloat outer, GLfloat ftcscale, GLfloat fvcscale, GLfloat vscale, GLfloat ox, GLfloat oy, GLfloat oz, GLfloat alpha)
{
    while(i <  numerator * totalBodies / divisor)
    {
        GLM::Vector3 point = GLM::Vector3::unit();
        //point = GLM::normalize(point);
        
        GLfloat scalar = nextRange(inner, outer);
        //std::cout << "scalar: " << scalar << std::endl;
        GLM::Vector3 position = point * scalar;
        
        *pPosition++ = position.x + ox;
        *pPosition++ = position.y + oy;
        *pPosition++ = position.z + oz;
        *pPosition++ = ftcscale;
        //pPosition += 4;
        
        GLM::Vector3 axis = GLM::Vector3(false);
        axis = GLM::normalize(axis);
        GLfloat dot  = GLM::dot(point, axis);
        
        if((1.0f - dot) < 1e-6)
        {
            axis.x = point.y;
            axis.y = point.x;
            
            axis = GLM::normalize(axis);
        } // if
        
        
        GLM::Vector3 velocity = position;
        velocity = GLM::cross(velocity, axis);
        velocity = GLM::scale(vscale, velocity);
        
        /*
        GLM::Vector3 velocity = GLM::Vector3(-ox, abs(ox) * sinf(alpha), 0.0f);//position;
        //velocity = GLM::cross(velocity, axis);
        velocity = GLM::scale(vscale, velocity);
        */
        
        *pVelocity++ = velocity.x;
        *pVelocity++ = velocity.y;
        *pVelocity++ = velocity.z;
        *pVelocity++ = fvcscale;
        //pVelocity += 4;
        
        i++;
    } // while
}

#pragma mark -
#pragma mark Private - Utilities

void Data::Random::makeShell(GLfloat *pPosition, GLfloat *pVelocity, GLfloat ftcscale, GLfloat fvcscale)
{
    GLfloat scale  = m_Scale[0];
    GLfloat vscale = scale * m_Scale[1];
    GLfloat inner  = 2.5f * scale;
    GLfloat outer  = 4.0f * scale;
    
    GLint p = 0;
    GLint v = 0;
    GLint i = 0;
    
    GLfloat dot = 0.0f;
    GLfloat len = 0.0f;
    
    GLM::Vector3 point;
    GLM::Vector3 position;
    GLM::Vector3 velocity;
    GLM::Vector3 axis;
    
    while(i < mnBodies)
    {
        point = GLM::Vector3(true);
        len   = GLM::norm(point);
        point = GLM::normalize(point);
        
        if(len > 1)
        {
            continue;
        } // if
        
        position = GLM::Vector3(false);
        position = GLM::scale((outer - inner), position);
        position = GLM::translate(inner, position);
        position = point * position;
        
        pPosition[p++] = position.x;
        pPosition[p++] = position.y;
        pPosition[p++] = position.z;
        pPosition[p++] = ftcscale;
        
        axis = GLM::Vector3(0.0f, 0.0f, 1.0f);
        axis = GLM::normalize(axis);
        dot  = GLM::dot(point, axis);
        
        if((1.0f - dot) < 1e-6)
        {
            axis.x = point.y;
            axis.y = point.x;
            
            axis = GLM::normalize(axis);
        } // if
        
        velocity = position;
        velocity = GLM::cross(velocity, axis);
        velocity = GLM::scale(vscale, velocity);
        
        pVelocity[v++] = velocity.x;
        pVelocity[v++] = velocity.y;
        pVelocity[v++] = velocity.z;
        pVelocity[v++] = fvcscale;
        
        i++;
    } // while
}

void Data::Random::makeShell2(GLfloat *pPosition, GLfloat *pVelocity, GLfloat ftcscale, GLfloat fvcscale)
{
    timeval tp;
    gettimeofday(&tp, nullptr);
    int seed = tp.tv_usec;
    std::cout << "Seed: " << seed << std::endl;
    srand(seed);

    
    GLfloat scale  = m_Scale[0];
    GLfloat vscale = m_Scale[1];
    GLfloat inner  = 2.5f * scale;
    GLfloat outer  = 4.0f * scale;
    std::cout << "range(" << inner << ", " << outer << ")" << std::endl;
    GLint p = 0;
    GLint v = 0;
    GLint i = 0;
    
    GLfloat dot = 0.0f;
    
    GLM::Vector3 point;
    GLM::Vector3 position;
    GLM::Vector3 velocity;
    GLM::Vector3 axis;
    
    while(i < mnBodies)
    {
        point = GLM::Vector3::unit();
        
        GLfloat scalar = nextRange(inner, outer);
        position = point * scalar;
        
        pPosition[p++] = position.x;
        pPosition[p++] = position.y;
        pPosition[p++] = position.z;
        pPosition[p++] = ftcscale;
        
        axis = GLM::Vector3(false);
        axis = GLM::normalize(axis);
        dot  = GLM::dot(point, axis);
        
        if((1.0f - dot) < 1e-6)
        {
            axis.x = point.y;
            axis.y = point.x;
            
            axis = GLM::normalize(axis);
        } // if
        
        velocity = position;
        velocity = GLM::cross(velocity, axis);
        velocity = GLM::scale(vscale, velocity);
        
        pVelocity[v++] = velocity.x;
        pVelocity[v++] = velocity.y;
        pVelocity[v++] = velocity.z;
        pVelocity[v++] = fvcscale;
        
        i++;
    } // while
}


void Data::Random::makeSphereNest(GLfloat* pPosition, GLfloat* pVelocity, GLfloat ftcscale, GLfloat ftvscale, Data::LayoutVector& layout, unsigned short entropy)
{
    for (int i = 0; i < layout.size(); ++i)
    {
        GLfloat inner = (i == 0)
            ? 0.0f
            : layout[i - 1].radius;
        GLfloat outer = layout[i].radius;
        
        GLM::Vector3 point = GLM::Vector3::unit();
        GLfloat scalar = nextRange(inner, outer);

        GLM::Vector3 position = point * scalar;
        
        makeLayeredShells(pPosition, pVelocity, ftcscale, ftvscale);
    }
}

void makeBang(GLfloat* pPosition, GLfloat* pVelocity, GLfloat minRadius, GLfloat maxRadius, GLfloat ftcscale, GLfloat ftvcscale, u32 numParticles, const Vec3 center)
{
    if (numParticles == 1) {
        placeParticle(pPosition, pVelocity, 0.0f, 1.0f, ftvcscale, center);
        pPosition += 4;
        pVelocity += 4;
    }
    else {
        u16 numBangs = nextRange((u16)3, (u16)(numParticles < 20 ? 4 : numParticles / 5));
        for (u16 curBang = 0; curBang < numBangs; ++curBang) {
            GLM::Vector3 point = GLM::Vector3::unit();
            //point = GLM::normalize(point);
            
            GLfloat scalar = nextRange(minRadius, maxRadius);
            
            GLM::Vector3 center = point * scalar;
            
            //makeBang(pPosition, pVelocity,
        }
    }
}

// Given: total number of particles, total number of entity layers
// -> layout universe
void Data::Random::bang(GLfloat* pPostion, GLfloat* pVelocity, GLfloat ftcscale, GLfloat ftvcscale)
{
    // Seed the universe random number generator
    timeval tp;
    gettimeofday(&tp, nullptr);
    int seed = 42;//tp.tv_usec;
    std::cout << "Seed: " << seed << std::endl;
    srand(seed);
    
    // Layout core
    
    // Layout layers
    
    u16 minEntityParticleCount = 3;
    //u16 maxEntityParticleCount =
}

void Data::Random::makeLayeredShells(GLfloat *pPosition, GLfloat *pVelocity, GLfloat ftcscale, GLfloat fvcscale)
{
    timeval tp;
    gettimeofday(&tp, nullptr);
    int seed = tp.tv_usec;
    std::cout << "Seed: " << seed << std::endl;
    srand(seed);
    
    
    GLfloat scale  = m_Scale[0];
    GLfloat vscale = m_Scale[1];
    GLfloat inner1  = 0.7125f * scale;
    GLfloat outer1  = scale;
    GLfloat inner2  = outer1 * 1.95f;
    GLfloat outer2  = inner2 + (outer1 - inner1) * 0.25f;
    std::cout << "range1(" << inner1 << ", " << outer1 << ")" << std::endl;
    std::cout << "range2(" << inner2 << ", " << outer2 << ")" << std::endl;
    
    GLint i = 0;
    GLint ox = -5;
    GLint oy = 0;
    GLint oz = 0;
    placeStuff(mnBodies, 1, 14, i, pPosition, pVelocity, inner1, outer1, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/360.0f);
    placeStuff(mnBodies, 7, 16, i, pPosition, pVelocity, inner2, outer2, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/360.0f);
    
    gettimeofday(&tp, nullptr);
    //int seed = tp.tv_usec;
    std::cout << "Seed2: " << seed << std::endl;
    srand(seed);
    
    ox = 5;
    placeStuff(mnBodies, 1, 4, i, pPosition, pVelocity, inner1, outer1, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/36.0f);
    placeStuff(mnBodies, 1, 1, i, pPosition, pVelocity, inner2, outer2, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/360.0f);
    
    /*
    GLint p = 0;
    GLint v = 0;
    GLint i = 0;
    
    GLfloat dot = 0.0f;
    
    GLM::Vector3 point;
    GLM::Vector3 position;
    GLM::Vector3 velocity;
    GLM::Vector3 axis;
    
    while(i < mnBodies / 7)
    {
        point = GLM::Vector3::unit();
        //point = GLM::normalize(point);
        
        GLfloat scalar = nextRange(inner1, outer1);
        //std::cout << "scalar: " << scalar << std::endl;
        position = point * scalar;
        
        pPosition[p++] = position.x;
        pPosition[p++] = position.y;
        pPosition[p++] = position.z;
        pPosition[p++] = ftcscale;
        
        axis = GLM::Vector3(false);
        axis = GLM::normalize(axis);
        dot  = GLM::dot(point, axis);
        
        if((1.0f - dot) < 1e-6)
        {
            axis.x = point.y;
            axis.y = point.x;
            
            axis = GLM::normalize(axis);
        } // if
        
        velocity = position;
        velocity = GLM::cross(velocity, axis);
        velocity = GLM::scale(vscale, velocity);
        
        pVelocity[v++] = velocity.x;
        pVelocity[v++] = velocity.y;
        pVelocity[v++] = velocity.z;
        pVelocity[v++] = fvcscale;
        
        i++;
    } // while
    
    while(i < mnBodies)
    {
        point = GLM::Vector3::unit();
        //point = GLM::normalize(point);
        
        GLfloat scalar = nextRange(inner2, outer2);
        //std::cout << "scalar: " << scalar << std::endl;
        position = point * scalar;
        
        pPosition[p++] = position.x;
        pPosition[p++] = position.y;
        pPosition[p++] = position.z;
        pPosition[p++] = ftcscale;
        
        axis = GLM::Vector3(false);
        axis = GLM::normalize(axis);
        dot  = GLM::dot(point, axis);
        
        if((1.0f - dot) < 1e-6)
        {
            axis.x = point.y;
            axis.y = point.x;
            
            axis = GLM::normalize(axis);
        } // if
        
        velocity = position;
        velocity = GLM::cross(velocity, axis);
        velocity = GLM::scale(vscale, velocity);
        
        pVelocity[v++] = velocity.x;
        pVelocity[v++] = velocity.y;
        pVelocity[v++] = velocity.z;
        pVelocity[v++] = fvcscale * 2.0f;
        
        i++;
    } // while
     */
}


void Data::Random::makeLayeredShells2(GLfloat *pPosition, GLfloat *pVelocity, GLfloat ftcscale, GLfloat fvcscale)
{
    timeval tp;
    gettimeofday(&tp, nullptr);
    int seed = tp.tv_usec;
    std::cout << "Seed: " << seed << std::endl;
    srand(seed);
    
    
    GLfloat scale  = m_Scale[0];
    GLfloat vscale = m_Scale[1];
    GLfloat inner1  = 0.25f * scale;
    GLfloat outer1  = scale;
    //[0.25 * scale, scale]
    GLfloat r1 = outer1 - inner1;
    GLfloat inner2  = outer1 + r1 / 2.0f;
    GLfloat outer2  = inner2 + r1 * scale / 2.0f;
    GLfloat r2 = outer2 - inner2;
    GLfloat inner3  = outer2 + r2  / 2.0f;
    GLfloat outer3  = inner3 + r2 * scale / 2.0f;
    std::cout << "range1(" << inner1 << ", " << outer1 << ")" << std::endl;
    std::cout << "range2(" << inner2 << ", " << outer2 << ")" << std::endl;
    std::cout << "range3(" << inner3 << ", " << outer3 << ")" << std::endl;

    GLint i = 0;
    GLfloat* pos = pPosition + 4;
    GLfloat* vel = pVelocity + 4;
    
    GLfloat ox = outer3 * 1.75f / -2.0f;
    GLfloat oy = 0.0f;
    GLfloat oz = 0.0f;
    placeStuff(mnBodies, 3, 16, i, pPosition, pVelocity, inner1, outer1, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/360.0f);
    placeStuff(mnBodies, 5, 16, i, pPosition, pVelocity, inner2, outer2, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/360.0f);
    placeStuff(mnBodies, 8, 16, i, pPosition, pVelocity, inner3, outer3, ftcscale, fvcscale, vscale, ox, oy, oz, 30.0f/360.0f);
    
    pPosition = pos;
    pVelocity = vel;
    ox = outer3 * 0.75f / 2.0f;
    placeStuff(mnBodies, 11, 16, i, pPosition, pVelocity, inner1, outer1, ftcscale, fvcscale, vscale, ox, oy, oz, -30.0f/360.0f);
    placeStuff(mnBodies, 14, 16, i, pPosition, pVelocity, inner2, outer2, ftcscale, fvcscale, vscale, ox, oy, oz, -30.0f/360.0f);
    placeStuff(mnBodies, 1, 1, i, pPosition, pVelocity, inner3, outer3, ftcscale, fvcscale, vscale, ox, oy, oz, -30.0f/360.0f);
}


void Data::Random::acquire(GLfloat* pPosition,
                           GLfloat* pVelocity)
{
    const GLfloat fcount   = GLfloat(mnBodies);
    const GLfloat fbcscale = fcount / 1024.0f;
    //const GLfloat ftcscale = 16384.0f / fcount;
    const GLfloat ftcscale = 32768.0f / fcount;
    const GLfloat fvcscale = kBodyCountScale * fcount;
    
    switch(mnConfig)
    {
        default:
            
        //case NBody::eConfigShell:
        {
            LayoutVector layoutVector;
            layoutVector.push_back({1.0f, 1.0f});
            layoutVector.push_back({10.0f, 1.0f});
            //makeSphereNest(pPosition, pVelocity, ftcscale, fvcscale, layoutVector, 0);
            makeLayeredShells(pPosition, pVelocity, ftcscale, fvcscale);
            //makeLayeredShells2(pPosition, pVelocity, ftcscale, fvcscale);
            //makeShell2(pPosition, pVelocity, ftcscale, fvcscale);
            //makeShell(pPosition, pVelocity, ftcscale, fvcscale);
        } // NBody::eConfigShell
            
            break;
            
        case NBody::eConfigShell://eConfigLua:
        {
            // set our global points and velocity pointers, etc.
            gPoints = pPosition;
            gVelocities = pVelocity;
            gParticleCount = mnBodies;
            gScale = m_Scale[0];
            gVScale = m_Scale[1];
            
            int loadResult = luaL_loadfilex(gLua,  "/Volumes/SharedTmp/The Thirteenth Floor/Sources/scripts/bang.lua", "rt");
            int callResult;
            const char* message;
            int si;
            switch (loadResult) {
                case LUA_OK:
                    callResult = lua_pcall(gLua, 0, LUA_MULTRET, 0);
                    switch (callResult) {
                        case LUA_OK:
                            std::cout << "Lua script executed sucessfully!" << std::endl;
                            break;
                            
                        case LUA_ERRRUN:
                            si = lua_gettop(gLua);
                            message = lua_tolstring(gLua, si, 0);
                            std::cout << "Lua script failed with error: " << message << std::endl;
                            break;
                            
                        case LUA_ERRMEM:
                            std::cout << "Lua script failed: OUT OF MEMORY" << std::endl;
                            break;
                            
                        case LUA_ERRERR:
                        case LUA_ERRGCMM:
                        default:
                            std::cout << "Unhandled lua error type!";
                            break;
                    }


                    break;
                case LUA_ERRSYNTAX:
                    si = lua_gettop(gLua);
                    message = lua_tolstring(gLua, si, 0);
                    std::cout << "Lua script failed with error: " << message << std::endl;
                    break;
                    break;
                    
                case LUA_ERRMEM:
                    
                    break;
                    
                case LUA_ERRGCMM:
                    
                    break;
                    
                default:
                    break;
            }
        }break;
    } // switch
} // acquire

#pragma mark -
#pragma mark Public - Constructor

Data::Random::Random(const size_t& nBodies,
                     const Params& rParams)
{
    gLua = luaL_newstate();
    
    luaL_openlibs(gLua);

    
    universeScript = new UniverseScript();
    
    luaopen_array(gLua);
    
    mnBodies   = nBodies;
    mnConfig   = rParams.mnConfig;
    m_Scale[0] = rParams.mnClusterScale;
    m_Scale[1] = rParams.mnVelocityScale;
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Data::Random::~Random()
{
    mnBodies   = 0;
    mnConfig   = eConfigRandom;
    m_Scale[0] = 0.0f;
    m_Scale[1] = 0.0f;
} // Destructor

#pragma mark -
#pragma mark Public - Accessor

void Data::Random::setParam(const Params& rParams)
{
    mnConfig   = rParams.mnConfig;
    m_Scale[0] = rParams.mnClusterScale;
    m_Scale[1] = rParams.mnVelocityScale;
} // setParam

#pragma mark -
#pragma mark Public - Operators

bool Data::Random::operator()(GLfloat *pPosition,
                              GLfloat *pVelocity)
{
    bool bSuccess = (pPosition != NULL) && (pVelocity != NULL);
    
    if(bSuccess)
    {
        acquire(pPosition, pVelocity);
    } // if
    
    return bSuccess;
} // operator()

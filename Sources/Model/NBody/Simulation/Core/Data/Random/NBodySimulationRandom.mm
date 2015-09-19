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

#import "CFIFStream.h"
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

lua_State* gLua = nullptr;
UniverseScript* universeScript = nullptr;

float* gPoints;
float* gVelocities;
unsigned int gParticleCount;


#pragma mark -
#pragma mark Private - Utilities

bool Data::Random::acquire(GLfloat* pPosition,
                           GLfloat* pVelocity)
{
    if (!pPosition || !pVelocity)
        return false;
    
    // set our global points and velocity pointers, etc.
    gPoints = pPosition;
    gVelocities = pVelocity;
    gParticleCount = mnBodies;
    
    std::string fullpath;
    CF::IFStreamRef pStream = CF::IFStreamCreate(CFSTR("bang"), CFSTR("lua"), &fullpath);
    
    if(!CF::IFStreamIsValid(pStream))
    {
        std::cout
        << ">> N-body Simulation: "
        << " could not open 'bang.lua'"
        << std::endl;
        return false;
    } // if
    
    size_t sz = CF::IFStreamGetSize(pStream);
    const char *pBuffer = CF::IFStreamGetBuffer(pStream);
    
    // open the script for editing (requires having default app for *.lua files)
    std::string command = "open " + fullpath;
    system(command.c_str());
    
    // load the script into the lua runtime
    int loadResult = luaL_loadbuffer(gLua, pBuffer, sz, "bigbang");
    
    // Release the stream now that script is loaded
    CF::IFStreamRelease(pStream);
    
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
    return true;
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
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Data::Random::~Random()
{
    mnBodies   = 0;
} // Destructor

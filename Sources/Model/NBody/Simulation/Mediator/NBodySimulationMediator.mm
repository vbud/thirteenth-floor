/*
     File: NBodySimulationMediator.mm
 Abstract: 
 A mediator object for managing cpu and gpu bound simulators, along with their labeled-buttons.
 
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

#import <iostream>
#import <thread>

#import <OpenCL/OpenCL.h>
#import <OpenGL/gl.h>

#import "GLMSizes.h"

#import "NBodySimulationMediator.h"
#import "NBodySimulationGPU.h"

static const GLuint kNBodyMaxDeviceCount = 128;

// Get the number of coumpute device counts
static GLuint NBodyGetComputeDeviceCount(const GLint& type)
{
    cl_device_id ids[kNBodyMaxDeviceCount] = {0};
    
    GLuint count = -1;
    
    GLint err = clGetDeviceIDs(NULL, type, kNBodyMaxDeviceCount, ids, &count);
    
    if(err != CL_SUCCESS)
    {
        std::cerr
        << ">> ERROR: NBody Simulation Mediator - Failed acquiring maximum device count!"
        << std::endl;
    } // if
    
    return count;
} // NBodyGetComputeDeviceCount

// Set the current active n-body parameters
void NBody::Simulation::Mediator::setParams(const NBody::Simulation::Params& rParams)
{
    std::memset(&m_Params, 0x0, sizeof(NBody::Simulation::Params));
    
    m_Params = rParams;
} // setParams

// Initialize all instance variables to their default values
void NBody::Simulation::Mediator::setDefaults(const size_t& nBodies)
{
    
    mnBodies = nBodies;
    mnSize   = 4 * mnBodies * GLM::Size::kFloat;
    
    mpPosition = NULL;
    
    mpSimulator    = NULL;
} // setDefaults

// Acquire all simulators
void NBody::Simulation::Mediator::acquire(const NBody::Simulation::Params& rParams)
{
    setParams(rParams);
    
    GLuint nGPUs = NBodyGetComputeDeviceCount(CL_DEVICE_TYPE_GPU);
    
    if(nGPUs > 0)
    {
        mpSimulator = new NBody::Simulation::GPU(mnBodies, rParams, nGPUs - 1);

        if(mpSimulator != NULL)
        {
            mpSimulator->start();
            
            while(!mpSimulator->isAcquired())
            {
                std::this_thread::yield();
            } // while
        } // if
    } // if

} // acquire

// Construct a mediator object for GPUs, or CPU and CPUs
NBody::Simulation::Mediator::Mediator(const NBody::Simulation::Params& rParams,
                                      const GLuint& nCount)
{
    setDefaults(nCount);
    
    acquire(rParams);
} // Constructor

// Delete alll simulators
NBody::Simulation::Mediator::~Mediator()
{
    delete mpSimulator;
    mpSimulator = nullptr;
    
    std::memset(&m_Params, 0x0, sizeof(NBody::Simulation::Params));
} // Destructor

// Check to see if position was acquired
const bool NBody::Simulation::Mediator::hasPosition() const
{
    return mpPosition != NULL;
} // hasPosition

// Pause the current active simulator
void NBody::Simulation::Mediator::pause()
{
    if(mpSimulator != NULL)
    {
        mpSimulator->pause();
    } // if
} // pause

// unpause the current active simulator
void NBody::Simulation::Mediator::unpause()
{
    if(mpSimulator != NULL)
    {
        mpSimulator->unpause();
    } // if
} // unpause

// Get position data
const GLfloat* NBody::Simulation::Mediator::position() const
{
    return mpPosition;
} // position

// Get the current simulator
NBody::Simulation::Base* NBody::Simulation::Mediator::simulator()
{
    return mpSimulator;
} // simulator

// void update position data
void NBody::Simulation::Mediator::update()
{
    GLfloat *pPosition = mpSimulator->data();
    
    if(pPosition != NULL)
    {
        if(mpPosition != NULL)
        {
            free(mpPosition);
        } // if
        
        mpPosition = pPosition;
    } // if
} // update

// Reset all the gpu bound simulators
void NBody::Simulation::Mediator::reset(Params& params)
{
    m_Params = params;
    
    if(mpSimulator != NULL)
    {
        if(mpPosition != NULL)
        {
            free(mpPosition);
            
            mpPosition = NULL;
            
            free(mpSimulator->data());
        } // if
        
        mpSimulator->resetParams(m_Params);
        
        mpSimulator->invalidate(true);
        
        mpSimulator->unpause();
    } // if
} // NBodyResetSimulators

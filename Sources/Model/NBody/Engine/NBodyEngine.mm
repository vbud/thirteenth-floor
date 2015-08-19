/*
     File: NBodyEngine.mm
 Abstract: 
 These methods performs an NBody simulation which calculates a gravity field
 and corresponding velocity and acceleration contributions accumulated
 by each body in the system from every other body.  This example
 also shows how to mitigate computation between all available devices
 including CPU and GPU devices, as well as a hybrid combination of both,
 using separate threads for each simulator.
 
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

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import <OpenGL/gl.h>

#import "GLMConstants.h"
#import "GLMSizes.h"

#import "NBodySimulationDemo.h"

#import "NBodyEngine.h"

#pragma mark -
#pragma mark Private - Utilities - Reset/Restart

void NBody::Engine::reset(const GLuint& index)
{
    setActiveDemo(index);
    mpVisualizer->stopRotation();
    mpVisualizer->setRotationSpeed(0.0f);
    
    mpMediator->reset(m_ActiveParams);
    mpVisualizer->reset(index);
} // reset

void NBody::Engine::restart()
{
    mpVisualizer->setViewRotation(m_RotationPt);
    mpVisualizer->setViewZoom(mnViewDistance);
    mpVisualizer->setViewTime(0.0f);
    mpVisualizer->setIsResetting(true);
    mpVisualizer->stopRotation();
} // restart

#pragma mark -
#pragma mark Private - Utilities - Renderers

void NBody::Engine::renderStars()
{
    const GLfloat* pPosition = mpMediator->position();
    
    mpVisualizer->draw(pPosition);
} // renderStars

void NBody::Engine::renderHUD()
{
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    {

    }
    glDisable(GL_BLEND);
} // renderHUD

void NBody::Engine::render()
{
    mpMediator->update();
    
    glClearColor(mnClearColor, mnClearColor, mnClearColor, 1.0f);
    
    if (mnClearColor > 0.0f)
    {
        mnClearColor -= 0.05f;
    } // if
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    if(!mpMediator->hasPosition())
    {
        if(mbWaitingForData)
        {
            CGLFlushDrawable(CGLGetCurrentContext());
        } // if
    } // if
    else
    {
        mbWaitingForData = false;
        
        glClear(GL_COLOR_BUFFER_BIT);
        
        renderStars();
        //renderHUD();
        
        CGLFlushDrawable(CGLGetCurrentContext());
    } // else
    
    glFinish();
} // render

#pragma mark -
#pragma mark Private - Utilities - Selection

void NBody::Engine::nextDemo()
{
    mnActiveDemo = (mnActiveDemo + 1) % NBody::Simulation::Demo::kParamsCount;
    
    reset(mnActiveDemo);
} // demo

#pragma mark -
#pragma mark Private - Utilities - Swapping

void NBody::Engine::swapVisualizer()
{
    render();
    
    mbWaitingForData = true;
    
    mpVisualizer->reset(mnActiveDemo);
} // swapVisualizer

#pragma mark -
#pragma mark Private - Utilities - Intervals

void NBody::Engine::sync(const bool& doSync)
{
    CGLContextObj pContext = CGLGetCurrentContext();
    
    if(pContext != NULL)
    {
        const GLint sync = GLint(doSync);
        
        CGLSetParameter(CGLGetCurrentContext(),
                        kCGLCPSwapInterval,
                        &sync);
    } // if
} // sync

#pragma mark -
#pragma mark Private - Utilities - Acquires

bool NBody::Engine::simulators(const GLuint& nBodies)
{
    mnBodies = (mbReduce) ? NBody::Bodies::kCount : nBodies;
    
    mpMediator = new NBody::Simulation::Mediator(m_ActiveParams, mnBodies);
    
    
    mpMediator->reset(m_ActiveParams);
    mpVisualizer->reset(mnActiveDemo);
    
    return mpMediator != nullptr;
} // NBodyAcquireSimulators

#pragma mark -
#pragma mark Privale - Utilitie - Demo Selection

void NBody::Engine::setDemo(const GLubyte& nCommand)
{
    GLint demo = (nCommand - '0');
    
    if(demo < NBody::Simulation::Demo::kParamsCount)
    {
        mnActiveDemo = demo;
        
        reset(mnActiveDemo);
    } // if
} // setDemo

#pragma mark -
#pragma mark Public - Constructor

NBody::Engine::Engine(const GLfloat& nStarScale,
                      const GLuint& nActiveDemo)
{
    std::memset(&m_ActiveParams, 0x0, sizeof(NBody::Simulation::Params));
    
    mbReduce          = false;
    mbShowHUD         = true;
    mbWaitingForData  = true;
    mbIsRotating      = true;
    mnActiveDemo      = nActiveDemo;
    m_ActiveParams    = NBody::Simulation::Demo::kParams[mnActiveDemo];
    mnStarScale       = nStarScale;
    mnDockSpeed       = NBody::Defaults::kSpeed;
    mnViewDistance    = 30.0f;
    mnClearColor      = 1.0f;
    mnWidowWidth      = GLsizei(NBody::Window::kWidth);
    mnWidowHeight     = GLsizei(NBody::Window::kHeight);
    m_FrameSz         = CGSizeMake(NBody::Window::kWidth, NBody::Window::kHeight);
    m_DockPt          = CGPointMake(0.0f, (mbShowDock ? GLM::kHalfPi_f : 0.0f));
    m_MousePt         = CGPointMake(0.0f, 0.0f);
    m_RotationPt      = CGPointMake(0.0f, 0.0f);
    m_ButtonRt        = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

NBody::Engine::~Engine()
{
    if(mpVisualizer != NULL)
    {
        delete mpVisualizer;
        
        mpVisualizer = NULL;
    } // if
    
    if(mpMediator != NULL)
    {
        delete mpMediator;
        
        mpMediator = NULL;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Utilities - Finalize

bool NBody::Engine::finalize(const GLuint& nBodies)
{
    bool bSuccess = bool(nBodies);
    
    if(bSuccess)
    {
        sync(true);
        
        mpVisualizer = new NBody::Simulation::Visualizer(nBodies);
        
        bSuccess = mpVisualizer->isValid();
        
        if(bSuccess)
        {
            mpVisualizer->setFrame(m_FrameSz);
            mpVisualizer->setStarScale(mnStarScale);
            mpVisualizer->setStarSize(NBody::Star::kSize);
            mpVisualizer->setRotationChange(NBody::Defaults::kRotationDelta);
            
            bSuccess = simulators(nBodies);
        } // if
    } // if
    
    return bSuccess;
} // finalize

#pragma mark -
#pragma mark Public - Utilities - Draw

void NBody::Engine::draw()
{
    render();
} // draw

#pragma mark -
#pragma mark Public - Utilities - Events

void NBody::Engine::resize(const CGRect& rFrame)
{
    if((rFrame.size.width >= NBody::Window::kWidth) && (rFrame.size.height >= NBody::Window::kHeight))
    {
        mnWidowWidth  = GLint(rFrame.size.width + 0.5f);
        mnWidowHeight = GLint(rFrame.size.height + 0.5f);
        
        m_FrameSz = rFrame.size;
        
        m_ButtonRt = CGRectMake(0.75f * m_FrameSz.width - 0.5f * NBody::Button::kWidth,
                                NBody::Button::kSpacing,
                                NBody::Button::kWidth,
                                NBody::Button::kHeight);
        
        if(mpVisualizer != NULL)
        {
            mpVisualizer->setFrame(m_FrameSz);
        } // if
    } // if
} // Resize

void NBody::Engine::run(const GLubyte& nCommand)
{
    switch(nCommand)
    {
        case 'e':
            mpVisualizer->toggleEarthView();
            break;
            
        case 'r':
            mpVisualizer->toggleRotation();
            break;
            
        case 'R':
            restart();
            break;
            
        case 'n':
            nextDemo();
            break;
            
        case '0': // galaxy
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            setDemo(nCommand);
            break;
            
        case 'd':
            mbShowDock = !mbShowDock;
            break;
            
        case 'g':
            swapVisualizer();
            break;
    } // switch
} // run

void NBody::Engine::move(const CGPoint& point)
{
    if(mbIsRotating)
    {
        m_RotationPt.x += (point.x - m_MousePt.x) * 0.2f;
        m_RotationPt.y += (point.y - m_MousePt.y) * 0.2f;
        
        mpVisualizer->setRotation(m_RotationPt);
        
        m_MousePt.x = point.x;
        m_MousePt.y = point.y;
    } // if
} // move

void NBody::Engine::click(const GLint& nState,
                          const CGPoint& point)
{
 
} // click

void NBody::Engine::scroll(const GLfloat& nDelta)
{
    mpVisualizer->setViewDistance(nDelta);
} // scroll

#pragma mark -
#pragma mark Public - Accessors

void NBody::Engine::setActiveDemo(const GLuint& nActiveDemo)
{
    mnActiveDemo   = nActiveDemo;
    m_ActiveParams = NBody::Simulation::Demo::kParams[mnActiveDemo];
} // setActiveDemo

void NBody::Engine::setFrame(const CGRect& rFrame)
{
    if((rFrame.size.width >= NBody::Window::kWidth) && (rFrame.size.height >= NBody::Window::kHeight))
    {
        mnWidowWidth  = GLint(rFrame.size.width + 0.5f);
        mnWidowHeight = GLint(rFrame.size.height + 0.5f);
        
        m_FrameSz = rFrame.size;
        
        m_ButtonRt = CGRectMake(0.75f * m_FrameSz.width - 0.5f * NBody::Button::kWidth,
                                NBody::Button::kSpacing,
                                NBody::Button::kWidth,
                                NBody::Button::kHeight);
    } // if
} // setFrame

void NBody::Engine::setToReduce(const bool& bReduce)
{
    mbReduce = bReduce;
} // setToReduce

void NBody::Engine::setShowHUD(const bool& bShow)
{
    mbShowHUD     = bShow;
    mnHudPosition = mbShowHUD ? GLM::kHalfPi_f : 0.0f;
} // setShowHUD

void NBody::Engine::setClearColor(const GLfloat& nColor)
{
    mnClearColor = nColor;
} // setClearColor

void NBody::Engine::setDockSpeed(const GLfloat& nSpeed)
{
    mnDockSpeed = nSpeed;
} // setDockSpeed

void NBody::Engine::setViewDistance(const GLfloat& nDistance)
{
    mnViewDistance = nDistance;
} // setViewDistance

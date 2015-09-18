/*
     File: NBodySimulationDemo.h
 Abstract: 
 Baseline NBody demo simulation parameters.
 
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

#ifndef _NBODY_DEMO_PARAMETERS_H_
#define _NBODY_DEMO_PARAMETERS_H_

#import <OpenGL/OpenGL.h>

#import "NBodySimulationTypes.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Demo
        {
            static const Params kParams[] =
            {
                // time step,       softening,      damping,        point size scale,
                // x-rotation,      y-rotation ,    view distance
                
                {
                    0.005f,         0.0921f,        0.93f,          0.9f,
                    90.0f,          20.0f,          25.0f
                },
                
                {
                    0.003f,         0.1221f,        0.93f,          0.9f,
                    90.0f,          20.0f,          15.0f
                },
                
                {
                    0.005f,         0.30f,          0.40f,          0.18f,
                    90.0f,          0.0f,           9.0f
                },
                
                {
                    0.016f,         0.1f,           1.0f,           1.2f,
                    39.0f,          2.0f,           50.0f
                },
                
                {
                    0.0006f,        1.0f,           1.0f,           0.15f,
                    90.0f,          10.0f,          5.0f
                },
                
                {
                    0.0016f,        0.145f,         1.0f,           0.1f,
                    90.0f,          0.0f,           4.15f
                },
                
                {
                    0.016f,         0.15f,          1.0f,            1.0f,
                    90.0f,          0.0f,           50.0f
                },
                
                {
                    0.008f,         0.09f,          0.89f,          1.2f,
                    90.0f,          2.0f,           30.0f
                },
                
                {
                    0.005f,         0.0921f,        0.93f,          5.1f,
                    90.0f,          20.0f,          25.0f
                },
                
                {
                    0.0021f,        0.002215462f,   0.97f,          1.2f,
                    90.0f,          0.0f,           30.0f
                }
                
            };
            
  
            static const GLint kParamsCount = sizeof(kParams) / sizeof(Params);
        } // Demo
    } // Simulation
} // NBody

#endif

#endif

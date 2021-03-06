/*
     File: GLUTransforms.mm
 Abstract: 
 Utility methods for generating OpenGL linear transformations.
 
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

#import <OpenGL/gl.h>

#import "GLMMatrix4.h"
#import "GLMTransforms.h"

#import "GLUTransforms.h"

void GLU::Scale(const GLfloat& x,
                const GLfloat& y,
                const GLfloat& z)
{
    GLM::Matrix4 scale = GLM::scale(x, y, z);
    
    glLoadMatrixf(scale.m);
} // GLU::Scale

void GLU::Scale(const GLM::Vector3& s)
{
    GLM::Matrix4 scale = GLM::scale(s.x, s.y, s.z);
    
    glLoadMatrixf(scale.m);
} // GLU::Scale

void GLU::Translate(const GLfloat& x,
                    const GLfloat& y,
                    const GLfloat& z)
{
    GLM::Matrix4 translate = GLM::translate(x, y, z);
    
    glLoadMatrixf(translate.m);
} // GLU::Scale

void GLU::Translate(const GLM::Vector3& t)
{
    GLM::Matrix4 translate = GLM::translate(t.x, t.y, t.z);
    
    glLoadMatrixf(translate.m);
} // GLU::Scale

void GLU::Rotate(const GLfloat& angle,
                 const GLfloat& x,
                 const GLfloat& y,
                 const GLfloat& z)
{
    GLM::Matrix4 rotate = GLM::rotate(angle, x, y, z);
    
    glLoadMatrixf(rotate.m);
} // GLU::Rotate

void GLU::Rotate(const GLfloat& angle,
                 const GLM::Vector3& r)
{
    GLM::Matrix4 rotate = GLM::rotate(angle, r);
    
    glLoadMatrixf(rotate.m);
} // GLU::Rotate

void GLU::Frustum(const GLfloat& left,
                  const GLfloat& right,
                  const GLfloat& bottom,
                  const GLfloat& top,
                  const GLfloat& near,
                  const GLfloat& far)
{
    GLM::Matrix4 frustum = GLM::frustum(left, right, bottom, top, near, far);
    
    glLoadMatrixf(frustum.m);
} // GLU::Frustum

void GLU::Frustum(const GLfloat& angle,
                  const GLfloat& width,
                  const GLfloat& heigth,
                  const GLfloat& near,
                  const GLfloat& far)
{
    GLM::Matrix4 frustum = GLM::frustum(angle, width, heigth, near, far);
    
    glLoadMatrixf(frustum.m);
} // // GLU::Frustum

void GLU::Frustum(const GLfloat& angle,
                  const GLfloat& aspect,
                  const GLfloat& near,
                  const GLfloat& far)
{
    GLM::Matrix4 frustum = GLM::frustum(angle, aspect, near, far);
    
    glLoadMatrixf(frustum.m);
} // // GLU::Frustum

void GLU::Frustum(const GLM::Vector3& near,
                  const GLM::Vector3& far)
{
    GLM::Matrix4 frustum = GLM::frustum(near, far);
    
    glLoadMatrixf(frustum.m);
} // GLU::Frustum

void GLU::LookAt(const GLfloat * const pEye,
                 const GLfloat * const pCenter,
                 const GLfloat * const pUp)
{
    GLM::Matrix4 lookAt = GLM::lookAt(pEye, pCenter, pUp);
    
    glLoadMatrixf(lookAt.m);
} // GLU::LookAt

void GLU::LookAt(const GLM::Vector3& eye,
                 const GLM::Vector3& center,
                 const GLM::Vector3& up)
{
    GLM::Matrix4 lookAt = GLM::lookAt(eye, center, up);
    
    glLoadMatrixf(lookAt.m);
} // GLU::LookAt

void GLU::Perspective(const GLfloat& fovy,
                      const GLfloat& aspect,
                      const GLfloat& near,
                      const GLfloat& far)
{
    GLM::Matrix4 perspective = GLM::perspective(fovy, aspect, near, far);
    
    glLoadMatrixf(perspective.m);
} // GLU::Perspective

void GLU::Perspective(const GLfloat& fovy,
                      const GLfloat& width,
                      const GLfloat& height,
                      const GLfloat& near,
                      const GLfloat& far)
{
    GLM::Matrix4 perspective = GLM::perspective(fovy, width, height, near, far);
    
    glLoadMatrixf(perspective.m);
} // GLU::Perspective

void GLU::Ortho(const GLfloat& left,
                const GLfloat& right,
                const GLfloat& bottom,
                const GLfloat& top,
                const GLfloat& near,
                const GLfloat& far)
{
    GLM::Matrix4 ortho = GLM::ortho(left, right, bottom, top, near, far);
    
    glLoadMatrixf(ortho.m);
} // GLU::Ortho

void GLU::Ortho(const GLM::Vector3& origin,
                const GLM::Vector3& size)
{
    GLM::Matrix4 ortho = GLM::ortho(origin, size);
    
    glLoadMatrixf(ortho.m);
} // GLU::Ortho


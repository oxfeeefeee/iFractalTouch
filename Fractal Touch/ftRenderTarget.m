//
//  ftRenderTarget.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ISTUtility.h"
#import "ftRenderTarget.h"
#import "ISTHandMadeUIImage.h"

@interface ftRenderTarget()

@property (nonatomic, assign) GLuint fbo;
@property (nonatomic, assign) GLuint previousFbo;
@property (nonatomic, assign) CGSize size;

@end

@implementation ftRenderTarget
@synthesize textureName = mTextureName;
@synthesize fbo = mFbo;
@synthesize previousFbo = mPreviousFbo;
@synthesize size = mSize;


- (ftRenderTarget*)initWithSize:(CGSize)size
{
    if(self = [self init]){
        mSize = size;
        glGenTextures(1, &mTextureName);
        glBindTexture(GL_TEXTURE_2D, mTextureName);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, size.width, size.height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, NULL);
        
        glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint*)&mPreviousFbo);
        glGenFramebuffersOES(1, &mFbo);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFbo);
        // attach renderbuffer
        glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, mTextureName, 0);
        // unbind frame buffer
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, mPreviousFbo);
        mPreviousFbo = 0;
    }
    return self;
}

- (void)dealloc
{
    glDeleteFramebuffers(1, &mFbo);
    glDeleteTextures(1, &mTextureName);
}

- (void) applyRenderTarget
{
    glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint*)&mPreviousFbo);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mFbo);
}

- (void) restorePreviousRenderTarget
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mPreviousFbo);
}

- (ISTHandMadeUIImage*) getResultAsUIImage
{
    ISTHandMadeUIImage* image = [[ISTHandMadeUIImage alloc]initWithSize:mSize];
    glReadPixels(0, 0, mSize.width, mSize.height, GL_RGBA, GL_UNSIGNED_BYTE, image.buffer);
    return image;
}

@end

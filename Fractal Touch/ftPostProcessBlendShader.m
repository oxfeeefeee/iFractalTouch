//
//  ftPostProcessBlend.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ftPostProcessBlendShader.h"

@interface ftPostProcessBlendShader()

@property (nonatomic, strong) ISTShader* shader;
@property (nonatomic, assign) GLint mvpMatUniform;
@property (nonatomic, assign) GLint textureUniform;
@property (nonatomic, assign) GLint blendTextureUniform;

@end


@implementation ftPostProcessBlendShader

@synthesize shader = mShader;
@synthesize textureName = mTextureName;
@synthesize mvpMatUniform = mMvpMatUniform;
@synthesize textureUniform = mTextureUniform;
@synthesize blendTextureUniform = mBlendTextureUniform;
@synthesize blendTexture = mBlendTexture;
@synthesize mvpMatrix = mMvpMatrix;

static NSString *sVSFileName = @"blendImage"; 
static NSString *sPSFileName = @"blendImage";
static ftPostProcessBlendShader *sInstance = NULL;

+ (ftPostProcessBlendShader *)instance
{
    @synchronized(self)
    {
        if (sInstance == NULL){
            sInstance = [[self alloc] init];
        }
    }
    return(sInstance);
}

+ (void)releaseInstance
{
    sInstance = NULL;
}

- (ftPostProcessBlendShader*)init
{
    if(self = [super init])
    {
        mShader = [[ISTShader alloc]init];
        mShader.delegate = self;
        [self.shader loadShaderVS:sVSFileName andPS:sPSFileName];
    }
    return self;
}

- (void)setMvpMatrix:(GLKMatrix4)mvpMatrix
{
    mMvpMatrix = mvpMatrix;
}

- (void)bindAttributeLocations
{
    glBindAttribLocation(self.shader.program, ISTVertexAttribPosition, "position");
    glBindAttribLocation(self.shader.program, ISTVertexAttribTexCoord0, "texCoords0");
    glBindAttribLocation(self.shader.program, ISTVertexAttribTexCoord1, "texCoords1");
}

- (void)getUniformLocations
{
    mMvpMatUniform = glGetUniformLocation(self.shader.program, "mvpMatrix");
    mTextureUniform = glGetUniformLocation(self.shader.program, "texture");
    mBlendTextureUniform = glGetUniformLocation(self.shader.program, "blendTexture");
}

- (void)applyShader
{
    [self.shader applyShader];
}

- (void)updateUniforms
{
    glUniformMatrix4fv(mMvpMatUniform, 1, 0, mMvpMatrix.m);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mTextureName);
    glUniform1i(mTextureUniform, 0);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, mBlendTexture);
    glUniform1i(mBlendTextureUniform, 1);
}

@end


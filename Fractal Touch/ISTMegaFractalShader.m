//
//  ISTMegaFractalShader.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-2-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTMegaFractalShader.h"

@interface ISTMegaFractalShader()

@property (nonatomic, strong) ISTShader* shader;
@property (nonatomic, assign) GLint mvpMatUniform;
@property (nonatomic, assign) GLint textureUniform;

@end


@implementation ISTMegaFractalShader

@synthesize shader = mShader;
@synthesize textureName = mTextureName;
@synthesize mvpMatUniform = mMvpMatUniform;
@synthesize textureUniform = mTextureUniform;
@synthesize mvpMatrix = mMvpMatrix;

static NSString *sVSFileName = @"megaFractal"; // @"renderImage";//
static NSString *sPSFileName = @"megaFractal";
static ISTMegaFractalShader *sInstance = NULL;

+ (ISTMegaFractalShader *)instance
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

- (ISTMegaFractalShader*)init
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
    glBindAttribLocation(self.shader.program, ISTVertexAttribTexCoord0, "texCoords");
}

- (void)getUniformLocations
{
    mMvpMatUniform = glGetUniformLocation(self.shader.program, "mvpMatrix");
    mTextureUniform = glGetUniformLocation(self.shader.program, "texture");
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
}

@end

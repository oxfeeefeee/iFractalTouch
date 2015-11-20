//
//  ftPostProcessImage.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ftPostProcessImage.h"
#import "ftPostProcessBlendShader.h"
#import "ISTUtility.h"

@interface ftPostProcessImage()

@property (nonatomic, readonly, strong) ftPostProcessBlendShader* ppShader;

@end

@implementation ftPostProcessImage
@synthesize textureName = mTextureName;
@synthesize blendTextureName = mBlendTextureName;

- (ftPostProcessBlendShader*)ppShader
{
    return [ftPostProcessBlendShader instance];
}

- (ftPostProcessImage*)initWithFrame:(CGRect)frame andBlendingTextureUV:(CGPoint)uv
{
    if(self = [super init]){
        [self setupGeometry:uv];
        self.frame = frame;
        mTextureName = 0;
        mBlendTextureName = 0;
    }
    return self;
}

- (ftPostProcessImage*)initWithFrame:(CGRect)frame andTextureName:(GLuint)textureName andBlendingTextureUV:(CGPoint)uv
{
    if(self = [super init]){
        [self setupGeometry:uv];
        self.frame = frame;
        mTextureName = textureName;
        mBlendTextureName = 0;
    }
    return self;
}

- (void)setupGeometry: (CGPoint)blendingTexureUV
{
    GLfloat squareVertices[] = {
        -0.5f, -0.5f, 1.0f, 1.0f, blendingTexureUV.x, blendingTexureUV.y,
        0.5f,  -0.5f, 0.0f, 1.0f, 0.0f, blendingTexureUV.y,
        -0.5f,  0.5f, 1.0f, 0.0f, blendingTexureUV.x, 0.0f,
        
        0.5f,   0.5f, 0.0f, 0.0f, 0.0f, 0.0f,
        -0.5f,  0.5f, 1.0f, 0.0f, blendingTexureUV.x, 0.0f,
        0.5f,  -0.5f, 0.0f, 1.0f, 0.0f, blendingTexureUV.y,
    };
    /*const GLfloat squareVertices[] = {
        -0.5f, -0.5f, 1.0f, 1.0f, 8.0f, 8.0f,
        0.5f,  -0.5f, 0.0f, 1.0f, 0.0f, 8.0f,
        -0.5f,  0.5f, 1.0f, 0.0f, 8.0f, 0.0f,
        
        0.5f,   0.5f, 0.0f, 0.0f, 0.0f, 0.0f,
        -0.5f,  0.5f, 1.0f, 0.0f, 8.0f, 0.0f,
        0.5f,  -0.5f, 0.0f, 1.0f, 0.0f, 8.0f,
    };*/
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertices), squareVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(ISTVertexAttribPosition);
    glVertexAttribPointer(ISTVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(ISTVertexAttribTexCoord0);
    glVertexAttribPointer(ISTVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(8));
    glEnableVertexAttribArray(ISTVertexAttribTexCoord1);
    glVertexAttribPointer(ISTVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(16));
    
    glBindVertexArrayOES(0);
}

- (void)setParametersToShader: (GLKMatrix4*) mat
{
    [self.ppShader applyShader];
    self.ppShader.textureName = self.textureName;
    self.ppShader.blendTexture = mBlendTextureName;
    self.ppShader.mvpMatrix = *mat;
    [self.ppShader updateUniforms];
}

@end

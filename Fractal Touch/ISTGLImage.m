//
//  ISTGLButton.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTGLImage.h"
#import "ISTDrawImageShader.h"
#import "ISTUtility.h"


@interface ISTGLImage()

@property (nonatomic, readonly, strong) ISTDrawImageShader* shader;
@property (nonatomic, readonly, assign) GLuint vao;
@property (nonatomic, readonly, assign) GLuint vbo;

- (void)setupGeometry;

@end


@implementation ISTGLImage

@synthesize frame = mFrame;
@synthesize texture = mTexture;
@synthesize shader = mShader;
@synthesize vao = mVao;
@synthesize vbo = mVbo;

- (void)setFrame:(CGRect)frame
{
    mFrame = frame;
}

- (void)setTexture:(GLKTextureInfo *)texture
{
    self.shader.textureName = texture.name;
    mTexture = texture;
}

- (ISTDrawImageShader*)shader
{
    return [ISTDrawImageShader instance];
}

- (ISTGLImage*)init
{
    if(self = [super init]){
        [self prepareVao];
        mTexture = nil;
    }
    return self;
}

- (ISTGLImage*)initWithOrigin:(CGPoint)origin andResourcePath:(NSString*)path ofType:(NSString*)type
{
    CGRect frame;
    GLKTextureInfo *texture = [ISTUtility loadTextureWithPath:path ofType:type];
    if ([ISTUtility isRetina]) {
        frame = CGRectMake(origin.x, origin.y, texture.width * 0.5, texture.height * 0.5);
    }else{
        frame = CGRectMake(origin.x, origin.y, texture.width, texture.height);
    }
    return [self initWithFrame:frame andTexture:texture];
}

- (ISTGLImage*)initWithFrame:(CGRect)frame andTexture:(GLKTextureInfo*)texture
{
    if(self = [self init]){
        self.frame = frame;
        self.texture = texture;
        [self setupGeometry];
    }
    return self;
}

- (ISTGLImage*)initWithOrigin:(CGPoint)origin andImage:(CGImageRef)image
{
    NSError *error = nil;
    GLKTextureInfo *texture = [GLKTextureLoader textureWithCGImage:image options:nil error:&error];
    if (error) {
        NSLog(@"Error loading texture!%@", error);
    }
    CGRect frame = CGRectMake(origin.x, origin.y, texture.width*0.5f, texture.height*0.5f);
    return [self initWithFrame:frame andTexture:texture];
}

- (void)prepareVao
{
    glGenVertexArraysOES(1, &mVao);
    glBindVertexArrayOES(mVao);
    glGenBuffers(1, &mVbo);
    glBindBuffer(GL_ARRAY_BUFFER, mVbo); 
}

- (void)setupGeometry
{
    const GLfloat squareVertices[] = {
        -0.5f, -0.5f, 1.0f, 1.0f,
        0.5f,  -0.5f, 0.0f, 1.0f,
        -0.5f,  0.5f, 1.0f, 0.0f,
        
        0.5f,   0.5f, 0.0f, 0.0f,
        -0.5f,  0.5f, 1.0f, 0.0f,
        0.5f,  -0.5f, 0.0f, 1.0f,
    };

    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertices), squareVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(ISTVertexAttribPosition);
    glVertexAttribPointer(ISTVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(ISTVertexAttribTexCoord0);
    glVertexAttribPointer(ISTVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(8));
    
    glBindVertexArrayOES(0);
}

- (void)setParametersToShader: (GLKMatrix4*) mat
{
    self.shader.textureName = self.texture.name; 
    self.shader.mvpMatrix = *mat;
    [self.shader applyShader];
    [self.shader updateUniforms];
}

- (void)draw
{
    glBindVertexArrayOES(mVao);
    //note we need to map (0,0) to (-1, -1)
    
    float halfW = mFrame.size.width * 0.5f;
    float halfH = mFrame.size.height * 0.5f;
    float centerX = mFrame.origin.x + halfW;
    float centerY = mFrame.origin.y + halfH;
    
    float screenWidth = [ISTUtility screenWidth];
    float screenHeight = [ISTUtility screenHeight];
    
    float x = 1.0f / mFrame.size.width;
    float y = 1.0f / mFrame.size.height;
    
    GLKMatrix4 mat = GLKMatrix4MakeOrtho((centerX)*x, (centerX-screenWidth)*x, -(centerY-screenHeight)*y, -(centerY)*y, -1.0, 1.0);
    [self setParametersToShader:(&mat)];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void) dealloc
{
    glDeleteBuffers(1, &mVbo);
    glDeleteVertexArraysOES(1, &mVao);
}

@end

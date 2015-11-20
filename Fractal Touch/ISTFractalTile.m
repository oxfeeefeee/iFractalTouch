//
//  ISTFractalTile.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTFractalTile.h"
#import "ISTMegaFractalShader.h"
#import "ISTUtility.h"
#import "FractalSRCalc.h"
#import "ISTColorCalculator.h"


#define BUFFER_OFFSET(i) ((char *)NULL + (i))


@interface ISTFractalTile()

@property (nonatomic, assign, readonly) PIXEL_FORMAT* buffer;
@property (nonatomic, assign, readonly) GLuint textureName;

@end


@implementation ISTFractalTile

@synthesize state = mState;
@synthesize buffer = mBuffer;
@synthesize textureName = mTextureName;
@synthesize level = mLevel;
@synthesize coordinateX = mCoordinateX;
@synthesize coordinateY = mCoordinateY;
@synthesize alwaysCache = mAlwaysCache;
@synthesize dummyBarrier = mDummyBarrier;
@synthesize canSkipRendering = mCanSkipRendering;
@synthesize abortComputingFlag = mAbortComputingFlag;
static GLuint smVao;
static GLuint smVbo;

- (ISTFractalTile*)init
{
    if(self = [super init]){
        //todo: better memory managment: use single malloc for all tiles
        void* buffer;
        int num = posix_memalign(&buffer, 64, IST_TILE_SIZE * IST_TILE_SIZE * sizeof(PIXEL_FORMAT));
        if(num != 0){
            mBuffer = 0;
            NSLog(@"OOM creating tile!");
            return nil;
        }else {
            mBuffer = (PIXEL_FORMAT*)buffer;
            mState = ISTTileStateIdle;
            mLevel = mCoordinateX = mCoordinateY = 0;
            
            mTextureName = 0;
        }
        mAlwaysCache = NO;
        mDummyBarrier = NO;
        mCanSkipRendering = NO;
    }
    return self;
}

- (bool)fastIsEqual:(long long*)coordx coordx:(long long*)coordy level:(int)level
{
    return mCoordinateX == *coordx && mCoordinateY == *coordy && mLevel == level;
}

- (BOOL)isEqual:(id)other
{
    ISTFractalTile* buffer = (ISTFractalTile*)other;
    return [buffer fastIsEqual:&mCoordinateX coordx:&mCoordinateY level:mLevel];
}

- (NSUInteger)hash
{
    return (int)((mCoordinateX&0x8000000000000000)|((mCoordinateY>>1)&4000000000000000)|
                 (mCoordinateX&0x3FFC000000000000)|(mCoordinateY&0x0003FFC000000000)) + mLevel; 
}

- (void)compute:(ISTFractalTile*)previousLevelTile tileGenerator:(ISTTileGenerator*)tileGenerator
{
    srCalc(mCoordinateX, mCoordinateY, mLevel, previousLevelTile.coordinateX, previousLevelTile.coordinateY, previousLevelTile.buffer, mBuffer, (__bridge void*)self);
}

- (void)uploadToGpu:(ISTColorCalculator*)colorCalc
{
    assert(!mTextureName);
    [colorCalc updateColorBufferWithData:mBuffer];
    [self unloadFromGpu];
    glGenTextures(1, &mTextureName);
    glBindTexture(GL_TEXTURE_2D, mTextureName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, IST_TILE_SIZE, IST_TILE_SIZE, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, colorCalc.bufferPtr);
}

- (void)unloadFromGpu
{
    glDeleteTextures(1, &mTextureName);
    mTextureName = 0;
}

- (BOOL)isComputed
{
    return mState == ISTTileStateNeedUpload || mState == ISTTileStateReady;
}

- (BOOL)needProcess
{
    return mState == ISTTileStateIdle;
}

- (void)onColorChange:(ISTColorCalculator*) colorCalculator uploadNow:(BOOL)uploadNow
{
    if (mState == ISTTileStateReady) {
        [self unloadFromGpu];
        if (uploadNow) {
            [self uploadToGpu: colorCalculator];
        }else {
            mState = ISTTileStateNeedUpload;
        }
    }
}

- (void)trash
{
    if (mState == ISTTileStateComputing) {
        self.abortComputingFlag = YES;
    }else if (mState == ISTTileStateReady) {
        [self unloadFromGpu];
    }
    mState = ISTTileStateIdle;
}

- (void)releaseBuffer
{
    free(mBuffer);
    mBuffer = 0;
}

- (void)dealloc
{
    [self unloadFromGpu];
    [self releaseBuffer];
}

- (void)drawToMemory:(PIXEL_FORMAT*)ptr sizeX:(int)sizeX sizeY:(int)sizeY locX:(long long)locX locY:(long long)locY xyscale:(double)xyscale level:(int)level
{
    if (![self isComputed]) {
        return;
    }
    
    int levelDiff = level - mLevel;
    double scale = pow(2.0, levelDiff);
    long long intScale = (long long)(scale + 0.01);
    double preview = pow(2.0, level);
    double scaleRatio = preview/xyscale;
    double locxA = (double)(locX>>30);
    double locxB = locX - locxA*(1<<30);
    long long locXMulScaleRatio = 
    (long long)(locxA * scaleRatio * (double)(1<<30)) + (long long)(locxB * scaleRatio);
    double locyA = (double)(locY>>30);
    double locyB = locY - locyA*(1<<30);
    long long locYMulScaleRatio = 
    (long long)(locyA * scaleRatio * (double)(1<<30)) + (long long)(locyB * scaleRatio);
    int x0 = mCoordinateX * IST_TILE_SIZE * intScale + locXMulScaleRatio + sizeX/2;
    int y0 = mCoordinateY * IST_TILE_SIZE * intScale + locYMulScaleRatio + sizeY/2;
    int tileSize = IST_TILE_SIZE * intScale;
    int x1 = x0 + tileSize;
    int y1 = y0 + tileSize;
    int dx0 = 0;
    int dx1 = sizeX;
    int dy0 = 0;
    int dy1 = sizeY;
    int ux0 = MAX(x0, dx0);
    int ux1 = MIN(x1, dx1);
    int uy0 = MAX(y0, dy0);
    int uy1 = MIN(y1, dy1);
    int offsetX = - x0;
    int offsetY = - y0;
    for (int y = uy0; y < uy1; ++y) {
        int rowDiff = sizeX * y;
        int rowDiffSrc = IST_TILE_SIZE * ((y + offsetY)/intScale);
        for (int x = ux0; x < ux1; ++x) {
            ptr[rowDiff+x] = mBuffer[rowDiffSrc + (x + offsetX)/intScale];
        }
    }
}

- (void)drawWithLocX:(long long)locX locY:(long long)locY andScale:(double)scale colcCalc:(ISTColorCalculator*) colorCalculator
{
    if (![self isComputed] || self.canSkipRendering) {
        return;
    }
    
    if (mState == ISTTileStateNeedUpload) {
        if (!colorCalculator) {
            return;
        }
        [self uploadToGpu:colorCalculator];
        mState = ISTTileStateReady;
    }
    
    ISTMegaFractalShader* shader = [ISTMegaFractalShader instance];
    shader.textureName = self.textureName;
    
    double tileSizeInPoint = IST_TILE_SIZE / [ISTUtility screenScale];
    double tileScale = pow(2.0, mLevel);
    double scaleRatio = scale/tileScale;
    float halfSize = (float)(tileSizeInPoint * 0.5 * scaleRatio);
    
    //percision problem!!!
    double ratio = scaleRatio * tileSizeInPoint;
    long long ratioInt = (long long)ratio;
    double rationFloat = ratio - ratioInt;
    float offsetX = (float)((double)(mCoordinateX * ratioInt + locX) + (double)mCoordinateX*rationFloat);
    float offsetY = (float)((double)(mCoordinateY * ratioInt + locY) + (double)mCoordinateY*rationFloat);
    
    //note we need to map (0,0) to (-1, -1)
    float centerX = offsetX + halfSize;
    float centerY = offsetY + halfSize;
    
    float screenWidth = [ISTUtility screenWidth];
    float screenHeight = [ISTUtility screenHeight];
    
    float oneOverSize = 0.5f / halfSize;
    
    GLKMatrix4 mat = GLKMatrix4MakeOrtho((centerX)*oneOverSize,
                                         (centerX-screenWidth)*oneOverSize,
                                         (centerY-screenHeight)*oneOverSize,
                                         (centerY)*oneOverSize, -1.0, 1.0);
    shader.mvpMatrix = mat;
    [shader updateUniforms];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

+ (void)setupGpuResources
{
    const GLfloat squareVertices[] = {
        -0.5f, -0.5f, 1.0f, 1.0f,
        0.5f,  -0.5f, 0.0f, 1.0f,
        -0.5f,  0.5f, 1.0f, 0.0f,
        
        0.5f,   0.5f, 0.0f, 0.0f,
        -0.5f,  0.5f, 1.0f, 0.0f,
        0.5f,  -0.5f, 0.0f, 1.0f,
    };
    glGenVertexArraysOES(1, &smVao);
    glBindVertexArrayOES(smVao);
    
    glGenBuffers(1, &smVbo);
    glBindBuffer(GL_ARRAY_BUFFER, smVbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertices), squareVertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(ISTVertexAttribPosition);
    glVertexAttribPointer(ISTVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(ISTVertexAttribTexCoord0);
    glVertexAttribPointer(ISTVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 16, BUFFER_OFFSET(8));
    
    glBindVertexArrayOES(0);
}

+ (void)realeaseGpuResources
{
    glDeleteBuffers(1, &smVbo);
    glDeleteVertexArraysOES(1, &smVao);
}

+ (void)applyTileCommonState
{
    glDisable(GL_BLEND);
    glDisable(GL_STENCIL_TEST);
    glBindVertexArrayOES(smVao);
    [ISTMegaFractalShader.instance applyShader];
}

@end

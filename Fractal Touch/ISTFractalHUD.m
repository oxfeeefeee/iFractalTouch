//
//  ISTFractalHUD.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTFractalHUD.h"
#import "ISTGLImage.h"
#import "ISTHandMadeUIImage.h"
#import "FractalSRCalc.h"
#import "ISTUtility.h"


@interface ISTFractalHUD()

@property (nonatomic, assign) CGPoint currentLoc;
@property (nonatomic, strong) ISTHandMadeUIImage* locIndicatorBG;
@property (nonatomic, strong) ISTHandMadeUIImage* locIndicatorBG2;
@property (nonatomic, strong) ISTHandMadeUIImage* locIndicator;
@property (nonatomic, strong) ISTHandMadeUIImage* zoomIndicatorBG;
@property (nonatomic, strong) ISTHandMadeUIImage* zoomIndicator;
@property (nonatomic, strong) ISTHandMadeUIImage* dot;
@property (nonatomic, strong) ISTGLImage* glLocIndicatorBG;
@property (nonatomic, strong) ISTGLImage* glLocIndicatorBG2;
@property (nonatomic, strong) ISTGLImage* glLocIndicator;
@property (nonatomic, strong) ISTGLImage* glZoomIndicatorBG;
@property (nonatomic, strong) ISTGLImage* glZoomIndicator;
@property (nonatomic, strong) ISTGLImage* glDot;
@property (nonatomic, strong) ISTGLImage* glCenterButton;

@end


@implementation ISTFractalHUD

@synthesize animating = mAnimating;
@synthesize currentLoc = mCurrentLoc;
@synthesize locIndicatorBG = mLocIndicatorBG;
@synthesize locIndicatorBG2 = mLocIndicatorBG2;
@synthesize locIndicator = mLocIndicator;
@synthesize zoomIndicatorBG = mZoomIndicatorBG;
@synthesize zoomIndicator = mZoomIndicator;
@synthesize dot = mDot;
@synthesize glLocIndicatorBG = mGLLocIndicatorBG;
@synthesize glLocIndicatorBG2 = mGLLocIndicatorBG2;
@synthesize glLocIndicator = mGLLocIndicator;
@synthesize glZoomIndicatorBG = mGLZoomIndicatorBG;
@synthesize glZoomIndicator = mGLZoomIndicator;
@synthesize glDot = mGLDot;
@synthesize glCenterButton = mGLCenterButton;

static int smSizexInPoint = 64;
static int smSizeyInPoint = 64;
static int smCenterX = 321-32;
static int smCenterY = 40;//480+15-48;
static int smIndicatorWidth = 12;
static int smIndicatorHeight = 18;
static int smZoomIndicatorX = 302;
static int smZoomIndicatorBGWidth = 16;
static int smZoomIndicatorBGHeight = 70;
static int smZoomIndicatorBGMargin = 2;
static int smDotSize = 16;
static int smDotToButtom = 25;
static int smDotXLeft = 14;
static int smDotXCenter = 160;
static int smDotXRight = 280;

static CGPoint smOffsets[4];
static float smCounter;
static float smCounterMax = 10.f;
static float smDistance = 8.f;


- (ISTFractalHUD*)init
{
    if(self = [super init])
    {
        [self createLocIndicatorBG];
        [self createLocIndicator];
        [self createZoomIndicatorBG];
        [self createZoomIndicator];
        [self createDot];
    }
    return self;
}

- (void)setAnimating:(BOOL)animating
{
    mAnimating = animating;
}

- (void)createLocIndicatorBG
{
    size_t sizex = smSizexInPoint * 2;
    size_t sizey = smSizeyInPoint * 2;
    mLocIndicatorBG = [[ISTHandMadeUIImage alloc]initWithSize:CGSizeMake(sizex, sizey)];
    mLocIndicatorBG2 = [[ISTHandMadeUIImage alloc]initWithSize:CGSizeMake(sizex, sizey)];
    unsigned int* buffer = mLocIndicatorBG.buffer;
    unsigned int* buffer2 = mLocIndicatorBG2.buffer;
    int halfx = sizex/2;
    int halfy = sizey/2;
    float mapping = 4.f/(float)sizex;
    for (int i = -halfy; i < halfy; ++i) {
        for (int j = -halfx; j < halfx; ++j) {
            unsigned int value = calcPointSingleWithCount((float)j*mapping, (float)i*mapping, 64);
            if (value <= 4) {
                buffer[(i+halfy)*sizex+halfx+j] = 0;
                buffer2[(i+halfy)*sizex+halfx+j] = 255 + (255<<8) + (255<<16) + ((192)<<24);
            }else if(value <= 5){
                buffer2[(i+halfy)*sizex+halfx+j] = 255 + (255<<8) + (255<<16) + ((64)<<24);
                buffer[(i+halfy)*sizex+halfx+j] = ((64)<<24);
            }else if(value <= 6){
                buffer2[(i+halfy)*sizex+halfx+j] = 255 + (255<<8) + (255<<16) + ((128)<<24);
                buffer[(i+halfy)*sizex+halfx+j] = ((128)<<24);
            }else if(value <= 63){
                buffer2[(i+halfy)*sizex+halfx+j] = 255 + (255<<8) + (255<<16) + ((192)<<24);
                buffer[(i+halfy)*sizex+halfx+j] = ((192)<<24);
            }else {
                buffer2[(i+halfy)*sizex+halfx+j] = (128<<24);
                buffer[(i+halfy)*sizex+halfx+j] = 255 + (255<<8) + (255<<16) + (128<<24);
            }
        }
    }
    [mLocIndicatorBG generateUIImage];
    mGLLocIndicatorBG = [[ISTGLImage alloc] initWithOrigin:CGPointMake(smCenterX-smSizexInPoint/2, smCenterY-smSizeyInPoint/2) andImage:mLocIndicatorBG.uiImage.CGImage];
    [mLocIndicatorBG2 generateUIImage];
    mGLLocIndicatorBG2 = [[ISTGLImage alloc] initWithOrigin:CGPointMake(smCenterX-smSizexInPoint/2, smCenterY-smSizeyInPoint/2) andImage:mLocIndicatorBG2.uiImage.CGImage];
}

- (void)createLocIndicator
{
    mLocIndicator = [[ISTHandMadeUIImage alloc]initWithSize:CGSizeMake(smIndicatorWidth, smIndicatorHeight)];
    [mLocIndicator generateUIImage];
    mGLLocIndicator = [[ISTGLImage alloc] initWithOrigin:CGPointMake(smCenterX-smIndicatorWidth/4, smCenterY-smIndicatorHeight/4) andImage:mLocIndicator.uiImage.CGImage];
}

- (void)createZoomIndicatorBG
{
    mZoomIndicatorBG = [[ISTHandMadeUIImage alloc]initWithSize:CGSizeMake(smZoomIndicatorBGWidth, smZoomIndicatorBGHeight)];
    unsigned int* buffer = mZoomIndicatorBG.buffer;
    for (int i = 0; i < smZoomIndicatorBGHeight; ++i) {
        for (int j = 0; j < smZoomIndicatorBGWidth; ++j) {
            buffer[i*smZoomIndicatorBGWidth+j] = ((128)<<24);
        }
    }
    for (int i = smZoomIndicatorBGMargin; i < smZoomIndicatorBGHeight-smZoomIndicatorBGMargin; ++i) {
        for (int j = smZoomIndicatorBGMargin; j < smZoomIndicatorBGWidth-smZoomIndicatorBGMargin; ++j) {
            buffer[i*smZoomIndicatorBGWidth+j] = 255 + (255<<8) + (255<<16) + ((128)<<24);
        }
    }
    [mZoomIndicatorBG generateUIImage];
    mGLZoomIndicatorBG = [[ISTGLImage alloc] initWithOrigin:CGPointMake(smZoomIndicatorX, smCenterY-smZoomIndicatorBGHeight/4) andImage:mZoomIndicatorBG.uiImage.CGImage];
}

- (void)createZoomIndicator
{
    size_t size = smZoomIndicatorBGWidth-2*smZoomIndicatorBGMargin;
    mZoomIndicator = [[ISTHandMadeUIImage alloc]initWithSize:CGSizeMake(size, size)];
    unsigned int* buffer = mZoomIndicator.buffer;
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            buffer[i*size+j] = 255 + (255<<8) + (255<<16) + ((128)<<24);
        }
    }
    for (int i = 1; i < size-1; ++i) {
        for (int j = 1; j < size-1; ++j) {
            buffer[i*size+j] = ((128)<<24);
        }
    }
    [mZoomIndicator generateUIImage];
    mGLZoomIndicator = [[ISTGLImage alloc] initWithOrigin:CGPointMake(smZoomIndicatorX+smZoomIndicatorBGMargin/2, smCenterY-smZoomIndicatorBGHeight/4+smZoomIndicatorBGMargin/2) andImage:mZoomIndicator.uiImage.CGImage];
}

- (void)createDot
{
    mDot = [[ISTHandMadeUIImage alloc]initWithSize:CGSizeMake(smDotSize, smDotSize)];
    unsigned int* buffer = mDot.buffer;
    for (int i = 0; i < smDotSize; ++i) {
        for (int j = 0; j < smDotSize; ++j) {
            buffer[i*smDotSize+j] = 255 + (255<<8) + (255<<16) + ((128)<<24);
        }
    }
    for (int i = 2; i < smDotSize-2; ++i) {
        for (int j = 2; j < smDotSize-2; ++j) {
            buffer[i*smDotSize+j] = ((128)<<24);
        }
    }
    [mDot generateUIImage];
    mGLDot = [[ISTGLImage alloc] initWithOrigin:CGPointMake(0, 0) andImage:mDot.uiImage.CGImage];
}

- (void)dealloc
{    
}

- (void)update:(CGPoint)loc scale:(double)scale
{
    CGRect frame = mGLLocIndicator.frame;
    float mapping = (float)smSizexInPoint / 4.f;
    float x = smCenterX-smIndicatorWidth/4 + loc.x * mapping;
    float y = smCenterY-smIndicatorHeight/4 - loc.y * mapping;
    frame.origin.x = x;
    frame.origin.y = y;
    mGLLocIndicator.frame = frame;
    
    frame = mGLZoomIndicator.frame;
    frame.origin.y = smCenterY-smZoomIndicatorBGHeight/4+smZoomIndicatorBGMargin/2;
    float level = ceil(log2(scale));//level is from 1 to 46;
    float indicatorSize = smZoomIndicatorBGWidth-2*smZoomIndicatorBGMargin;
    float barLen = (smZoomIndicatorBGHeight - 2*smZoomIndicatorBGMargin - indicatorSize)*0.5f;
    float indicatorLoc = (level - 1.f)/(46.f-1.f);
    frame.origin.y += indicatorLoc * barLen;
    mGLZoomIndicator.frame = frame;
}

- (void)draw:(CGPoint)loc scale:(double)scale
{
    [self update:loc scale:scale];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_NEVER, 1, 0xFF);
    glStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
    glStencilMask(0xFF);
    glClear(GL_STENCIL_BUFFER_BIT);
    /*
    //[mGLLocIndicator draw];
    glStencilMask(0x00);
    glStencilFunc(GL_EQUAL, 0, 0xFF);
    //[mGLLocIndicatorBG draw];
    glStencilFunc(GL_EQUAL, 1, 0xFF);
    //[mGLLocIndicatorBG2 draw];
     */
    
    glStencilMask(0xFF);
    glClear(GL_STENCIL_BUFFER_BIT);
    [mGLZoomIndicator draw];
    glStencilMask(0x00);
    glStencilFunc(GL_EQUAL, 0, 0xFF);
    [mGLZoomIndicatorBG draw];
    glStencilFunc(GL_EQUAL, 1, 0xFF);
    [mGLZoomIndicator draw];
    glDisable(GL_STENCIL_TEST);
    
    //[mGLDot draw];
    float doty = [ISTUtility screenHeight] - smDotToButtom;
    
    CGRect frame = mGLDot.frame;
    frame.origin = CGPointMake(smDotXLeft, doty);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(smDotXLeft+10, doty-7);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(smDotXLeft+10, doty+7);
    mGLDot.frame = frame;
    [mGLDot draw];
    
    frame.origin = CGPointMake(smDotXRight, doty);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(smDotXRight+10, doty);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(smDotXRight+20, doty);
    mGLDot.frame = frame;
    [mGLDot draw];
    
    
    float dotx = smDotXCenter - frame.size.width*0.5f;
    //frame.origin = CGPointMake(dotx, doty);
    //mGLDot.frame = frame;
    //[mGLDot draw];
    
    
    if (mAnimating) {
        ++smCounter;
        if (smCounter >= smCounterMax) {
            smCounter = 0.f;
        }
        float temp = smCounter / smCounterMax * 2.f;
        if (temp < 1.f) {
            float dis = smDistance * temp;
            smOffsets[0].x = 0;
            smOffsets[0].y = dis;
            smOffsets[1].x = -dis;
            smOffsets[1].y = 0;
            smOffsets[2].x = 0;
            smOffsets[2].y = -dis;
            smOffsets[3].x = dis;
            smOffsets[3].y = 0;
        }else{
            float dis = smDistance * (temp-1.f);
            smOffsets[0].x = -dis;
            smOffsets[0].y = smDistance;
            smOffsets[1].x = -smDistance;
            smOffsets[1].y = -dis;
            smOffsets[2].x = dis;
            smOffsets[2].y = -smDistance;
            smOffsets[3].x = smDistance;
            smOffsets[3].y = dis;
        }
    }else{
        smOffsets[0].x = smOffsets[0].y = smOffsets[1].x = smOffsets[1].y = smOffsets[2].x = smOffsets[2].y = smOffsets[3].x = smOffsets[3].y = 0.f;
    }
    
    frame.origin = CGPointMake(dotx+8 + smOffsets[0].x, doty + smOffsets[0].y);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(dotx+ smOffsets[1].x, doty+8+ smOffsets[1].y);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(dotx-8+ smOffsets[2].x, doty+ smOffsets[2].y);
    mGLDot.frame = frame;
    [mGLDot draw];
    frame.origin = CGPointMake(dotx+ smOffsets[3].x, doty-8+ smOffsets[3].y);
    mGLDot.frame = frame;
    [mGLDot draw];
}


@end

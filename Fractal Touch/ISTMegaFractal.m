//
//  ISTMegaFractal.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-2-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ISTMegaFractal.h"
#import "ISTFractalTile.h"
#import "ISTMegaFractalShader.h"
#import "ISTTileGenerator.h"
#import "FractalSRCalc.h"
#import "ISTColorSelection.h"
#import "ISTUtility.h"
#import "ISTIterationSelection.h"
#import "ftTextureSelection.h"

typedef enum
{
    AnimateState_default,
    AnimateState_panning,
    AnimateState_stopping,
    AnimateState_tapped,
    AnimateState_tappedOut,
}AnimateState;

@interface ISTMegaFractal()

@property (nonatomic, strong) ISTTileGenerator* generator;
@property (nonatomic, weak) id refreshTarget;
@property (nonatomic, assign) double internalLocX;
@property (nonatomic, assign) double internalLocY;

@property (nonatomic, assign) AnimateState panState;
@property (nonatomic, assign) CGPoint lastDestPoint; 
@property (nonatomic, assign) CGPoint panStoppingVelocity;
@property (nonatomic, strong) NSDate* panStopTime;
@property (nonatomic, assign) NSTimeInterval panStoppingTimeLength;
@property (nonatomic, assign) float lastPinchScale;
@property (nonatomic, assign) CGPoint tapLocation;
@property (nonatomic, assign) float scaleWhenTapped;
@property (nonatomic, assign) CGPoint tapOutLocation;
@property (nonatomic, assign) float scaleWhenTappedOut;

@end


@implementation ISTMegaFractal

@synthesize generator = mGenerator;
@synthesize refreshTarget = mRefreshTarget;
@synthesize internalLocX = mInternalLocX;
@synthesize internalLocY = mInternalLocY;
@synthesize scale = mScale;
@synthesize dirty = mDirty;

@synthesize panState = mPanState;
@synthesize lastDestPoint = mLastDestPoint;
@synthesize panStoppingVelocity = mPanStoppingVelocity;
@synthesize panStopTime = mPanStopTime;
@synthesize panStoppingTimeLength = mPanStoppingTimeLength;
@synthesize lastPinchScale = mLastPinchScale;
@synthesize tapLocation = mTapLocation;
@synthesize scaleWhenTapped = mScaleWhenTapped;
@synthesize tapOutLocation = mTapOutLocation;
@synthesize scaleWhenTappedOut = mScaleWhenTappedOut;

static double smOriginX = 0.0;
static double smOriginY = 0.0;
static float smMinPanEndVelToSlip = 50.f;
static float smStopSlippingVel = 0.1f;
//static double smTapToZoomSpeed = 0.13f;
static double smMinScale = 2.0;
static double smMaxScale = (double)(((long long)1)<<46);

- (double)locationX
{
    return mInternalLocX - smOriginX;
}

- (double)locationY
{
    return mInternalLocY - smOriginY;
}

- (double)absScale
{
    return mScale / [ISTUtility screenScale];
}

- (void)setAbsScale:(double)absScale
{
    mScale = absScale * [ISTUtility screenScale];
}

- (double)absLocationX
{
    if (mInternalLocX == smOriginX) {
        return 0.0;
    }
    return -(mInternalLocX - smOriginX)/(mScale*self.mathCoordToPoint);
}

- (void)setAbsLocationX:(double)absLocationX//need to set scale first!!!
{
    mInternalLocX = -absLocationX*(mScale*self.mathCoordToPoint)+smOriginX;
}

- (double)absLocationY
{
    return (mInternalLocY - smOriginY)/(mScale*self.mathCoordToPoint);
}

- (void)setAbsLocationY:(double)absLocationY//need to set scale first!!!
{
    mInternalLocY = absLocationY*(mScale*self.mathCoordToPoint)+smOriginY;
}

- (double)mathCoordToPoint
{
    return 64.0 / [ISTUtility screenScale];
}


- (ISTMegaFractal*)initWithRefreshTarget:(id)target;
{
    if (self = [super init]) 
    {
        smOriginX = [ISTUtility screenWidth] *0.5;
        smOriginY = [ISTUtility screenHeight]*0.5;
        smMinScale = [ISTUtility screenScale];
        
        mRefreshTarget = target;
        
        mInternalLocX = smOriginX;
        mInternalLocY = smOriginY;
        mScale = smMinScale;
        mDirty = YES;
        mPanState = AnimateState_default;
        mGenerator = [[ISTTileGenerator alloc]initWithMegaFractal:self];
        [ISTFractalTile setupGpuResources];
    }
    return self;
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer*)sender
{
    mTapLocation = [sender locationInView:sender.view];
    mScaleWhenTapped = mScale;
    mPanState = AnimateState_tapped;
}

- (void)handleTwoFingerTapGesture:(UITapGestureRecognizer*)sender
{
    UIView *myView = [sender view];
    CGPoint p0 = [sender locationOfTouch:0 inView:myView];
    CGPoint p1 = [sender locationOfTouch:1 inView:myView];
    mTapOutLocation.x = (p0.x + (p1.x-p0.x)*0.5);
    mTapOutLocation.y = (p0.y + (p1.y-p0.y)*0.5);
    mScaleWhenTappedOut = mScale;
    mPanState = AnimateState_tappedOut;
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)sender
{
    UIView *myView = [sender view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        mLastDestPoint = [sender translationInView:myView];
        mPanState = AnimateState_panning;
    }else{
        CGPoint currentTrans = [sender translationInView:myView];
        
        float diffX = currentTrans.x - mLastDestPoint.x;
        float diffY = currentTrans.y - mLastDestPoint.y;
        mInternalLocX += diffX;
        mInternalLocY += diffY;
        mDirty = YES;

        mLastDestPoint = currentTrans;
        
        if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
        {
            mPanState = AnimateState_stopping;
            mPanStoppingVelocity = [sender velocityInView:myView];
            float vel = mPanStoppingVelocity.x * mPanStoppingVelocity.x + mPanStoppingVelocity.y * mPanStoppingVelocity.y;
            vel = sqrtf(vel);
            if(vel <= smMinPanEndVelToSlip)
            {
                mPanState = AnimateState_default;
                mPanStoppingVelocity.x = mPanStoppingVelocity.y = 0.f;
            } else {
                mPanStoppingVelocity.x = (vel - smMinPanEndVelToSlip) * mPanStoppingVelocity.x / vel;
                mPanStoppingVelocity.y = (vel - smMinPanEndVelToSlip) * mPanStoppingVelocity.y / vel;
            }
            mPanStopTime = [NSDate date];
            mPanStoppingTimeLength = 0.0;
        }
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)sender
{
    UIView *myView = [sender view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        mLastPinchScale = sender.scale;
        mPanState = AnimateState_default;
    }
    else if([sender numberOfTouches] >= 2)
    {
        double currentScale = sender.scale;
        double s = currentScale / mLastPinchScale;
        double scaleToBe = mScale * s;
        if (scaleToBe < smMinScale) {
            scaleToBe = smMinScale;
        }else if (scaleToBe > smMaxScale) {
            scaleToBe = smMaxScale;
        }
        s = scaleToBe / mScale;
        currentScale = s * mLastPinchScale;
        sender.scale = currentScale;
        
        mLastPinchScale = currentScale;
        mScale *= s;
        
        CGPoint p0 = [sender locationOfTouch:0 inView:myView];
        CGPoint p1 = [sender locationOfTouch:1 inView:myView];
        
        double centerX = ((double)(p0.x + (p1.x-p0.x)*0.5) - mInternalLocX);
        double centerY = ((double)(p0.y + (p1.y-p0.y)*0.5) - mInternalLocY);
        mInternalLocX += (centerX * (1.0-s));
        mInternalLocY += (centerY * (1.0-s));
        mDirty = YES;
    }
}

- (void)update
{
    if(mPanState == AnimateState_stopping)
    {
        NSTimeInterval newLength = -[mPanStopTime timeIntervalSinceNow];
        NSTimeInterval interval = newLength - mPanStoppingTimeLength;
        mPanStoppingTimeLength = newLength;
        
        mInternalLocX += mPanStoppingVelocity.x * interval;
        mInternalLocY += mPanStoppingVelocity.y * interval;
        mDirty = YES;
        
        mPanStoppingVelocity.x *= 0.82f;
        mPanStoppingVelocity.y *= 0.82f;
        
        if((mPanStoppingVelocity.x*mPanStoppingVelocity.x + mPanStoppingVelocity.y*mPanStoppingVelocity.y) <= smStopSlippingVel)
        {
            mPanState = AnimateState_default;
            mPanStoppingVelocity.x = mPanStoppingVelocity.y = 0.f;
        }
    }else if (mPanState == AnimateState_tapped) {
        double previousScale = mScale;
        double finalScale = mScaleWhenTapped * 4.0;
        
        double scalediff = finalScale / mScale;
        double scaleInc = (scalediff-1.0) * 0.2;
        if (scaleInc > 0.1) {
            scaleInc = 0.1;
        }
        mScale *= (1.0 + scaleInc);
        
        if (mScale > smMaxScale) {
            mScale = smMaxScale;
        }
        
        if (scalediff <= 1.001) {
            mScale = finalScale;
            mPanState = AnimateState_default;
        }
        double taplocx = (double)(mTapLocation.x) - mInternalLocX;
        double taplocy = (double)(mTapLocation.y) - mInternalLocY;
        double diff = (mScale - previousScale) / previousScale;
        double x = taplocx * diff;
        double y = taplocy * diff;
        mInternalLocX -= x;
        mInternalLocY -= y;
        mDirty = YES;
    }else if (mPanState == AnimateState_tappedOut) {
        double previousScale = mScale;
        double finalScale = mScaleWhenTappedOut * 0.25;
        
        double scalediff = mScale / finalScale;
        double scaleDec = (scalediff-1.0) * 0.2;
        if (scaleDec > 0.1) {
            scaleDec = 0.1;
        }
        mScale *= (1.0 - scaleDec);
        
        if (mScale < smMinScale) {
            mScale = smMinScale;
        }
        
        if (scalediff <= 1.001) {
            mScale = finalScale;
            mPanState = AnimateState_default;
        }
        double taplocx = (double)(mTapOutLocation.x) - mInternalLocX;
        double taplocy = (double)(mTapOutLocation.y) - mInternalLocY;
        double diff = (mScale - previousScale) / previousScale;
        double x = taplocx * diff;
        double y = taplocy * diff;
        mInternalLocX -= x;
        mInternalLocY -= y;
        mDirty = YES;
    }

    if (mDirty) {
        //make sure x, y are in the right range
        double s = mScale / smMinScale;
        double x = s * smOriginX;
        double y = s * smOriginY;
        double xmin = smOriginX + smOriginX - x;
        double ymin = smOriginY + smOriginY - y;
        if (mInternalLocX > x) {
            mInternalLocX = x;
        }else if(mInternalLocX < xmin){
            mInternalLocX = xmin;
        }
        if (mInternalLocY > y) {
            mInternalLocY = y;
        }else if(mInternalLocY < ymin){
            mInternalLocY = ymin;
        }
    }
}

- (void)draw
{
    [mGenerator update];
    
    [ISTFractalTile applyTileCommonState];
    ISTColorCalculator* calc = mGenerator.colorCalculator;

    for (ISTFractalTile* tile in mGenerator.previewTiles){
        [tile drawWithLocX:mInternalLocX locY:mInternalLocY andScale:mScale colcCalc:calc];
    }
    
    for (int i = [mGenerator.tilesLOD count]-1 ; i >= 0; --i) {
        NSEnumerator* enumerator = [[mGenerator.tilesLOD objectAtIndex:i] objectEnumerator];
        for (ISTFractalTile* tile in enumerator) {
            [tile drawWithLocX:mInternalLocX locY:mInternalLocY andScale:mScale colcCalc:nil];
        }
    }
    
    mDirty = NO;
}

- (void)forceRefresh
{
    SEL action = @selector(forceRefresh);
    NSMethodSignature *signature = [self.refreshTarget methodSignatureForSelector:action];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = action;
    invocation.target = self.refreshTarget;
    [invocation invoke];
}

- (void)prepareForColorPreview:(float)preViewWidth
{
    double tilesScale = pow(2.0, mGenerator.currentLevel);
    double scaleRatio = mScale/tilesScale;
    double preViewScale = 0.25;
    int levelDiff = 2;
    double widthInPoint = [ISTUtility screenWidth] * 0.25 / scaleRatio;
    if (widthInPoint < preViewWidth) {
        preViewScale = 0.5;
        levelDiff = 1;
    }
    double width = [ISTUtility screenWidth] * [ISTUtility screenScale] * preViewScale / scaleRatio;
    double height = [ISTUtility screenHeight] * [ISTUtility screenScale] * preViewScale / scaleRatio;
    int dataWidth = (int)width;
    int dataHeight = (int)height;
    PIXEL_FORMAT* rawdata = malloc(dataWidth*dataHeight*sizeof(PIXEL_FORMAT));
    
    ISTFractalTile *tile;
    long long locx = self.locationX*[ISTUtility screenScale]*preViewScale;
    long long locy = self.locationY*[ISTUtility screenScale]*preViewScale;
    NSEnumerator* enumerator = [mGenerator.previewTiles objectEnumerator];
    while (tile = [enumerator nextObject]) {
        [tile drawToMemory:rawdata sizeX:dataWidth sizeY:dataHeight locX:locx locY:locy xyscale:mScale*preViewScale level:mGenerator.currentLevel - levelDiff];
    }
    for (int i = [mGenerator.tilesLOD count]-1 ; i >= levelDiff; --i) {
        enumerator = [[mGenerator.tilesLOD objectAtIndex:i] objectEnumerator];
        while ((tile = [enumerator nextObject])) {
            [tile drawToMemory:rawdata sizeX:dataWidth sizeY:dataHeight locX:locx locY:locy xyscale:mScale*preViewScale level:mGenerator.currentLevel - levelDiff];
        }
    }

    [ISTColorSelection instance].previewRawData = rawdata;
    [ISTColorSelection instance].previewRawDataWidth = dataWidth;
    [ISTColorSelection instance].previewRawDataHeight = dataHeight;
}

- (void)onFractalViewSettingChange
{
    if ([ISTIterationSelection instance].dirtyFlag){
        [mGenerator onColorChangeKeepCache:NO];
    }else if ([ISTColorSelection instance].colorIndexDirty) {
        [mGenerator onColorChangeKeepCache:YES];
    }
    [[ISTIterationSelection instance] clearDirtyFlag];
    [[ISTColorSelection instance] clearColorIndexDirtyFlag];
    mDirty = YES;
    [self forceRefresh];
}

- (void)releaseResource
{
    [mGenerator releaseResource];
    [ISTFractalTile realeaseGpuResources];
}

- (void)dealloc
{
}

@end

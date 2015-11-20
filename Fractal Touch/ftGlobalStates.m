//
//  ftGlobalStates.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ftGlobalStates.h"
#import "ISTColorSelection.h"
#import "ISTIterationSelection.h"
#import "ftTextureSelection.h"
#import "ISTMegaFractal.h"
#import "ISTUtility.h"

@implementation ftGlobalStates
@synthesize reText = mReText;
@synthesize imText = mImText;
@synthesize zoomingText = mZoomingText;
@synthesize dbObject = mDBObject;
@synthesize selectorMode = mSelectorMode;
@synthesize jumpToBuyTag = mJumpToBuyTag;
static ftGlobalStates *sInstance = NULL;


- (ftGlobalStates*)init
{
    if (self = [super init]) {
        mSelectorMode = ScrollingSelectorMode_Color;
        mReText = @"-0.743643135";//@"0.0";
        mImText = @"0.131825963";//@"0.0";
        mZoomingText = @"210350";//@"1.0";
        
        [ISTColorSelection instance].currentColorIndex = 1;
    }
    return self;
}

- (void)setDbObject:(ShaderSource *)dbObject
{
    mDBObject = dbObject;
    mReText = dbObject.re;
    mImText = dbObject.im;
    mZoomingText = dbObject.zomming;
    size_t colorCalcIndex = dbObject.colorIndex.unsignedIntValue & 0x0000ffff;
    size_t colorIndex, colorStyleIndex;
    [ISTColorSelection getColorIndex:&colorIndex colorStyleIndex:&colorStyleIndex withColorCalcIndex:colorCalcIndex];
    self.colorIndex = colorIndex;
    self.colorStyleIndex = colorStyleIndex;
    //self.textureIndex = dbObject.colorIndex.unsignedIntValue >> 16;
    self.iterLimitIndex = dbObject.iterCountIndex.unsignedIntValue;
}

- (size_t)colorIndex
{
    return [ISTColorSelection instance].currentColorIndex;
}

- (void)setColorIndex:(size_t)colorIndex
{
    [ISTColorSelection instance].currentColorIndex = colorIndex;
}

- (size_t)colorStyleIndex
{
    return [ISTColorSelection instance].currentColorStyleIndex;
}

- (void)setColorStyleIndex:(size_t)colorStyleIndex
{
    [ISTColorSelection instance].currentColorStyleIndex = colorStyleIndex;
}

- (size_t)iterLimitIndex
{
    return [ISTIterationSelection instance].iterationLimitIndex;
}

- (void)setIterLimitIndex:(size_t)iterLimitIndex
{
    [ISTIterationSelection instance].iterationLimitIndex = iterLimitIndex;
}

- (size_t)textureIndex
{
    return [ftTextureSelection instance].currentIndex;
}

- (void)setTextureIndex:(size_t)textureIndex
{
    [ftTextureSelection instance].currentIndex = textureIndex;
}

- (void)updateFractalLocInfo:(ISTMegaFractal*)mf
{
    NSArray* texts = [ISTUtility getFractalLocStrings:mf];
    self.reText = [texts objectAtIndex:0];
    self.imText = [texts objectAtIndex:1];
    self.zoomingText = [texts objectAtIndex:2];
}

+ (ftGlobalStates *)instance
{
    @synchronized(self)
    {
        if (sInstance == NULL){
            sInstance = [[self alloc] init];
        }
    }
    return(sInstance);
}

@end

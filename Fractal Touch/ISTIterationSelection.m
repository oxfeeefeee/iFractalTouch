//
//  ISTIterationSelection.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ISTIterationSelection.h"
#import "FractalSRCalc.h"
#import "ISTColorSelection.h"

@implementation ISTIterationSelection

@synthesize iterationLimitIndex = mIterationLimitIndex;
@synthesize dirtyFlag = mDirtyFlag;
static ISTIterationSelection *sInstance = NULL;

+ (ISTIterationSelection*)instance
{
    @synchronized(self)
    {
        if (sInstance == NULL){
            sInstance = [[self alloc] init];
        }
    }
    return(sInstance);
}

- (int)iterationLimit
{
    return g_iterCount;
}

- (int)iterationLimitIndex
{
    if(g_iterCount == 256){
        return 0;
    }else if(g_iterCount == 512){
        return 1;
    }else if(g_iterCount == 1024){
        return 2;
    }else if(g_iterCount == 2048){
        return 3;
    }else if(g_iterCount == 4096){
        return 4;
    }
    return 0;
}

- (void)setIterationLimitIndex:(int)iterationLimitIndex
{
    if (iterationLimitIndex > 4) {
        return;
    }
    int oldVal = g_iterCount;
    if (iterationLimitIndex == 0) {
        g_iterCount = 256;
    }else if(iterationLimitIndex == 1) {
        g_iterCount = 512;
    }else if (iterationLimitIndex == 2) {
        g_iterCount = 1024;
    }else if(iterationLimitIndex == 3) {
        g_iterCount = 2048;
    }else if (iterationLimitIndex == 4) {
        g_iterCount = 4096;
    }
    mIterationLimitIndex = iterationLimitIndex;
    mDirtyFlag = (oldVal != g_iterCount);
    if (mDirtyFlag) {
        [[ISTColorSelection instance] recreateCalculators];
    }
}

- (void)clearDirtyFlag
{
    mDirtyFlag = NO;
}

@end

//
//  ISTColorSelection.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTColorSelection.h"
#import "ISTMegaFractal.h"
#import "ISTUtility.h"
#import "ftTextureSelection.h"

@interface ISTColorSelection()

- (void)createCalculators;

@end


@implementation ISTColorSelection

@synthesize currentColorIndex = mCurrentColorIndex;
@synthesize currentColorStyleIndex = mCurrentColorStyleIndex;

@synthesize colorCalculators = mColorCalculators;
@synthesize colorStyleCalculators = mColorStyleCalculators;
@synthesize currentCalculatorIndex = mCurrentCalculatorIndex;
@synthesize previewRawData = mPreviewRawData;
@synthesize previewRawDataWidth = mPreviewRawDataWidth;
@synthesize previewRawDataHeight = mPreviewRawDataHeight;
@synthesize colorIndexDirty = mColorIndexDirty;

static ISTColorSelection *sInstance = NULL;
static int sStyleCount = 5;

+ (size_t)styleCount
{
    return sStyleCount;
}

- (ISTColorCalculator*) currentCalculator
{
    return [mColorCalculators objectAtIndex:mCurrentCalculatorIndex];
}

- (NSMutableArray*) colorCalculators
{
    NSMutableArray* currentCalcs = [[NSMutableArray alloc] init];
    size_t nextIndex = mCurrentColorStyleIndex;
    while (nextIndex < [mColorCalculators count]) {
        [currentCalcs addObject:[mColorCalculators objectAtIndex:nextIndex]];
        nextIndex += sStyleCount;
    }
    return currentCalcs;
}

- (NSMutableArray*) colorStyleCalculators
{
    NSMutableArray* currentCalcs = [[NSMutableArray alloc] init];
    size_t nextIndex = mCurrentColorIndex * sStyleCount;
    while (nextIndex < mCurrentColorIndex * sStyleCount + sStyleCount) {
        [currentCalcs addObject:[mColorCalculators objectAtIndex:nextIndex]];
        nextIndex += 1;
    }
    return currentCalcs;
}

- (void) setCurrentCalculatorIndex:(size_t)currentCalculatorIndex
{
    if (mCurrentCalculatorIndex != currentCalculatorIndex) {
        mColorIndexDirty = YES;
        mCurrentCalculatorIndex = currentCalculatorIndex;
    }
}

- (void)setCurrentColorIndex:(size_t)currentColorIndex
{
    if (![ISTUtility isIAP_ColorLoverEnabled]) {
        currentColorIndex = 1;
    }
    
    if (mCurrentColorIndex != currentColorIndex) {
        mCurrentColorIndex = currentColorIndex;
        size_t calcIndex = mCurrentColorIndex * sStyleCount + mCurrentColorStyleIndex;
        self.currentCalculatorIndex = calcIndex;
    }
}

- (void)setCurrentColorStyleIndex:(size_t)currentColorStyleIndex
{
    if (mCurrentColorStyleIndex != currentColorStyleIndex) {
        mCurrentColorStyleIndex = currentColorStyleIndex;
        size_t calcIndex = mCurrentColorIndex * sStyleCount + mCurrentColorStyleIndex;
        self.currentCalculatorIndex = calcIndex;
    }
}

- (PIXEL_FORMAT*)previewRawData
{
    return mPreviewRawData;
}

- (void) setPreviewRawData:(short *)previewRawData
{
    free(mPreviewRawData);
    mPreviewRawData = previewRawData;
}

- (void)clearColorIndexDirtyFlag
{
    mColorIndexDirty = NO;
}

- (ISTColorSelection*)init
{
    if(self = [super init])
    {
        [self createCalculators];
        mCurrentColorIndex = 0;
        mCurrentColorStyleIndex = 0;
        mCurrentCalculatorIndex = 0;
        mPreviewRawData = 0;
        mPreviewRawDataWidth = 0;
        mPreviewRawDataHeight = 0;
    }
    return self;
}

- (void)dealloc
{
    free(mPreviewRawData);
}

+ (ISTColorSelection*)instance
{
    @synchronized(self)
    {
        if (sInstance == NULL){
            sInstance = [[self alloc] init];
        }
    }
    return(sInstance);
}

- (void)generatePreviewData:(float)dataWidth
{
    size_t oldWidth = mPreviewRawDataWidth;
    size_t oldHeight = mPreviewRawDataHeight;
    mPreviewRawDataWidth = dataWidth;
    mPreviewRawDataHeight = dataWidth * 1.5;
    void* newData = malloc(2*mPreviewRawDataWidth*mPreviewRawDataHeight);
    [ISTUtility nearestNeighbourScale:mPreviewRawData width:oldWidth height:oldHeight toData:newData width:mPreviewRawDataWidth height:mPreviewRawDataHeight];
    free(mPreviewRawData);
    mPreviewRawData = newData;
    NSEnumerator *enumerator = [mColorCalculators objectEnumerator];
    ISTColorCalculator* calc;
    ISTHandMadeUIImage* texture = [ftTextureSelection instance].currentImage;
    while (calc = [enumerator nextObject]) {
        [calc generatePreviewWithTexture:texture];
    }
}

- (void)generatePreviewImages
{
    ISTHandMadeUIImage* texture = [ftTextureSelection instance].currentImage;
    for (ISTColorCalculator* calc in mColorCalculators) {
        [calc generatePreviewWithTexture:texture];
    }
}

- (void)clearPreviewData
{
    free(mPreviewRawData);
    mPreviewRawData = 0;
    mPreviewRawDataWidth = 0;
    mPreviewRawDataHeight = 0;
}

- (void)recreateCalculators
{
    [self createCalculators];
}

- (void)addColorCalculatorR:(float)r G:(float)g B:(float)b
{
    ISTColorCalculator* calc = [[ISTColorCalculator alloc]initWithParameters2R:r G:g B:b ChangeIndex:0];
    [mColorCalculators addObject:calc];
    calc = [[ISTColorCalculator alloc]initWithParameters2R:r G:g B:b ChangeIndex:1];
    [mColorCalculators addObject:calc];
    calc = [[ISTColorCalculator alloc]initWithParameters2R:r G:g B:b ChangeIndex:2];
    [mColorCalculators addObject:calc];
    calc = [[ISTColorCalculator alloc]initWithParameters2R:r G:g B:b ChangeIndex:3];
    [mColorCalculators addObject:calc];
    calc = [[ISTColorCalculator alloc]initWithParameters2R:r G:g B:b ChangeIndex:4];
    [mColorCalculators addObject:calc];
    
}

- (void)addColorCalculator2R:(float)r G:(float)g B:(float)b
{
    [self addColorCalculatorR:r/256.f G:g/256.f B:b/256.f];
}

- (void)createCalculators
{
    mColorCalculators = [[NSMutableArray alloc] init];

    [self addColorCalculator2R:380*0.7 G:130*0.7 B:190*0.7];
    [self addColorCalculator2R:300 G:0 B:200];
    [self addColorCalculator2R:180 G:0 B:210];
    [self addColorCalculator2R:350 G:80 B:0];
    [self addColorCalculator2R:330*0.8 G:255*0.8 B:80*0.8];
    [self addColorCalculator2R:60 G:240 B:30];
    [self addColorCalculator2R:40*1.2 G:70*1.2 B:160*1.2];
    [self addColorCalculator2R:70 G:210 B:280];
    [self addColorCalculator2R:40 G:65 B:95];
    [self addColorCalculator2R:149 G:113 B:151];
    
    //[self addColorCalculator2R:255 G:0 B:0];
    //[self addColorCalculator2R:0 G:255 B:0];
    //[self addColorCalculator2R:0 G:0 B:255];
    [self addColorCalculator2R:255 G:255 B:255];
}

+ (size_t) getColorCalcIndexWithColorIndex: (size_t)colorIndex andStyleIndex:(size_t)styleIndex
{
    return colorIndex * sStyleCount + styleIndex;
}

+ (void) getColorIndex:(size_t*)colorIndex colorStyleIndex:(size_t*)styleIndex withColorCalcIndex:(size_t)colorCalcIndex
{
    *colorIndex = colorCalcIndex / sStyleCount;
    *styleIndex = colorCalcIndex % sStyleCount;
}

@end
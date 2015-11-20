//
//  ISTFractalTile.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISTOpenglDrawable.h"
#import "FractalSRCalc.h"

typedef enum {
    ISTTileStateIdle,
    ISTTileStateNeedUpload,
    ISTTileStateComputing,
    ISTTileStateReady,
} ISTTileState;

@class ISTColorCalculator;
@class ISTTileGenerator;

@interface ISTFractalTile : NSObject

@property (nonatomic, assign) ISTTileState state;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) long long coordinateX;
@property (nonatomic, assign) long long coordinateY;
@property (nonatomic, assign) BOOL alwaysCache;
@property (nonatomic, assign) BOOL dummyBarrier;
@property (nonatomic, assign) BOOL canSkipRendering;
@property (atomic, assign) BOOL abortComputingFlag;

- (ISTFractalTile*)init;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash; 

- (void)compute:(ISTFractalTile*)previousLevelTile tileGenerator:(ISTTileGenerator*)tileGenerator;
- (void)uploadToGpu:(ISTColorCalculator*)colorCalc;
- (void)unloadFromGpu;
- (BOOL)isComputed;
- (BOOL)needProcess;
- (void)onColorChange:(ISTColorCalculator*) colorCalculator uploadNow:(BOOL)uploadNow;
- (void)drawWithLocX:(long long)locX locY:(long long)locY andScale:(double)scale colcCalc:(ISTColorCalculator*) colorCalculator;
- (bool)fastIsEqual:(long long*)coordx coordx:(long long*)coordy level:(int)level;
- (void)drawToMemory:(PIXEL_FORMAT*)ptr sizeX:(int)sizeX sizeY:(int)sizeY locX:(long long)locX locY:(long long)locY xyscale:(double)xyscale level:(int)level;
- (void)trash;

+ (void)setupGpuResources;
+ (void)realeaseGpuResources;
+ (void)applyTileCommonState;

@end

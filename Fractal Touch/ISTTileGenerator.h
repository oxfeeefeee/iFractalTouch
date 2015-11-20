//
//  ISTTileGenerator.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISTMegaFractal;
@class ISTFractalTile;
@class ISTColorCalculator;

@interface ISTTileGenerator : NSObject

//current frame min max point at current scale
@property (nonatomic, assign) double minX;
@property (nonatomic, assign) double maxX;
@property (nonatomic, assign) double minY;
@property (nonatomic, assign) double maxY;
@property (nonatomic, assign) int currentLevel;
@property (nonatomic, assign) int computingQueueSize;
@property (nonatomic, assign) BOOL newTileUploaded;
@property (nonatomic, readonly,assign) BOOL releaseResourceCalled;

@property (nonatomic, strong) NSArray* tilesLOD;
@property (nonatomic, strong) NSMutableSet* previewTiles;
@property (nonatomic, weak, readonly) ISTMegaFractal* megaFractal;
@property (nonatomic, strong) ISTColorCalculator* colorCalculator;

- (ISTTileGenerator*)initWithMegaFractal:(ISTMegaFractal*) megaFractal;

- (void)update; 

- (void)onColorChangeKeepCache: (BOOL) keepCache;

- (void)releaseResource;

- (void)pauseCalculation;

- (void)resumeCalculation;

@end

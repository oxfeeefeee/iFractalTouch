//
//  ISTColorSelection.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISTColorCalculator.h"

@class ISTMegaFractal;

@interface ISTColorSelection : NSObject

@property (nonatomic, assign) PIXEL_FORMAT* previewRawData;
@property (nonatomic, assign) size_t previewRawDataWidth;
@property (nonatomic, assign) size_t previewRawDataHeight;

@property (nonatomic, assign) size_t currentColorIndex;
@property (nonatomic, assign) size_t currentColorStyleIndex;

@property (nonatomic, strong, readonly) NSMutableArray* colorCalculators;
@property (nonatomic, strong, readonly) NSMutableArray* colorStyleCalculators;
@property (nonatomic, assign, readonly) size_t currentCalculatorIndex;
@property (nonatomic, readonly) ISTColorCalculator* currentCalculator;
@property (nonatomic, readonly) BOOL colorIndexDirty;

- (void)recreateCalculators;

- (void)generatePreviewData:(float)dataWidth;

- (void)generatePreviewImages;

- (void)clearPreviewData;

- (void)clearColorIndexDirtyFlag;

+ (ISTColorSelection*)instance;

+ (size_t) getColorCalcIndexWithColorIndex: (size_t)colorIndex andStyleIndex:(size_t)styleIndex;

+ (void) getColorIndex:(size_t*)colorIndex colorStyleIndex:(size_t*)styleIndex withColorCalcIndex:(size_t)colorCalcIndex;

+ (size_t)styleCount;

@end

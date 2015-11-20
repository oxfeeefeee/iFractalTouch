//
//  ISTColorCalculator.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FractalGridCalc.h"

@class ISTHandMadeUIImage;

@interface ISTColorCalculator : NSObject

@property (nonatomic, readonly) unsigned short* bufferPtr;
@property (nonatomic, readonly) unsigned int* colorMap;
@property (nonatomic, readonly) unsigned short* colorMap2;
@property (nonatomic, strong) ISTHandMadeUIImage* preview;

- (ISTColorCalculator*) initWithParametersR:(float)r G:(float)g B:(float)b;

- (ISTColorCalculator*) initWithParameters2R:(float)r G:(float)g B:(float)b ChangeIndex:(size_t)index;

- (void) updateColorBufferWithData:(PIXEL_FORMAT*)data;

- (ISTColorCalculator*) copy;

- (void)generatePreviewWithTexture:(ISTHandMadeUIImage*)texture;

@end

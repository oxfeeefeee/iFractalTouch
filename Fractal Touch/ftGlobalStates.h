//
//  ftGlobalStates.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShaderSource.h"

@class ISTMegaFractal;

enum ScrollingSelectorMode {
    ScrollingSelectorMode_Color = 0,
    ScrollingSelectorMode_Style = 1,
    ScrollingSelectorMode_Texture = 2,
};

@interface ftGlobalStates : NSObject

@property (nonatomic, strong) NSString* reText;
@property (nonatomic, strong) NSString* imText;
@property (nonatomic, strong) NSString* zoomingText;
@property (nonatomic, strong) ShaderSource* dbObject;
@property (nonatomic, assign) size_t colorIndex;
@property (nonatomic, assign) size_t colorStyleIndex;
@property (nonatomic, assign) size_t iterLimitIndex;
@property (nonatomic, assign) size_t textureIndex;
@property (nonatomic, assign) enum ScrollingSelectorMode selectorMode;
@property (nonatomic, strong) NSString* jumpToBuyTag;

- (void)updateFractalLocInfo:(ISTMegaFractal*)mf;

+ (ftGlobalStates*)instance;

@end

//
//  ISTMegaFractal.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-2-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISTOpenglDrawable.h"

@interface ISTMegaFractal : NSObject<ISTOpenglDrawable>

@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, readonly) double scale;
@property (nonatomic, readonly) double locationX;
@property (nonatomic, readonly) double locationY;
@property (nonatomic, assign) double absScale;
@property (nonatomic, assign) double absLocationX;
@property (nonatomic, assign) double absLocationY;
@property (nonatomic, readonly) double mathCoordToPoint;

- (ISTMegaFractal*)initWithRefreshTarget:(id)target;

- (void)handleDoubleTapGesture:(UITapGestureRecognizer*)sender;

- (void)handleTwoFingerTapGesture:(UITapGestureRecognizer*)sender;

- (void)handlePanGesture:(UIPanGestureRecognizer*)sender;

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)sender;

- (void)update;

- (void)draw;

- (void)forceRefresh;

- (void)prepareForColorPreview:(float)preViewWidth;

- (void)onFractalViewSettingChange;

- (void)releaseResource;

@end

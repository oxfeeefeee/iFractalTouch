//
//  ISTFractalHUD.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISTFractalHUD : NSObject

@property (nonatomic, assign) BOOL animating;

- (void)draw:(CGPoint)loc scale:(double)scale;

@end
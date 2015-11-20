//
//  ISTButton.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISTGLImage.h"


@interface ISTButton : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) ISTGLImage *image;

- (ISTButton*)initWithOrigin:(CGPoint)origin andResourcePath:(NSString*)path ofType:(NSString*)type;

- (ISTButton*)initWithOrigin:(CGPoint)origin andImage:(CGImageRef)image;

- (ISTButton*)initWithOrigin:(CGPoint)origin andSize:(CGSize)size;

- (void)setTarget:(id)target action:(SEL)action;

- (void)draw;

- (BOOL)inMyFrame:(CGPoint)point;

- (void)handleTap;

@end

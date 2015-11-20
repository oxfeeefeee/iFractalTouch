//
//  ISTButton.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTButton.h"

@interface ISTButton()

@property (nonatomic, strong) NSInvocation* targetAction;

@end

@implementation ISTButton

@synthesize frame = mFrame;
@synthesize image = mImage;
@synthesize targetAction = mTargetAction;


- (BOOL)inMyFrame:(CGPoint)point
{
    return CGRectContainsPoint(self.frame, point);
}

- (void)handleTap
{
    [mTargetAction invoke];
}

- (ISTButton*)initWithOrigin:(CGPoint)origin andResourcePath:(NSString*)path ofType:(NSString*)type
{
    if(self = [self init]){
        mImage = [[ISTGLImage alloc]initWithOrigin:origin andResourcePath:path ofType:type];
        mFrame = mImage.frame;
    }
    return self;
}

- (ISTButton*)initWithOrigin:(CGPoint)origin andImage:(CGImageRef)image
{
    if(self = [self init]){
        mImage = [[ISTGLImage alloc]initWithOrigin:origin andImage:image];
        mFrame = mImage.frame;
    }
    return self;   
}

- (ISTButton*)initWithOrigin:(CGPoint)origin andSize:(CGSize)size
{
    if (self = [self init]) {
        mFrame = CGRectMake(origin.x, origin.y, size.width, size.height);
    }
    return self;
}

- (void)setTarget:(id)target action:(SEL)action
{
    NSMethodSignature *signature = [target methodSignatureForSelector:action];
    mTargetAction = [NSInvocation invocationWithMethodSignature:signature];
    mTargetAction.selector = action;
    mTargetAction.target = target;
}

- (void)draw
{
    [self.image draw];
}

@end

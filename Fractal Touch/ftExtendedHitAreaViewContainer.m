//
//  ftExtendedHitAreaViewContainer.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ftExtendedHitAreaViewContainer.h"

@implementation ftExtendedHitAreaViewContainer

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        if ([[self subviews] count] > 0) {
            //force return of first child, if exists
            return [[self subviews] objectAtIndex:0];
        } else {
            return self;
        }
    }
    return nil;
}

@end

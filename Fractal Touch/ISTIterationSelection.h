//
//  ISTIterationSelection.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISTIterationSelection : NSObject

@property (nonatomic, assign, readonly) int iterationLimit;
@property (nonatomic, assign) int iterationLimitIndex;
@property (nonatomic, assign, readonly) BOOL dirtyFlag;

- (void)clearDirtyFlag;

+ (ISTIterationSelection*)instance;

@end

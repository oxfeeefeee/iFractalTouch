//
//  ISTHandMadeUIImage.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISTHandMadeUIImage : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) unsigned int* buffer;
@property (nonatomic, assign)CGImageRef cgImage;
@property (nonatomic, strong) UIImage* uiImage;

- (ISTHandMadeUIImage*) initWithSize:(CGSize) size;

- (void)dataUpsideDown;

- (void)generateUIImage;

- (void)generateUIImageFast;

@end

//
//  ISTGLButton.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISTOpenglDrawable.h"

@interface ISTGLImage : NSObject<ISTOpenglDrawable>

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) GLKTextureInfo* texture;

- (ISTGLImage*)initWithOrigin:(CGPoint)origin andResourcePath:(NSString*)path ofType:(NSString*)type;

- (ISTGLImage*)initWithOrigin:(CGPoint)origin andImage:(CGImageRef)image;

- (ISTGLImage*)initWithFrame:(CGRect)frame andTexture:(GLKTextureInfo*)texture;

- (void)draw;

@end
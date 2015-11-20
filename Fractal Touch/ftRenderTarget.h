//
//  ftRenderTarget.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class ISTHandMadeUIImage;

@interface ftRenderTarget : NSObject

@property (nonatomic, assign) GLuint textureName;

- (ftRenderTarget*)initWithSize:(CGSize)size;

- (void) applyRenderTarget;

- (void) restorePreviousRenderTarget;

- (ISTHandMadeUIImage*) getResultAsUIImage;

@end

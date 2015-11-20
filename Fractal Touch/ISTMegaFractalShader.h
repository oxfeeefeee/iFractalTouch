//
//  ISTMegaFractalShader.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-2-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTShader.h"

@interface ISTMegaFractalShader : NSObject<ISTShaderDelegate>

@property (nonatomic, assign) GLKMatrix4 mvpMatrix;
@property (nonatomic, assign) GLuint textureName;

- (void)applyShader;
- (void)updateUniforms;

- (void)bindAttributeLocations;
- (void)getUniformLocations;

+ (ISTMegaFractalShader*)instance;
+ (void)releaseInstance;

@end

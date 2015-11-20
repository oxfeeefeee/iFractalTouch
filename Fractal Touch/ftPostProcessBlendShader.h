//
//  ftPostProcessBlend.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ISTShader.h"

@interface ftPostProcessBlendShader : NSObject<ISTShaderDelegate>

@property (nonatomic, assign) GLKMatrix4 mvpMatrix;
@property (nonatomic, assign) GLuint textureName;
@property (nonatomic, assign) GLuint blendTexture;

- (void)applyShader;
- (void)updateUniforms;

- (void)bindAttributeLocations;
- (void)getUniformLocations;

+ (ftPostProcessBlendShader*)instance;
+ (void)releaseInstance;

@end

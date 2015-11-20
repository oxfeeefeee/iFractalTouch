//
//  ftPostProcessImage.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ISTGLImage.h"

@interface ftPostProcessImage : ISTGLImage

@property (nonatomic, assign) GLuint textureName;
@property (nonatomic, assign) GLuint blendTextureName;

- (ftPostProcessImage*)initWithFrame:(CGRect)frame andBlendingTextureUV:(CGPoint)uv;

- (ftPostProcessImage*)initWithFrame:(CGRect)frame andTextureName:(GLuint)textureName andBlendingTextureUV:(CGPoint)uv;

@end

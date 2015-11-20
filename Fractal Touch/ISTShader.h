//
//  ISTShaderBase.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    ISTVertexAttribPosition,
    ISTVertexAttribNormal,
    ISTVertexAttribColor,
    ISTVertexAttribTexCoord0,
    ISTVertexAttribTexCoord1,
} ISTVertexAttrib;

@protocol ISTShaderDelegate;

@interface ISTShader : NSObject

@property (nonatomic, readonly) GLuint program;
@property (nonatomic, assign) id<ISTShaderDelegate> delegate;

- (void)applyShader;
- (void)deleteShader;

- (BOOL)loadShaderVS:(NSString*)vs andPS:(NSString*)ps;

@end


@protocol ISTShaderDelegate <NSObject>

- (void)bindAttributeLocations;
- (void)getUniformLocations;

@end

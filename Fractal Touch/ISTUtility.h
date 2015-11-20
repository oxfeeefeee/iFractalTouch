//
//  ISTUtility.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@class ISTMegaFractal;

@interface ISTUtility : NSObject

+ (BOOL)isRetina;

+ (BOOL)isMultiCore;

+ (BOOL)isTallScreenPhone;

+ (int)screenWidth;

+ (int)screenHeight; 

+ (int)screenWidthInPixel;

+ (int)screenHeightInPixel; 

+ (float)screenScale;

+ (float)heightOverWidth;

+ (float)previewWidth;

+ (CGSize)previewSizeInPixel;

+ (float)blendingTextureVirtualSize;

+ (NSArray*)getFractalLocStrings:(ISTMegaFractal*) factal;

+ (CGImageRef)createImageWithData:(void*)data width:(size_t)width height:(size_t)height;

+ (void)getRGBAsFromImage:(UIImage*)image scaleTo:(CGSize)scaleTo toSize:(CGSize)size toBuffer:(unsigned int*)buffer;

+ (void)nearestNeighbourScale:(void*)data width:(size_t)width height:(size_t)height toData:(void*)scaledData width:(size_t)newWidth height:(size_t)newHheight;

+ (UIImage*)loadImageWithPath:(NSString*)path ofType:(NSString*)type;

+ (GLKTextureInfo*)loadTextureWithPath:(NSString*)path ofType:(NSString*)type;

+ (BOOL)isFreeVersion;

+ (BOOL)isIAP_ColorLoverEnabled;

+ (BOOL)isIAP_SpeedingEnabled;

+ (void)refreshIAP;

+ (BOOL)isIAP_CollectorEnabled;

+ (NSString*)iapColorLoverPID;

+ (NSString*)iapSpeedingPID;

+ (NSString*)iapCollectorPID;

+ (BOOL)isFeatureEnabled:(NSString*)pid;

+ (BOOL)enableFeature:(NSString*)pid;

+ (NSURL*)getMyAppUrl;

@end

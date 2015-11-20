//
//  ISTUtility.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include <sys/sysctl.h>
#import "ISTUtility.h"
#import "ISTMegaFractal.h"

@implementation ISTUtility

static int smIsRetina = -1;
static int smIsMultiCore = -1;
static int smWidthInPixel = 0;
static int smHeightInPixel = 0;
static float smScreenScale = 0;
static int smScreenWidth=0;
static int smScreenHeight = 0;
static float smHeightOverWidth = 0.f;
static float smPreviewWidth = 2* 58.f;
static float smBlendingTextureVirtualSize = 128.f;
static int smIsFreeVersion = -1;
static int smIsSpeedingEnabled = -1;

static NSString* smIAPCollectorPID = @"iFractalTouchFreeIAPCollector";
static NSString* smIAPColorLoverPID = @"iFractalTouchFreeIAPColorLover";
static NSString* smIAPSpeedingPID = @"iFractalTouchFreeIAPSpeeding";

int c_isMultiCore()
{
    if (smIsMultiCore != -1) {
        return smIsMultiCore != 0;
    }else{
        size_t len;
        unsigned int ncpu;
        
        len = sizeof(ncpu);
        sysctlbyname ("hw.ncpu",&ncpu,&len,NULL,0);
        
        smIsMultiCore = 0;
        if (ncpu >= 2) {
            smIsMultiCore = 1;
        }
        
        return smIsMultiCore != 0;
    }
 
}

+ (BOOL)isRetina
{
    if (smIsRetina == -1) {
        smIsRetina = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00;
    }
    return smIsRetina != 0;
}

+ (BOOL)isTallScreenPhone
{
    return [self screenHeight] > 480;
}

+ (BOOL)isMultiCore
{
    return c_isMultiCore();
}

+ (int)screenWidth
{ 
    if (smScreenWidth == 0) {
        smScreenWidth = [ [ UIScreen mainScreen ] bounds ].size.width;
    }
    return smScreenWidth;
}

+ (int)screenHeight
{
    if (smScreenHeight == 0) {
        smScreenHeight = [ [ UIScreen mainScreen ] bounds ].size.height;
    }
    return smScreenHeight;
}

+ (int)screenWidthInPixel
{
    if (smWidthInPixel == 0) {
        smWidthInPixel = [ISTUtility isRetina]? [self screenWidth] * 2 : [self screenWidth];
    }
    return smWidthInPixel;
}

+ (int)screenHeightInPixel
{
    if (smHeightInPixel == 0) {
        smHeightInPixel = [ISTUtility isRetina]? [self screenHeight] * 2 : [self screenHeight];
    }
    return smHeightInPixel;
}

+ (float)screenScale
{
    if(smScreenScale == 0.f)
    {
        smScreenScale = [ISTUtility isRetina]? 2.f : 1.f;
    }
    return smScreenScale;
}

+ (float)heightOverWidth
{
    if (smHeightOverWidth == 0.f) {
        smHeightOverWidth = (float)[self screenHeight]/(float)[self screenWidth];
    }
    return smHeightOverWidth;
}

+ (float)previewWidth
{
    return smPreviewWidth;
}

+ (CGSize)previewSizeInPixel
{
    return CGSizeMake(smPreviewWidth*[ISTUtility screenScale], smPreviewWidth*[ISTUtility screenScale]*[self heightOverWidth]);
}

+ (float)blendingTextureVirtualSize
{
    return smBlendingTextureVirtualSize;
}

+ (NSArray*)getFractalLocStrings:(ISTMegaFractal*) mf
{
    NSString* zoomingValueText = [NSString stringWithFormat:@"%.2f", mf.absScale];
    size_t digits = (size_t)log10(mf.scale*mf.mathCoordToPoint) + 1;
    NSString *format = [NSString stringWithFormat:@"%%.%zdf", digits];
    NSString* reValueText = [NSString stringWithFormat:format, mf.absLocationX];
    NSString* imValueText = [NSString stringWithFormat:format, mf.absLocationY];
    return [[NSArray alloc]initWithObjects:reValueText, imValueText, zoomingValueText, nil];
}

+ (CGImageRef)createImageWithData:(void*)data width:(size_t)width height:(size_t)height
{
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, 
                                                              data, 
                                                              width*height*4, 
                                                              NULL);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaLast;//kCGBitmapByteOrder32Big;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        32,
                                        4*width,colorSpaceRef,
                                        bitmapInfo,
                                        provider,NULL,NO,renderingIntent);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return imageRef;
}

+ (GLKTextureInfo*)loadTextureWithPath:(NSString*)path ofType:(NSString*)type
{
    GLKTextureInfo* texture = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
    if ([ISTUtility isRetina]) {
        NSString* realpath = [NSString stringWithFormat: @"%@@2x", path];
        NSString* filePath = [[NSBundle mainBundle] pathForResource:realpath ofType:type];
        NSError *error = nil;
        texture = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:&error];
        if (error) {
            NSLog(@"Error loading texture!%@", error);
        }
    }else{
        NSError *error = nil;
        NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:type];
        texture = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:&error];
        if (error) {
            NSLog(@"Error loading texture!");
        }
    }
    return texture;
}

+ (UIImage*)loadImageWithPath:(NSString*)path ofType:(NSString*)type
{
    if ([ISTUtility isRetina]) {
        NSString* realpath = [NSString stringWithFormat: @"%@@2x", path];
        NSString* filePath = [[NSBundle mainBundle] pathForResource:realpath ofType:type];
        return [UIImage imageWithContentsOfFile:filePath];
    }else{
        NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:type];
        UIImage* image = [UIImage imageWithContentsOfFile:filePath];
        if (!image) {
            NSString* realpath = [NSString stringWithFormat: @"%@@2x", path];
            NSString* filePath = [[NSBundle mainBundle] pathForResource:realpath ofType:type];
            return [UIImage imageWithContentsOfFile:filePath];
        }
    }
    return nil;
}

+ (void)nearestNeighbourScale:(void*)data width:(size_t)width height:(size_t)height toData:(void*)scaledData width:(size_t)newWidth height:(size_t)newHheight;
{
    float xRation = (float)width / (float)newWidth; 
    float yRation = (float)height/(float)newHheight;
    for (int i = 0;  i < newHheight - 1; ++i) {
        float floatI = (float)i;
        float oldI = floatI * yRation;
        int oldIInt = (int)oldI;
        if (oldI - floorf(oldI) > 0.5f) {
            ++oldIInt;
        }
        for (int j = 0; j < newWidth -1; ++j) {
            float floatJ = (float)j;
            float oldJ = floatJ * xRation;
            int oldJInt = (int)oldJ;
            oldJInt += (int)((oldJ - floorf(oldJ)) * 2.0f);
            ((unsigned short*)scaledData)[i*newWidth+j]
                = ((unsigned short*)data)[oldIInt*width+oldJInt];
        }
        ((unsigned short*)scaledData)[i*newWidth+newWidth-1]
            = ((unsigned short*)data)[oldIInt*width+width-1];
    }
    for (int j = 0; j < newWidth; ++j) {
        float floatJ = (float)j;
        float oldJ = floatJ * xRation;
        int oldJInt = (int)oldJ;
        if (oldJ - floorf(oldJ) > 0.5f) {
            ++oldJInt;
        }
        ((unsigned short*)scaledData)[(newHheight-1)*newWidth+j]
            = ((unsigned short*)data)[(height-1)*width+oldJInt];
    }
}

+ (void)getRGBAsFromImage:(UIImage*)image scaleTo:(CGSize)scaleTo toSize:(CGSize)size toBuffer:(unsigned int*)buffer
{
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(buffer, size.width, size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawTiledImage(context, CGRectMake(0, 0, scaleTo.width, scaleTo.height), imageRef);
    CGContextRelease(context);
}

+ (BOOL)isFreeVersion
{
    if (smIsFreeVersion == -1) {
        NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if ([name isEqualToString: @"iFractalTouch"]) {
            smIsFreeVersion = 0;
        }else{
            smIsFreeVersion = 1;
        }
    }
    return smIsFreeVersion;
}

+ (void)refreshIAP
{
    smIsSpeedingEnabled = -1;
}

+ (BOOL)getIAPInfoWithPID:(NSString*)pid pListName:(NSString*)plistName
{
    id idEnabled =[[NSUserDefaults standardUserDefaults] objectForKey:pid];
    if (idEnabled == nil) {
        BOOL enabled = [[[NSBundle mainBundle] objectForInfoDictionaryKey:plistName] boolValue];
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:pid];
        idEnabled =[[NSUserDefaults standardUserDefaults] objectForKey:pid];
    }
    return [idEnabled boolValue] ;
}

+ (BOOL)isIAP_ColorLoverEnabled
{
    return [ISTUtility getIAPInfoWithPID:smIAPColorLoverPID pListName:@"IAP_ColorLover"];
}

+ (BOOL)isIAP_SpeedingEnabled
{
    return 1;
    if (smIsSpeedingEnabled == -1) {
        
        BOOL enabled = [ISTUtility getIAPInfoWithPID:smIAPSpeedingPID pListName:@"IAP_Speeding"];
        
        if (enabled) {
            smIsSpeedingEnabled = 1;
        }else{
            smIsSpeedingEnabled = 0;
        }
    }
    return smIsSpeedingEnabled;
}

+ (BOOL)isIAP_CollectorEnabled
{
    return [ISTUtility getIAPInfoWithPID:smIAPCollectorPID pListName:@"IAP_Collector"];
}

+ (NSString*)iapColorLoverPID
{
    return smIAPColorLoverPID;
}

+ (NSString*)iapSpeedingPID
{
    return smIAPSpeedingPID;
}

+ (NSString*)iapCollectorPID
{
    return smIAPCollectorPID;
}

+ (BOOL)isFeatureEnabled:(NSString*)pid
{
    if ([pid isEqualToString:smIAPColorLoverPID] ) {
        return [ISTUtility isIAP_ColorLoverEnabled];
    }else if ([pid isEqualToString:smIAPSpeedingPID]){
        return [ISTUtility isIAP_SpeedingEnabled];
    }else if ([pid isEqualToString:smIAPCollectorPID]){
        return [ISTUtility isIAP_CollectorEnabled];
    }
    return NO;
}

+ (BOOL)enableFeature:(NSString*)pid
{
    if ([pid isEqualToString:smIAPColorLoverPID] || [pid isEqualToString:smIAPSpeedingPID] || [pid isEqualToString:smIAPCollectorPID]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:pid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [ISTUtility refreshIAP];
        return YES;
    }
    return NO;
}

+ (NSURL*)getMyAppUrl
{
    return [NSURL URLWithString:@"http://itunes.com/app/iFractalTouch"];
}


@end

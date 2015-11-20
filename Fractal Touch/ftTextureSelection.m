//
//  ftTextureSelection.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ftTextureSelection.h"
#import "ftRenderTarget.h"
#import "ftPostProcessImage.h"
#import "ISTUtility.h"
#import "ISTColorSelection.h"
#import "ftGlobalStates.h"


@interface ftTextureSelection()

@property (nonatomic, strong) NSMutableDictionary* allImages;
@property (nonatomic, strong) NSMutableDictionary* allTextures;
@property (nonatomic, assign) BOOL initialized;

@end


@implementation ftTextureSelection

@synthesize currentIndex = mCurrentIndex;
@synthesize needUpdateViewer = mNeedUpdateViewer;
@synthesize initialized = mInitialized;
@synthesize allIDs = mAllIDs;
@synthesize allImages = mAllImages;
@synthesize allTextures = mAllTextures;
@synthesize allPreviewImages = mAllPreviewImages;
static ftTextureSelection *sInstance = NULL;

+ (ftTextureSelection*)instance
{
    @synchronized(self)
    {
        if (sInstance == NULL){
            sInstance = [[self alloc] init];
        }
    }
    return(sInstance);
}

+ (void)releaseInstance
{
    sInstance = NULL;
}

- (NSString*) currentID
{
    if (!mInitialized) {
        self. currentIndex = [[ftGlobalStates instance] dbObject].colorIndex.unsignedIntValue >> 16;
    }
    return [mAllIDs objectAtIndex:mCurrentIndex];
}

- (void) setCurrentID:(NSString *)currentID
{
    for (int i = 0; i < mAllIDs.count; ++i) {
        if ([mAllIDs objectAtIndex:i] == currentID) {
            mCurrentIndex = i;
        }
    }
}

- (void) setCurrentIndex:(size_t)i
{
    if (i < [mAllIDs count]) {
        mCurrentIndex = i;
        mInitialized = YES;
    }
}

- (ftTextureSelection*)init
{
    if(self = [super init])
    {
        mNeedUpdateViewer = YES;
        mInitialized = NO;
        mAllIDs = [[NSMutableArray alloc]init];
        mAllImages = [[NSMutableDictionary alloc]init];
        mAllTextures = [[NSMutableDictionary alloc]init];
        mAllPreviewImages = [[NSMutableArray alloc]init];
        [self loadTextures];
        mCurrentIndex = 0;
    }
    return self;
}

- (GLKTextureInfo*)currentTexture
{
    return [mAllTextures objectForKey: self.currentID];
}

- (ISTHandMadeUIImage*)currentImage
{
    return [mAllImages objectForKey: self.currentID];
}

- (void)generatePreview
{
    [mAllPreviewImages removeAllObjects];
    for (NSString* imageName in mAllIDs){
        [[ISTColorSelection instance].currentCalculator generatePreviewWithTexture:[mAllImages objectForKey:imageName]];
        [mAllPreviewImages addObject:[ISTColorSelection instance].currentCalculator.preview]; 
    }
}

- (void)loadTexture:(NSString*) tname
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
    UIImage* image = [ISTUtility loadImageWithPath:tname ofType:@"png"];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:nil];
    glBindTexture(GL_TEXTURE_2D, texture.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    ISTHandMadeUIImage* hmImage = [[ISTHandMadeUIImage alloc]initWithSize:[ISTUtility previewSizeInPixel]];
    float size = [ISTUtility blendingTextureVirtualSize] ;//* [ISTUtility previewWidth] / [ISTUtility screenWidth];
    [ISTUtility getRGBAsFromImage:image scaleTo:CGSizeMake(size, size) toSize:hmImage.size toBuffer:hmImage.buffer];
    [hmImage generateUIImageFast];
    [mAllIDs addObject:tname];
    [mAllImages setObject:hmImage forKey:tname];
    [mAllTextures setObject:texture forKey:tname];
}

- (void)loadTextures
{
    [self loadTexture:@"blank"];
    [self loadTexture:@"japanese"];
    [self loadTexture:@"recycle"];
    [self loadTexture:@"sand"];
    [self loadTexture:@"canvas1"];
    [self loadTexture:@"canvas2"];
    [self loadTexture:@"structure2"];
    [self loadTexture:@"structure1"];
}

- (ISTHandMadeUIImage*)getImageWithID:(NSString*)textureID
{
    return [mAllImages objectForKey:textureID];
}

- (void)dealloc
{
    for(NSString *key in mAllTextures) {
        GLKTextureInfo* texture = [mAllTextures objectForKey:key];
        GLuint tname = texture.name;
        glDeleteTextures(1, &tname);
    }
}

@end

//
//  ftTextureSelection.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ISTHandMadeUIImage.h"

@interface ftTextureSelection : NSObject

@property (nonatomic, strong, readonly) NSMutableArray* allIDs;
@property (nonatomic, strong) NSMutableArray* allPreviewImages;
@property (nonatomic, assign) size_t currentIndex;
@property (nonatomic, strong) NSString* currentID;
@property (nonatomic, readonly) GLKTextureInfo* currentTexture;
@property (nonatomic, readonly) ISTHandMadeUIImage* currentImage;
@property (nonatomic, assign) BOOL needUpdateViewer;

- (void)generatePreview;

- (ISTHandMadeUIImage*)getImageWithID:(NSString*)textureID;

- (void)loadTextures;

+ (ftTextureSelection*)instance;

+ (void)releaseInstance;

@end

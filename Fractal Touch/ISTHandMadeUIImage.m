//
//  ISTHandMadeUIImage.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTHandMadeUIImage.h"
#import "ISTUtility.h"


@interface ISTHandMadeUIImage()

@end

@implementation ISTHandMadeUIImage

@synthesize size = mSize;
@synthesize uiImage = mUIImage;
@synthesize buffer = mBuffer;
@synthesize cgImage = mCGImage;

- (ISTHandMadeUIImage*) initWithSize:(CGSize) size
{   
    if (self = [super init]) {
        mSize = size;
        mBuffer = malloc(size.width*size.height*sizeof(unsigned int));
        mCGImage = NULL;
        mUIImage = nil;
    }
    return self;
}

- (void)dataUpsideDown
{
    unsigned int bufferSize = mSize.width * sizeof(unsigned int);
    void* buffer = malloc(bufferSize);
    void* data = (void*)mBuffer;
    for (int i = 0; i < mSize.height/2; ++i) {
        int j = mSize.height - 1 - i;
        memcpy(buffer, data+(i * bufferSize), bufferSize);
        memcpy(data+(i * bufferSize), data+(j * bufferSize), bufferSize);
        memcpy(data+(j * bufferSize), buffer, bufferSize);
    }
    free(buffer);
}

- (void)generateUIImage
{
    mCGImage = [ISTUtility createImageWithData:mBuffer width:mSize.width height:mSize.height];
    mUIImage = [[UIImage alloc]initWithData:UIImagePNGRepresentation([UIImage imageWithCGImage:mCGImage])];
}

- (void)generateUIImageFast
{
    mCGImage = [ISTUtility createImageWithData:mBuffer width:mSize.width height:mSize.height];
    mUIImage = [[UIImage alloc]initWithCGImage:mCGImage];
}

- (void)dealloc
{
    mUIImage = nil;
    CGImageRelease(mCGImage);
    free(mBuffer);
}

@end

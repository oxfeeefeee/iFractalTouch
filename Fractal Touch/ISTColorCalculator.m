//
//  ISTColorCalculator.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTColorCalculator.h"
#import "ISTColorSelection.h"
#import "ISTUtility.h"
#import "math.h"
#import "ftTextureSelection.h"
#import "ISTHandMadeUIImage.h"

@interface ISTColorCalculator()
@property (nonatomic, assign) float parameterR;
@property (nonatomic, assign) float parameterG;
@property (nonatomic, assign) float parameterB;
@property (nonatomic, assign) size_t formulaIndex;
@end

@implementation ISTColorCalculator

@synthesize parameterR = mParameterR;
@synthesize parameterG = mParameterG;
@synthesize parameterB = mParameterB;
@synthesize formulaIndex = mFormulaIndex;
@synthesize bufferPtr = mBufferPtr;
@synthesize colorMap = mColorMap;
@synthesize colorMap2 = mColorMap2;
@synthesize preview = mPreview;

static float smGetRGBConst = 1.0f/2.0f*255.0f;
static float smGetRGBConst5 = 1.0f/2.0f*31.0f;
static float smGetRGBConst6 = 1.0f/2.0f*63.0f;

static size_t smInvalidC = 0x0fffffff;

static int smmaxIterCount = 4096;
static float* smFormulaData00 = 0;
static float* smFormulaData01 = 0;
static float* smFormulaData10 = 0;
static float* smFormulaData11 = 0;
static float* smFormulaData20 = 0;
static float* smFormulaData21 = 0;
static float* smFormulaData30 = 0;
static float* smFormulaData31 = 0;
static float* smFormulaData40 = 0;
static float* smFormulaData41 = 0;

- (ISTColorCalculator*)init
{
    if(self = [super init])
    {
        mBufferPtr = malloc(IST_TILE_SIZE*IST_TILE_SIZE*sizeof(short));
        mColorMap = malloc((g_iterCount+1)*sizeof(unsigned int));
        mColorMap2 = malloc((g_iterCount+1)*sizeof(unsigned short)); 
        memset(mColorMap, 0xFF, (g_iterCount+1)*sizeof(unsigned int));
        
        [ISTColorCalculator initFormulaData];
    }
    return self;
}

+ (void)initFormulaData
{
    if (smFormulaData00 == 0) {
        smFormulaData00 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData01 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData10 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData11 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData20 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData21 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData30 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData31 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData40 = malloc((smmaxIterCount+1)*sizeof(float));
        smFormulaData41 = malloc((smmaxIterCount+1)*sizeof(float));
        for (int i = 0; i < smmaxIterCount; ++i) {
            /*smFormulaData00[i] = cosf(sinf((0.05*i)))*2.0f;
            float f = cosf(0.05*2*i)+1.0f;
            smFormulaData01[i] = f*f*0.5f;*/
            
            float t0 = cosf((0.05*i))+1.0f;
            
            float t1 = 0.05*2*i;
            float t = t1;
            
            float pi4 = 4.f * 3.14159265f;
            float toverPi4 = t / pi4 + 0.25f;
            t = toverPi4 - (int)toverPi4;

            if (t > 0.5) {
                smFormulaData00[i] = t0 + cosf(t1) + 1.f;
                smFormulaData01[i] = 0;
            }else{
                t = (cosf((t - 0.25f) * pi4) + 1.0f)*0.5f;
                smFormulaData00[i] = t0;
                smFormulaData01[i] = t * t * 2.f;
            }
            
            smFormulaData10[i] = cosf(0.01*i)+1.0f;
            smFormulaData11[i] = cosf(0.01*16.0*i)+1.0f;
            
            smFormulaData20[i] = cosf(sinf((0.05*i)))*2.0f;
            smFormulaData21[i] = cosf(0.1*16*i)+1.0f;
            
            smFormulaData30[i] = /*cosf(4.0*logf(i))+1.0f;//*/ cosf(sinf((0.001*i)))*2.0f; 
            smFormulaData31[i] = /*cosf(8.0*logf(i))+1.0f;//*/ cosf(0.002*16*i)+1.0f;     
            
            smFormulaData40[i] = cosf(0.16*i)+1.0f;
            smFormulaData41[i] = 0;//cosf(0.05*2.0*i)+1.0f;
        }
    }
}

- (ISTColorCalculator*) initWithParametersR:(float)r G:(float)g B:(float)b
{
    if (self = [self init]) {
        mParameterR = r;
        mParameterG = g;
        mParameterB = b;
        mFormulaIndex = smInvalidC;
        if (r == g && g == b) {
            for (int i = 0; i <= g_iterCount; ++i) {
                [self calcColorImpl2: i Out1:&(mColorMap[i]) Out2:&(mColorMap2[i])];
            }
        }else {
            for (int i = 0; i <= g_iterCount; ++i) {
                [self calcColorImpl: i Out1:&(mColorMap[i]) Out2:&(mColorMap2[i])];
            }
        } 
    }
    return self;
}

- (ISTColorCalculator*) initWithParameters2R:(float)r G:(float)g B:(float)b ChangeIndex:(size_t)index
{
    if (self = [self init]) {
        mParameterR = r;
        mParameterG = g;
        mParameterB = b;
        mFormulaIndex = index;
        
        float* formulaData0 = 0;
        float* formulaData1 = 0;
        if (index == 0) {
            formulaData0 = smFormulaData00;
            formulaData1 = smFormulaData01;
        }else if (index == 1) {
            formulaData0 = smFormulaData10;
            formulaData1 = smFormulaData11;
        }else if (index == 2) {
            formulaData0 = smFormulaData20;
            formulaData1 = smFormulaData21;
        }else if (index == 3) {
            formulaData0 = smFormulaData30;
            formulaData1 = smFormulaData31;
        }else if (index == 4) {
            formulaData0 = smFormulaData40;
            formulaData1 = smFormulaData41;
        }
        
        if (r == g && g == b) {
            for (int i = 0; i < g_iterCount; ++i) {
                [self calcColorSingleImpl2: formulaData0[i] T2:formulaData1[i] Out1:&(mColorMap[i]) Out2:&(mColorMap2[i])];
            }
        }else{
            for (int i = 0; i < g_iterCount; ++i) {
                [self calcColorSingleImpl: formulaData0[i] T2:formulaData1[i] Out1:&(mColorMap[i]) Out2:&(mColorMap2[i])];
            }
        }
        mColorMap[g_iterCount] = (255<<24);
        mColorMap2[g_iterCount] = 0;
    }
    return self;
}

- (void)dealloc
{
    free(mBufferPtr);
    free(mColorMap);
    free(mColorMap2);
}

- (void)generatePreviewWithTexture:(ISTHandMadeUIImage*)texture
{
    PIXEL_FORMAT* rawData = [ISTColorSelection instance].previewRawData;
    size_t width = [ISTColorSelection instance].previewRawDataWidth;
    size_t height = [ISTColorSelection instance].previewRawDataHeight;
    size_t size = width * height;
    
    mPreview = [[ISTHandMadeUIImage alloc] initWithSize:CGSizeMake(width, height)];
    unsigned int* data = mPreview.buffer;
    unsigned int* textureData = texture.buffer;
    for (int i = 0; i < size; ++i) {
        unsigned int t = textureData[i];
        unsigned int c = mColorMap[rawData[i]];
        *(data+i) = 
            ((((t&0x000000ff)*(c&0x000000ff)) >> 8) << 0) + 
            (((((t&0x0000ff00)>>8)*((c&0x0000ff00)>>8)) >> 8) << 8) + 
            (((((t&0x00ff0000)>>16)*((c&0x00ff0000)>>16)) >> 8) << 16) +
            (255 << 24);
    }
    [mPreview generateUIImageFast];
}

- (ISTColorCalculator*) copy
{
    if (mFormulaIndex != smInvalidC) {
        return [[ISTColorCalculator alloc]initWithParameters2R:mParameterR G:mParameterG B:mParameterB ChangeIndex:mFormulaIndex];
    }
    return [[ISTColorCalculator alloc]initWithParametersR:mParameterR G:mParameterG B:mParameterB];
}

- (void)calcColorSingleImpl:(float)t T2:(float)t2 Out1:(unsigned int*)out1 Out2:(unsigned short*)out2
{
    float r = t*mParameterR + t2*(1.0-mParameterR);
    float g = t*mParameterG + t2*(1.0-mParameterG);
    float b = t*mParameterB + t2*(1.0-mParameterB);
    
    if (r < 0.0) {
        r = 0.0;
    }else if(r > 2.0){
        r = 2.0;
    }
    if (g < 0.0) {
        g = 0.0;
    }else if(g > 2.0){
        g = 2.0;
    }
    if (b < 0.0) {
        b = 0.0;
    }else if(b > 2.0){
        b = 2.0;
    }
    *out1 = ((int)(r*smGetRGBConst)<<0) + ((int)(g*smGetRGBConst)<<8) + ((int)(b*smGetRGBConst)<<16) + (255<<24);
    *out2 = ((int)(b*smGetRGBConst5)<<0) + ((int)(g*smGetRGBConst6)<<5) + ((int)(r*smGetRGBConst5)<<11);
}

- (void)calcColorSingleImpl2:(float)t T2:(float)t2 Out1:(unsigned int*)out1 Out2:(unsigned short*)out2
{
    float r = t*mParameterR + t2*(1.0-mParameterR);
    float g = t*mParameterG + t2*(1.0-mParameterG);
    float b = t*mParameterB + t2*(1.0-mParameterB);
    if (r < 0.0) {
        r = 0.0;
    }else if(r > 2.0){
        r = 2.0;
    }
    if (g < 0.0) {
        g = 0.0;
    }else if(g > 2.0){
        g = 2.0;
    }
    if (b < 0.0) {
        b = 0.0;
    }else if(b > 2.0){
        b = 2.0;
    }
    *out1 = ((int)(r*smGetRGBConst)<<0) + ((int)(g*smGetRGBConst)<<8) + ((int)(b*smGetRGBConst)<<16) + (255<<24);
    *out2 = ((int)(b*smGetRGBConst5)<<0) + ((int)(g*smGetRGBConst5)<<6) + ((int)(r*smGetRGBConst5)<<11);
}

- (void)calcColorImpl:(PIXEL_FORMAT) iterCount Out1:(unsigned int*)out1 Out2:(unsigned short*)out2
{
    if (g_iterCount == iterCount) {
        *out1 = (255<<24);
        *out2 = 0;
        return;
    }
    float r = (cosf(mParameterR*iterCount)+1.0f);
    float g = (cosf(mParameterG*iterCount)+1.0f);
    float b = (cosf(mParameterB*iterCount)+1.0f);
    *out1 = ((int)(r*smGetRGBConst)<<0) + ((int)(g*smGetRGBConst)<<8) + ((int)(b*smGetRGBConst)<<16) + (255<<24);
    *out2 = ((int)(b*smGetRGBConst5)<<0) + ((int)(g*smGetRGBConst6)<<5) + ((int)(r*smGetRGBConst5)<<11);
}

- (void)calcColorImpl2:(PIXEL_FORMAT) iterCount Out1:(unsigned int*)out1 Out2:(unsigned short*)out2
{
    if (g_iterCount == iterCount) {
        *out1 = (255<<24);
        *out2 = 0;
        return;
    }
    float r = (cosf(mParameterR*iterCount)+1.0f);
    *out1 = ((int)(r*smGetRGBConst)<<0) + ((int)(r*smGetRGBConst)<<8) + ((int)(r*smGetRGBConst)<<16) + (255<<24);
    *out2 = ((int)(r*smGetRGBConst5)<<0) + ((int)(r*smGetRGBConst5)<<6) + ((int)(r*smGetRGBConst5)<<11);
}

- (void)updateColorBufferWithData:(PIXEL_FORMAT *)data
{
    for (int j = 0; j < IST_TILE_SIZE; ++j) {
        int offsetJ = IST_TILE_SIZE*j;
        for (int i = 0; i < IST_TILE_SIZE; ++i) {
            PIXEL_FORMAT iterCount = *(data+offsetJ+i);
            unsigned short color = mColorMap2[iterCount]; 
            *(mBufferPtr+offsetJ+i) = color;
        }
    }
}

@end

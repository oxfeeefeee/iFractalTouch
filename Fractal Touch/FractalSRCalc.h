//
//  FractalSRCalc.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef FractalPlus_FractalSRCalc_h
#define FractalPlus_FractalSRCalc_h

#define IST_TILE_SIZE 256
#define PIXEL_FORMAT short

extern int g_iterCount;

PIXEL_FORMAT getColor(PIXEL_FORMAT iterCount);

typedef struct calcHelper
{
    PIXEL_FORMAT* data;
    int level;
    int count;
    float xyxy[8];
    int offsetoffset[4];
    int resultresult[4];
}calcHelper;


void calcHelper_addWork(calcHelper* helper, double* x, double* y, int offset);

void calcHelper_finish(calcHelper* helper);

int calcPointDouble(double x, double y);
int calcPointDoubleA6(double x, double y);
int calcPointDouble2(double x, double y);//testing

int calcPointDoubleCompiler(double x, double y);

int calcPointDoubleA8(double x, double y);

int calcPointSingle(float x, float y);

int calcPointSingleWithCount(float x, float y, int count);

void calcPointSingle4(int* results, float* dataxy4);

void srCalc(long long coordx, long long coordy, int level, long long prex, long long prey, PIXEL_FORMAT* preData, PIXEL_FORMAT* data, void* abortIndicator);

#endif

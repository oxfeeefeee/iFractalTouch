//
//  FractalSRCalc.c
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/*helper->data[offset] = calcPointDoubleCompiler(*x,*y);
 helper->data[offset] = calcPointDoubleA8(*x, *y);
 helper->data[offset] = calcPointDouble(*x, *y);
 calcPointSingle(*x, *y);
 return;*/

#include <stdio.h>
#include "math.h"
#include "string.h"
#include "FractalSRCalc.h"
#include "FractalGridCalc.h"

int g_iterCount = 256;

extern int c_isMultiCore();

void calcHelper_addWork(calcHelper* helper, double* x, double* y, int offset)
{
    if (helper->data[offset] >= 0) {
        return;
    }
    
    if (helper->level >= 17) {
        if (c_isMultiCore()) {
            //helper->data[offset] = calcPointDouble(*x, *y);
            
            //helper->data[offset] = calcPointDoubleA6(*x, *y);
            helper->data[offset] = calcPointDoubleCompiler(*x,*y);
            //helper->data[offset] = calcPointDouble2(*x, *y);
            
            //helper->data[offset] = calcPointDoubleCompiler(*x,*y);
            
            //helper->data[offset] = calcPointDouble(*x, *y);
            
            //helper->data[offset] = calcPointDoubleA8(*x, *y);
        }else{
            //helper->data[offset] = calcPointDoubleA8(*x, *y);
            helper->data[offset] = calcPointDoubleCompiler(*x, *y);
        }
        return;
    }
    
    helper->xyxy[helper->count*2] = *x;
    helper->xyxy[helper->count*2+1] = *y;
    helper->offsetoffset[helper->count] = offset;
    helper->count += 1;
    if (helper->count == 4) {
        
        helper->resultresult[0] = calcPointSingle(helper->xyxy[0], helper->xyxy[1]);
        helper->resultresult[1] = calcPointSingle(helper->xyxy[2], helper->xyxy[3]);
        helper->resultresult[2] = calcPointSingle(helper->xyxy[4], helper->xyxy[5]);
        helper->resultresult[3] = calcPointSingle(helper->xyxy[6], helper->xyxy[7]);
        
        //calcPointSingle4(helper->resultresult, helper->xyxy);
        
        
        helper->data[helper->offsetoffset[0]] = helper->resultresult[0];
        helper->data[helper->offsetoffset[1]] = helper->resultresult[1];
        helper->data[helper->offsetoffset[2]] = helper->resultresult[2];
        helper->data[helper->offsetoffset[3]] = helper->resultresult[3];
        helper->count = 0;
    }  
}

void calcHelper_finish(calcHelper* helper)
{
    for (int i = 0; i < helper->count; ++i) {
        helper->data[helper->offsetoffset[i]] = calcPointSingle(helper->xyxy[i*2], helper->xyxy[i*2+1]);
    }
    helper->count = 0;
}

void static srReusePrevious(PIXEL_FORMAT* preData, PIXEL_FORMAT* data)
{
    for (int j = 0; j < IST_TILE_SIZE/2; ++j) {
        for (int i = 0; i < IST_TILE_SIZE/2; ++i) {
            
            PIXEL_FORMAT v = preData[j*IST_TILE_SIZE+i];
            data[j*2*IST_TILE_SIZE+i*2] = v;
        }
    }
    for (int j = 1; j < IST_TILE_SIZE/2-1; ++j) {
        for (int i = 1; i < IST_TILE_SIZE/2-1; ++i) {
            PIXEL_FORMAT value = preData[(j-1)*IST_TILE_SIZE+i-1];
            if(value == preData[(j-1)*IST_TILE_SIZE+i] &&
               value == preData[(j-1)*IST_TILE_SIZE+i+1] &&
               value == preData[(j)*IST_TILE_SIZE+i-1] &&
               value == preData[(j)*IST_TILE_SIZE+i] &&
               value == preData[(j)*IST_TILE_SIZE+i+1] &&
               value == preData[(j+1)*IST_TILE_SIZE+i-1] &&
               value == preData[(j+1)*IST_TILE_SIZE+i] &&
               value == preData[(j+1)*IST_TILE_SIZE+i+1])
            {      
                if (value != g_iterCount) {
                    data[(j*2-1)*IST_TILE_SIZE+i*2] = value;
                    data[j*2*IST_TILE_SIZE+i*2-1] = value;
                    data[j*2*IST_TILE_SIZE+i*2+1] = value;
                    data[(j*2+1)*IST_TILE_SIZE+i*2] = value;
                    data[(j*2-1)*IST_TILE_SIZE+i*2-1] = value;
                    data[(j*2-1)*IST_TILE_SIZE+i*2+1] = value;
                    data[(j*2+1)*IST_TILE_SIZE+i*2-1] = value;
                    data[(j*2+1)*IST_TILE_SIZE+i*2+1] = value;
                }
            }
        }
    }

}

static void calc(double x0, double y0, double inc, PIXEL_FORMAT* data)
{
    calcHelper helper;
    helper.data = data;
    helper.count = 0;
    for (int j = 0; j < IST_TILE_SIZE; ++j) {
        for (int i = 0; i < IST_TILE_SIZE; ++i) {
            PIXEL_FORMAT value = data[j*IST_TILE_SIZE+i];
            if (value < 0) {
                double x = x0 + inc*i;
                double y = y0 + inc*j;
                calcHelper_addWork(&helper, &x, &y, j*IST_TILE_SIZE+i);
            }
        }
    }
    calcHelper_finish(&helper);
}

void static srCalcWithoutPreviousLevelData(long long coordx, long long coordy, int level, PIXEL_FORMAT* data, void* abortIndicator)
{
    gridCalc(coordx, coordy, level, data, abortIndicator);
}

void static srCalcWithPreviousLevelData(long long coordx, long long coordy, int level, PIXEL_FORMAT* preData, PIXEL_FORMAT* data, void* abortIndicator)
{
    srReusePrevious(preData, data);
    gridCalc(coordx, coordy, level, data, abortIndicator);
}

void srCalc(long long coordx, long long coordy, int level, long long prex, long long prey, PIXEL_FORMAT* preData, PIXEL_FORMAT* data, void* abortIndicator)
{
    memset(data, -1, IST_TILE_SIZE*IST_TILE_SIZE*sizeof(PIXEL_FORMAT));
    if (!preData) {
        srCalcWithoutPreviousLevelData(coordx, coordy, level, data, abortIndicator);
    }else {
        int offsetX = coordx - prex*2;
        int offsetY = coordy - prey*2;
        int halfSize = IST_TILE_SIZE / 2;
        PIXEL_FORMAT* corrctedPredata = preData+(offsetY*halfSize*IST_TILE_SIZE + offsetX*halfSize);
        srCalcWithPreviousLevelData(coordx, coordy, level, corrctedPredata, data, abortIndicator);
    }
}








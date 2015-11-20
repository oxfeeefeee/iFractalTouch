//
//  FractalGridCalc.c
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include "math.h"
#include "FractalGridCalc.h"
#import "ISTFractalTile.h"


static int sameValueOnRect(int sizex, int sizey, PIXEL_FORMAT*data)
{
    int value = data[0];
    PIXEL_FORMAT* addr = data + IST_TILE_SIZE*(sizey-1);
    for (int i = 0; i < sizex; ++i) {
        if (value != data[i]) {
            return 0;
        }
        if (value != addr[i]) {
            return 0;
        }
    }
    PIXEL_FORMAT* addrBase1 = data;
    PIXEL_FORMAT* addrBase2 = data+sizex-1;
    for (int i = 1; i < sizey-1; ++i) {
        if (value != addrBase1[IST_TILE_SIZE*i]) {
            return 0;
        }
        if (value != addrBase2[IST_TILE_SIZE*i]) {
            return 0;
        }
    }
    for (int j = 1; j < sizey-1; ++j) {
        for (int i = 1; i < sizex-1; ++i) {
            data[j*IST_TILE_SIZE+i] = value;
        }
    }
    return 1;
}


static void calcHorizontalLine_(double x0, double y0, double inc, int len, calcHelper* helper, int offset)
{
    for (int i = 0; i < len; ++i) {
        double x = x0 + (double)i*inc;
        double y = y0;
        calcHelper_addWork(helper, &x, &y, offset+i);
    }
}

static void calcVerticalLine_(double x0, double y0, double inc, int len, calcHelper* helper, int offset)
{  
    for (int i = 0; i < len; ++i) {
        double x = x0;
        double y = y0 + (double)i*inc;
        calcHelper_addWork(helper, &x, &y, offset+IST_TILE_SIZE*i);
    }
}

//compute a square, the boundary of the square is ready.
//first, check the lines one the "corss" that divides the squares into 4
static void calc_(double x0, double y0, double inc, int sizex, int sizey, calcHelper* helper, int offset, void* abortIndicator)
{
    if(((__bridge ISTFractalTile*)abortIndicator).abortComputingFlag){
        return;
    }
    
    if (sizex <= 2 || sizey <=2) {
        return;
    }
    //calcHelper_finish(helper);
    PIXEL_FORMAT* data = helper->data + offset;
    if (sameValueOnRect(sizex, sizey, data)) {
        return;
    }  
    int halfSizeX = sizex/2;
    int halfSizeY = sizey/2;
    double locOffsetX = inc*(double)halfSizeX;
    double locOffsetY = inc*(double)halfSizeY;
    calcHorizontalLine_(x0+inc, y0+locOffsetY, inc, sizex-2, helper, offset+IST_TILE_SIZE*halfSizeY+1);
    calcVerticalLine_(x0+locOffsetX, y0+inc, inc, halfSizeY-1, helper, offset+IST_TILE_SIZE+halfSizeX);
    calcVerticalLine_(x0+locOffsetX, y0+(halfSizeY+1)*inc, inc, sizey-halfSizeY-2, helper, offset+IST_TILE_SIZE*(halfSizeY+1)+halfSizeX);
    
    calc_(x0, y0, inc, halfSizeX+1, halfSizeY+1, helper, offset, abortIndicator);
    calc_(x0+locOffsetX, y0, inc, sizex-halfSizeX, halfSizeY+1, helper, offset+halfSizeX, abortIndicator);
    calc_(x0, y0+locOffsetY, inc, halfSizeX+1, sizey-halfSizeY, helper, offset+IST_TILE_SIZE*halfSizeY, abortIndicator);
    calc_(x0+locOffsetX, y0+locOffsetY, inc, sizex-halfSizeX, sizey-halfSizeY, helper, offset+IST_TILE_SIZE*halfSizeY+halfSizeX, abortIndicator);
}

void gridCalc(long long coordx, long long coordy, int level, PIXEL_FORMAT* data, void* abortIndicator)
{
    double levelTemp = pow(2.0, level);
    levelTemp = (double)IST_TILE_SIZE * 0.25 * levelTemp;
    double offset = 1.0/levelTemp;
    double x0 = coordx * IST_TILE_SIZE * offset;
    double y0 = coordy * IST_TILE_SIZE * offset;
    
    calcHelper helper;
    helper.level = level;
    helper.count = 0;
    helper.data = data;
    calcHorizontalLine_(x0, y0, offset, IST_TILE_SIZE, &helper, 0);
    calcHorizontalLine_(x0, y0+offset*(IST_TILE_SIZE-1), offset, IST_TILE_SIZE, &helper, (IST_TILE_SIZE-1)*IST_TILE_SIZE);
    calcVerticalLine_(x0, y0+offset, offset, IST_TILE_SIZE-2, &helper, IST_TILE_SIZE);
    calcVerticalLine_(x0+offset*(IST_TILE_SIZE-1), y0+offset, offset, IST_TILE_SIZE-2, &helper, IST_TILE_SIZE+IST_TILE_SIZE-1);
    calc_(x0, y0, offset, IST_TILE_SIZE, IST_TILE_SIZE, &helper, 0, abortIndicator);
    calcHelper_finish(&helper);
}
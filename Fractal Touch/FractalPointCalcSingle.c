//
//  FractalCalcPoints.c
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
/*
 vmov.32 %0, %1, d16 \n\t \
 vmov.f32 q12, q9         \n\t       \
 vmov.f32 q13, q10        \n\t       \
 vmov.f32 q14, q11        \n\t       \
 vmov.f32 q9, q2          \n\t       \
 vmov.f32 q10, q3         \n\t       \
 vmov.f32 q11, q6         \n\t       \
 vmul.f32 q4, q2, q2      \n\t      \
 vmul.f32 q5, q3, q3      \n\t         \
 vmul.f32 q6, q2, q3      \n\t      \
 vsub.f32 q2, q4, q5  \n\t              \
 vadd.f32 q2, q2, q0  \n\t              \
 vadd.f32 q3, q6, q6  \n\t           \
 vadd.f32 q3, q3, q1  \n\t           \
 vmul.f32 q4, q2, q2      \n\t      \
 vmul.f32 q5, q3, q3      \n\t         \
 vmul.f32 q6, q2, q3      \n\t      \
 vsub.f32 q2, q4, q5  \n\t              \
 vadd.f32 q2, q2, q0  \n\t              \
 vadd.f32 q3, q6, q6  \n\t           \
 vadd.f32 q3, q3, q1  \n\t           \
 vmul.f32 q4, q2, q2      \n\t      \
 vmul.f32 q5, q3, q3      \n\t         \
 vmul.f32 q6, q2, q3      \n\t      \
 vsub.f32 q2, q4, q5  \n\t              \
 vadd.f32 q2, q2, q0  \n\t              \
 vadd.f32 q3, q6, q6  \n\t           \
 vadd.f32 q3, q3, q1  \n\t           \
 vmul.f32 q4, q2, q2      \n\t      \
 vmul.f32 q5, q3, q3      \n\t         \
 vmul.f32 q6, q2, q3      \n\t      \
 vsub.f32 q2, q4, q5  \n\t              \
 vadd.f32 q2, q2, q0  \n\t              \
 vadd.f32 q3, q6, q6  \n\t           \
 vadd.f32 q3, q3, q1  \n\t           \
 vadd.f32 q6, q4, q5  \n\t         \
 vcgt.f32 q8, q6, q7  \n\t            \
 vpadd.i32 d16, d16, d17   \n\t        \
 */

/*
 vmov %0, %1, d16 \n\t \
 vmov.f32 q12, q9         \n\t       \
 vmov.f32 q13, q10        \n\t       \
 vmov.f32 q14, q11        \n\t       \
 vmov.f32 q9, q2          \n\t       \
 vmov.f32 q10, q3         \n\t       \
 vmov.f32 q11, q6         \n\t       \
 vmul.f32 d8,  d4,  d4      \n\t                           \
 vmul.f32 d10, d6,  d6      \n\t       \
 vmul.f32 d12, d4,  d6      \n\t       \
 vmul.f32 d9,  d5,  d5      \n\t       \
 vmul.f32 d11, d7,  d7      \n\t       \
 vmul.f32 d13, d5,  d7      \n\t       \
 vsub.f32 d4,  d8,  d10     \n\t       \
 vadd.f32 d6,  d12, d12     \n\t       \
 vsub.f32 d5,  d9,  d11     \n\t       \
 vadd.f32 d7,  d13, d13     \n\t       \
 vadd.f32 d4,  d4,  d0      \n\t       \
 vadd.f32 d6,  d6,  d2      \n\t       \
 vadd.f32 d5,  d5,  d1      \n\t       \
 vadd.f32 d7,  d7,  d3      \n\t                            \
 vmul.f32 d8,  d4,  d4      \n\t                           \
 vmul.f32 d10, d6,  d6      \n\t       \
 vmul.f32 d12, d4,  d6      \n\t       \
 vmul.f32 d9,  d5,  d5      \n\t       \
 vmul.f32 d11, d7,  d7      \n\t       \
 vmul.f32 d13, d5,  d7      \n\t       \
 vsub.f32 d4,  d8,  d10     \n\t       \
 vadd.f32 d6,  d12, d12     \n\t       \
 vsub.f32 d5,  d9,  d11     \n\t       \
 vadd.f32 d7,  d13, d13     \n\t       \
 vadd.f32 d4,  d4,  d0      \n\t       \
 vadd.f32 d6,  d6,  d2      \n\t       \
 vadd.f32 d5,  d5,  d1      \n\t       \
 vadd.f32 d7,  d7,  d3      \n\t                            \
 vmul.f32 d8,  d4,  d4      \n\t                           \
 vmul.f32 d10, d6,  d6      \n\t       \
 vmul.f32 d12, d4,  d6      \n\t       \
 vmul.f32 d9,  d5,  d5      \n\t       \
 vmul.f32 d11, d7,  d7      \n\t       \
 vmul.f32 d13, d5,  d7      \n\t       \
 vsub.f32 d4,  d8,  d10     \n\t       \
 vadd.f32 d6,  d12, d12     \n\t       \
 vsub.f32 d5,  d9,  d11     \n\t       \
 vadd.f32 d7,  d13, d13     \n\t       \
 vadd.f32 d4,  d4,  d0      \n\t       \
 vadd.f32 d6,  d6,  d2      \n\t       \
 vadd.f32 d5,  d5,  d1      \n\t       \
 vadd.f32 d7,  d7,  d3      \n\t                            \
 vmul.f32 d8,  d4,  d4      \n\t                           \
 vmul.f32 d10, d6,  d6      \n\t       \
 vmul.f32 d12, d4,  d6      \n\t       \
 vmul.f32 d9,  d5,  d5      \n\t       \
 vmul.f32 d11, d7,  d7      \n\t       \
 vmul.f32 d13, d5,  d7      \n\t       \
 vsub.f32 d4,  d8,  d10     \n\t       \
 vadd.f32 d6,  d12, d12     \n\t       \
 vsub.f32 d5,  d9,  d11     \n\t       \
 vadd.f32 d7,  d13, d13     \n\t       \
 vadd.f32 d4,  d4,  d0      \n\t       \
 vadd.f32 d6,  d6,  d2      \n\t       \
 vadd.f32 d5,  d5,  d1      \n\t       \
 vadd.f32 d7,  d7,  d3      \n\t                            \
 vadd.f32 q6, q4, q5  \n\t         \
 vcgt.f32 q8, q6, q7  \n\t            \
 vpadd.i32 d16, d16, d17   \n\t        \
 */

#include <stdio.h>

#include "FractalSRCalc.h"

int calcPointSingle(float x0, float y0)
{
    int count = g_iterCount;
    float xxxx, x, y;
    xxxx = x = y = 0.f;
    while (!(!count || xxxx > 4.0f))
    {
        float txx = x*x;
        float tyy = y*y;
        y = 2.0f*x*y + y0;
        x =  txx - tyy + x0;
        xxxx = txx + tyy;
        --count;
    }
    return g_iterCount - count;
}

int calcPointSingleWithCount(float x0, float y0, int c)
{
    /*
    int count = c;
    float xxxx, x, y;
    xxxx = x = y = 0.f;
    while (!(!count || xxxx > 4.0f))
    {
        float txx = x*x;
        float tyy = y*y;
        y = 2.0f*x*y + y0;
        x =  txx - tyy + x0;
        xxxx = txx + tyy;
        --count;
    }
    return c - count;
}

void calcPointSingle4(int* results, float* dataxy4)
{
    float x0 = dataxy4[0];
    float y0 = dataxy4[1];
    float x1 = dataxy4[2];
    float y1 = dataxy4[3];
    float x2 = dataxy4[4];
    float y2 = dataxy4[5];
    float x3 = dataxy4[6];
    float y3 = dataxy4[7];
    __asm__ __volatile__(
                         "\
                         vmov d0, %0, %1     \n\t               \
                         vmov d1, %2, %3      \n\t               \
                         vmov d2, %4, %5     \n\t               \
                         vmov d3, %6, %7      \n\t               \
                         vmov.f32 q2, #0.0   \n\t            \
                         vmov.f32 q3, #0.0   \n\t            \
                         vmov.f32 q6, #0.0   \n\t            \
                         vmov.f32 q7, #4.0   \n\t            \
                         vmov.f32 q8, #0.0   \n\t            \
                         "
                         :
                         :"r"(x0), "r"(x1),"r"(x2), "r"(x3),"r"(y0), "r"(y1),"r"(y2), "r"(y3)
                         :"q0","q1", "q2", "q3", "q6", "q7", "q8"
                         );
    
    int count = g_iterCount + 4;
    int done1, done2;
    for (;;) {
        __asm__ __volatile__(
                             "\
                             vmov %0, %1, d16 \n\t \
                             vmov.f32 q12, q9         \n\t       \
                             vmov.f32 q13, q10        \n\t       \
                             vmov.f32 q14, q11        \n\t       \
                             vmov.f32 q9, q2          \n\t       \
                             vmov.f32 q10, q3         \n\t       \
                             vmov.f32 q11, q6         \n\t       \
                             vmul.f32 q4, q2, q2      \n\t      \
                             vmul.f32 q5, q3, q3      \n\t         \
                             vmul.f32 q6, q2, q3      \n\t      \
                             vsub.f32 q2, q4, q5  \n\t              \
                             vadd.f32 q2, q2, q0  \n\t              \
                             vadd.f32 q3, q6, q6  \n\t           \
                             vadd.f32 q3, q3, q1  \n\t           \
                             vmul.f32 q4, q2, q2      \n\t      \
                             vmul.f32 q5, q3, q3      \n\t         \
                             vmul.f32 q6, q2, q3      \n\t      \
                             vsub.f32 q2, q4, q5  \n\t              \
                             vadd.f32 q2, q2, q0  \n\t              \
                             vadd.f32 q3, q6, q6  \n\t           \
                             vadd.f32 q3, q3, q1  \n\t           \
                             vmul.f32 q4, q2, q2      \n\t      \
                             vmul.f32 q5, q3, q3      \n\t         \
                             vmul.f32 q6, q2, q3      \n\t      \
                             vsub.f32 q2, q4, q5  \n\t              \
                             vadd.f32 q2, q2, q0  \n\t              \
                             vadd.f32 q3, q6, q6  \n\t           \
                             vadd.f32 q3, q3, q1  \n\t           \
                             vmul.f32 q4, q2, q2      \n\t      \
                             vmul.f32 q5, q3, q3      \n\t         \
                             vmul.f32 q6, q2, q3      \n\t      \
                             vsub.f32 q2, q4, q5  \n\t              \
                             vadd.f32 q2, q2, q0  \n\t              \
                             vadd.f32 q3, q6, q6  \n\t           \
                             vadd.f32 q3, q3, q1  \n\t           \
                             vadd.f32 q6, q4, q5  \n\t         \
                             vcgt.f32 q8, q6, q7  \n\t            \
                             vpadd.i32 d16, d16, d17   \n\t        \
                             "
                             :"=r"(done1), "=r"(done2)
                             :
                             :"q0", "q1", "q2", "q3", "q4", "q5","q6", "q7", "q8", "q9", "q10", "q11", "q12", "q13", "q14"
                             );
        count-=4;
        if(!count || done1|done2)
            break;
    }  
    
    float tx0, tx1, tx2, tx3, ty0, ty1, ty2, ty3, result0, result1, result2, result3;
    __asm__ __volatile__(
                         "\
                         vmov %0, %1, d24     \n\t       \
                         vmov %2, %3, d25     \n\t       \
                         vmov %4, %5, d26     \n\t       \
                         vmov %6, %7, d27     \n\t       \
                         vmov %8, %9, d28     \n\t       \
                         vmov %10, %11, d29   \n\t       \
                         "           
                         :"=r"(tx0), "=r"(tx1),"=r"(tx2), "=r"(tx3), "=r"(ty0), "=r"(ty1),"=r"(ty2), "=r"(ty3), "=r"(result0), "=r"(result1),"=r"(result2), "=r"(result3)
                         :
                         :);
    
    int count0, count1, count2, count3 ;
    count0 = count1 = count2 = count3 = count + 4;
    
    while (!(!count0 || result0 > 4.0f))
    {
        float txx = tx0*tx0;
        float tyy = ty0*ty0;
        ty0 = 2*tx0*ty0 + y0;
        tx0 =  txx - tyy + x0;
        result0 = txx + tyy;
        --count0;
    };
    results[0] = g_iterCount - count0;
    while (!(!count1 || result1 > 4.0f))
    {
        float txx = tx1*tx1;
        float tyy = ty1*ty1;
        ty1 = 2*tx1*ty1 + y1;
        tx1 = txx - tyy + x1;
        result1 = txx + tyy;
        --count1;
    }
    results[1] = g_iterCount - count1;
    while (!(!count2 || result2 > 4.0f))
    {
        float txx = tx2*tx2;
        float tyy = ty2*ty2;
        ty2 = 2*tx2*ty2 + y2;
        tx2 = txx - tyy + x2;
        result2 = txx + tyy;
        --count2;
    }
    results[2] = g_iterCount - count2;
    while (!(!count3 || result3 > 4.0f))
    {
        float txx = tx3*tx3;
        float tyy = ty3*ty3;
        ty3 = 2*tx3*ty3 + y3;
        tx3 = txx - tyy + x3;
        result3 = txx + tyy;
        --count3;
    }
    results[3] = g_iterCount - count3;
     */return 0;
}
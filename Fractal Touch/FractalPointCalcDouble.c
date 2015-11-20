//
//  FractalPointCalc.c
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//
/* pre-optimization
 vmov.32 %0, d25[1]      \n\t \
 vqadd.s64 d2, d23, d26  \n\t \
 vqadd.s64 d3, d24, d26  \n\t \
 vand d4, d2, d27       \n\t \
 vand d5, d3, d27       \n\t \
 vshr.s64 d6, d2, #28  \n\t \
 vshr.s64 d7, d3, #28   \n\t \
 vqmovn.u64 d8, q2      \n\t \
 vqmovn.u64 d9, q3      \n\t \
 vqsub.s32 d9, d28       \n\t \
 vrev64.s32 d10, d9     \n\t \
 vmull.s32 q6, d9, d10 \n\t \
 vmull.s32 q7, d9, d9  \n\t \
 vmull.s32 q8, d8, d10 \n\t \
 vmull.s32 q9, d8, d9  \n\t \
 vshr.s64 d16, #28     \n\t \
 vshr.s64 d17, #28     \n\t \
 vshr.s64 d18, #28     \n\t \
 vshr.s64 d19, #28     \n\t \
 vqadd.s64 d20, d16, d17 \n\t \
 vqadd.s64 d20, d12    \n\t \
 vqadd.s64 d21, d18, d18 \n\t \
 vqadd.s64 d21, d14    \n\t \
 vqadd.s64 d22, d19, d19 \n\t \
 vqadd.s64 d22, d15    \n\t \
 vqsub.s64 d23, d21, d22 \n\t \
 vqadd.s64 d23, d0     \n\t \
 vqadd.s64 d24, d20, d20 \n\t  \
 vqadd.s64 d24, d1     \n\t \
 vqadd.s64 d25, d21, d22 \n\t \
 vqsub.s64 d25, d29    \n\t \
*/


#include <stdio.h>
#include "math.h"
#include "FractalSRCalc.h"
//add turns the values to positive
//then splite them into two parts
int calcPointDoubleA8(double x0, double y0)
{
    /*
    long long addImm = 0x0600000000000000;
    long long andImm = 0x000000000fffffff;
    long long subImm = 0x6000000060000000;
    long long four = 4ll << 56;
    
    long long a = x0 * pow(2.0, 56);
    long long b = y0 * pow(2.0, 56);
    __asm__ __volatile__(
                         "\
                         vldr.64 d0, [%0]     \n\t               \
                         vldr.64 d1, [%1]     \n\t               \
                         vldr.64 d26, [%2]    \n\t               \
                         vldr.64 d27, [%3]    \n\t               \
                         vldr.64 d28, [%4]    \n\t               \
                         vldr.64 d29, [%5]    \n\t               \
                         vmov.f32 d23, #0.0   \n\t               \
                         vmov.f32 d24, #0.0   \n\t               \
                         vmov.f32 d25, #0.0   \n\t               \
                         vqsub.s64 d25, d25, d29    \n\t              \
                         "           
                         :
                         :"r"(&a), "r"(&b), "r"(&addImm), "r"(&andImm), "r"(&subImm), "r"(&four)
                         :"q0","q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10", "q11", "q12", "q13", "q14"
                         );
    int count = g_iterCount + 1;
    int result = -1;
    for (;;) {
        
        __asm__ __volatile__(
                             "\
                             vmov.32 %0, d25[1]      \n\t \
                             vqadd.s64 d2, d23, d26  \n\t \
                             vqadd.s64 d3, d24, d26  \n\t \
                             vand d4, d2, d27       \n\t \
                             vand d5, d3, d27       \n\t \
                             vshr.s64 d6, d2, #28  \n\t \
                             vshr.s64 d7, d3, #28   \n\t \
                             vqmovn.u64 d8, q2      \n\t \
                             vqmovn.u64 d9, q3      \n\t \
                             vqsub.s32 d9, d9, d28       \n\t \
                             vrev64.s32 d10, d9     \n\t \
                             vmull.s32 q6, d9, d10 \n\t \
                             vmull.s32 q7, d9, d9  \n\t \
                             vmull.s32 q8, d8, d10 \n\t \
                             vmull.s32 q9, d8, d9  \n\t \
                             vshr.s64 d16, #28     \n\t \
                             vshr.s64 d17, #28     \n\t \
                             vshr.s64 d18, #28     \n\t \
                             vshr.s64 d19, #28     \n\t \
                             vqadd.s64 d20, d16, d17 \n\t \
                             vqadd.s64 d21, d18, d18 \n\t \
                             vqadd.s64 d22, d19, d19 \n\t \
                             vqadd.s64 d20, d12    \n\t \
                             vqadd.s64 d21, d14    \n\t \
                             vqadd.s64 d22, d15    \n\t \
                             vqsub.s64 d23, d21, d22 \n\t \
                             vqadd.s64 d24, d20, d20 \n\t  \
                             vqadd.s64 d25, d21, d22 \n\t \
                             vqadd.s64 d23, d0     \n\t \
                             vqadd.s64 d24, d1     \n\t \
                             vqsub.s64 d25, d25, d29    \n\t \
                             "
                             :"=r"(result)
                             :
                             :"q0","q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10", "q11", "q12", "q13", "q14"
                             );

        --count;
        if(!count)
            break;
        if(result >= 0)
            break;
    }
    return g_iterCount - count;
     */return 0;
}

int calcPointDouble(double x0, double y0)
{
    /*
    __asm__ __volatile__(
                         "\
                         vldr.64 d0, [%0]     \n\t               \
                         vldr.64 d1, [%1]     \n\t               \
                         vmov.f32 d2, #0.0   \n\t            \
                         vmov.f32 d3, #0.0   \n\t            \
                         vmov.f32 d6, #0.0   \n\t            \
                         vmov.f64 d7, #4.0   \n\t            \
                         vmov.f32 d8, #0.0   \n\t            \
                         vcmp.f64 d6, d7     \n\t            \
                         "           
                         :
                         :"r"(&x0), "r"(&y0)
                         :"q0","q1", "q2", "q3", "q6", "q7", "q8"
                         );
    int count = g_iterCount + 1;
    int fpscr;
    for (;;) {
        __asm__ __volatile__(
                             "\
                             vmrs %0,fpscr         \n\t \
                             vmul.f64 d4, d2, d2      \n\t      \
                             vmul.f64 d5, d3, d3      \n\t         \
                             vmul.f64 d6, d2, d3      \n\t      \
                             vsub.f64 d2, d4, d5  \n\t              \
                             vadd.f64 d2, d2, d0  \n\t              \
                             vadd.f64 d3, d6, d6  \n\t           \
                             vadd.f64 d3, d3, d1  \n\t           \
                             vadd.f64 d6, d4, d5  \n\t         \
                             vcmp.f64 d6, d7     \n\t            \
                             "
                             :"=r"(fpscr)
                             :
                             :"q0", "q1", "q2", "q3", "q4", "q5","q6", "q7", "q8", "q9", "q10", "q11"
                             );
        --count;
        if(!count)
            break;
        if((fpscr&0xF0000000) == 0x20000000)
            break;
    }
    return g_iterCount - count;
     */
    return 0;
}

int calcPointDoubleA6(double x0, double y0)
{
    int count = g_iterCount;
    double xxxx, x, y;
    xxxx = x = y = 0.0;
    while (count && xxxx <= 4.0)
    {
        double txx = x*x;
        double tyy = y*y;
        y = 2.0*x*y + y0;
        x =  txx - tyy + x0;
        xxxx = txx + tyy;
        --count;
    }
    return g_iterCount - count;
}

/*
 vmul.f64 d4, d2, d2 \n\t \
 vadd.f64 d2, d2, d2 \n\t \
 vmul.f64 d5, d3, d3 \n\t \
 vmul.f64 d3, d2, d3 \n\t \
 vsub.f64 d2, d4, d5 \n\t \
 vadd.f64 d5, d4, d5 \n\t \
 vadd.f64 d2, d2, d0 \n\t \
 vcmpe.f64 d5, d7 \n\t \
 vadd.f64 d3, d3, d1 \n\t \
 */

int calcPointDouble2(double x0, double y0)
{
    /*
    __asm__ __volatile__(
                         "\
                         vldr.64 d0, [%0]     \n\t               \
                         vldr.64 d1, [%1]     \n\t               \
                         vmov.f32 d2, #0.0   \n\t            \
                         vmov.f32 d3, #0.0   \n\t            \
                         vmov.f32 d6, #0.0   \n\t            \
                         vmov.f64 d7, #4.0   \n\t            \
                         vmov.f32 d8, #0.0   \n\t            \
                         vcmp.f64 d6, d7     \n\t            \
                         "
                         :
                         :"r"(&x0), "r"(&y0)
                         :"q0","q1", "q2", "q3", "q6", "q7", "q8"
                         );
    int count = g_iterCount + 1;
    int fpscr;
    do {
        __asm__ __volatile__(
                             "\
                             vmrs %0,fpscr         \n\t \
                             vmul.f64 d4, d2, d2 \n\t \
                             vadd.f64 d2, d2, d2 \n\t \
                             vmul.f64 d5, d3, d3 \n\t \
                             vmul.f64 d3, d2, d3 \n\t \
                             vsub.f64 d2, d4, d5 \n\t \
                             vadd.f64 d5, d4, d5 \n\t \
                             vadd.f64 d2, d2, d0 \n\t \
                             vcmpe.f64 d5, d7 \n\t \
                             vadd.f64 d3, d3, d1 \n\t \
                             "
                             :"=r"(fpscr)
                             :
                             :"q0", "q1", "q2", "q3", "q4", "q5","q6", "q7", "q8", "q9", "q10", "q11"
                             );
        count-=1;
    }while(count && (fpscr&0xF0000000) != 0x20000000);
    
    return g_iterCount - count;
     */return 0;
}

int calcPointDoubleCompiler(double x0, double y0)
{
    int count = g_iterCount;
    double xxxx, x, y;
    xxxx = x = y = 0.0;
    while (count && xxxx <= 4.0)
    {
        double txx = x*x;
        double tyy = y*y;
        y = 2.0*x*y + y0;
        x =  txx - tyy + x0;
        xxxx = txx + tyy;
        --count;
    }
    return g_iterCount - count;
}


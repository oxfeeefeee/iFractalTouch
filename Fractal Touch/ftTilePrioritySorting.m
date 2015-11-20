//
//  ftTilePrioritySorting.m
//  Fractal Touch
//
//  Created by On Mac No5 on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ftTilePrioritySorting.h"

@implementation ftTileSortingProxy

@synthesize x = mX;
@synthesize y = mY;
@synthesize distance = mDistance;

@end


@interface ftTilePrioritySorting()

@property NSMutableArray* freeProxies;
@property NSMutableArray* workingProxies;

- (ftTileSortingProxy*)getFreeProxy;

@end


@implementation ftTilePrioritySorting

@synthesize freeProxies = mFreeProxies;
@synthesize workingProxies = mWorkingProxies;
static ftTilePrioritySorting *sInstance = NULL;

+ (ftTilePrioritySorting *)instance
{
    @synchronized(self)
    {
        if (sInstance == NULL){
            sInstance = [[self alloc] init];
        }
    }
    return(sInstance);
}

- (ftTilePrioritySorting*)init
{
    if (self = [super init]) {
        mFreeProxies = [[NSMutableArray alloc]init];
        mWorkingProxies = [[NSMutableArray alloc]init];
    }
    return self;
}

- (ftTileSortingProxy*)getFreeProxy
{
    if ([mFreeProxies count] > 0) {
        ftTileSortingProxy* p = [mFreeProxies lastObject];
        [mFreeProxies removeLastObject];
        return p;
    }
    return [[ftTileSortingProxy alloc]init];
}

- (void)begin
{
    [mFreeProxies addObjectsFromArray:mWorkingProxies];
    [mWorkingProxies removeAllObjects];
}

- (void) addTileCoordX:(long long)x andY:(long long)y andCX:(double)cx andCY:(double)cy
{
    ftTileSortingProxy* p = [self getFreeProxy];
    p.x = x;
    p.y = y;
    p.distance = (cx-0.5 - (double)x) * (cx-0.5 - (double)x) + (cy-0.5 - (double)y) * (cy-0.5 - (double)y);
    [mWorkingProxies addObject:p];
}

- (NSMutableArray*)sortAndEnd
{
    [mWorkingProxies sortUsingComparator:^NSComparisonResult(id p1, id p2) {
        ftTileSortingProxy* proxy1 = (ftTileSortingProxy*)p1;
        ftTileSortingProxy* proxy2 = (ftTileSortingProxy*)p2;
        if (proxy1.distance > proxy2.distance) {
            return NSOrderedAscending;
        }else {
            return NSOrderedDescending;
        }
    }];
    return mWorkingProxies;
}

@end

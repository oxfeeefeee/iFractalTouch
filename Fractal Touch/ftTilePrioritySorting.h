//
//  ftTilePrioritySorting.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ftTileSortingProxy : NSObject

@property long long x;
@property long long y;
@property double distance;

@end


@interface ftTilePrioritySorting : NSObject

- (void) begin;

- (void) addTileCoordX:(long long)x andY:(long long)y andCX:(double)cx andCY:(double)cy;

- (NSMutableArray*) sortAndEnd;

+ (ftTilePrioritySorting*)instance;

@end

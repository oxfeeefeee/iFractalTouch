//
//  ShaderSource.h
//  Fractal Touch
//
//  Created by On Mac No5 on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShaderSource : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * im;
@property (nonatomic, retain) NSString * re;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * zomming;
@property (nonatomic, retain) NSNumber * colorIndex;
@property (nonatomic, retain) NSNumber * iterCountIndex;

@end

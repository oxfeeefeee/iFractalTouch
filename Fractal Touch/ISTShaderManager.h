//
//  ISTShaderManager.h
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    DataFetchTypeAllShaders,
    DataFetchTypeFavorites,
    DataFetchTypeAddingFavorites,
} DataFetchType;

@interface ISTShaderManager : NSObject

@property (nonatomic, strong, readonly) NSString *dataPath;

- (void)getFetchedResultControllerWithType:(DataFetchType)type completionHandler:(void (^)(NSFetchedResultsController *controller))handler;

- (void)addBookmark:(NSString*)re im:(NSString*)im zooming:(NSString*)zooming colorIndex:(int)colorIndex textureIndex:(int)textureIndex iterIndex:(int)iterIndex thumbnail:(NSData*)thumbnail;

- (void)save;

- (void)deleteDatabaseFile;

+ (ISTShaderManager*)instance;

@end

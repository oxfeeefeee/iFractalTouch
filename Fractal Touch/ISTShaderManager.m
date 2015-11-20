//
//  ISTShaderManager.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTShaderManager.h"
#import "ISTShaderManager+WriteDefaultData.h"
#import "ShaderSource.h"
#import "ISTColorSelection.h"
#import "ISTIterationSelection.h"
#import "ftTextureSelection.h"

@interface ISTShaderManager()

@property (nonatomic, strong) UIManagedDocument *shaderDatabase;

@end


@implementation ISTShaderManager


@synthesize shaderDatabase = mShaderDatabase;
static ISTShaderManager *gInstance = NULL;
static NSString *dbPath = @"DefaultShaderDatabase";

+ (ISTShaderManager *)instance
{
    @synchronized(self)
    {
        if (gInstance == NULL){
            gInstance = [[self alloc] init];
        }
    }
    return(gInstance);
}

- (NSString*) dataPath
{
    return @"";
}

- (UIManagedDocument *)shaderDatabase
{
    if (!mShaderDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:dbPath];
        mShaderDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create 
    }
    return mShaderDatabase;
}

- (NSFetchedResultsController *)createFetchedResultsControllerForAllShaders
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FractalBookmark"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)]];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.shaderDatabase.managedObjectContext
                                                 sectionNameKeyPath:nil/*@"type"*/
                                                          cacheName:nil];
}

- (NSFetchedResultsController *)createFetchedResultsControllerForFavorites
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FractalBookmark"];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"favorite" ascending:YES selector:@selector(compare:)],
                               [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(compare:)],
                               
                               nil];
    request.predicate = [NSPredicate predicateWithFormat:@"favorite >= 0"];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.shaderDatabase.managedObjectContext
                                                 sectionNameKeyPath:nil/*@"type"*/
                                                          cacheName:nil];
} 

- (NSFetchedResultsController *)createFetchedResultsControllerForAddingFavorites
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FractalBookmark"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"favorite < 0"];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.shaderDatabase.managedObjectContext
                                                 sectionNameKeyPath:nil/*@"type"*/
                                                          cacheName:nil];
}

- (NSFetchedResultsController *)createFetchedResultsControllerWithType:(DataFetchType)type
{
    if (type == DataFetchTypeAllShaders) {
        return [self createFetchedResultsControllerForAllShaders];
    }
    else if(type == DataFetchTypeFavorites){
        return [self createFetchedResultsControllerForFavorites];
    }
    else if(type == DataFetchTypeAddingFavorites){
        return [self createFetchedResultsControllerForAddingFavorites];
    }
    return nil;
}

- (NSURL*) getDBFileDirURL
{
    return [self.shaderDatabase.fileURL URLByAppendingPathComponent:@"StoreContent"];
}

- (void)getFetchedResultControllerWithType:(DataFetchType)type completionHandler:(void (^)(NSFetchedResultsController *controller))handler
{
    UIManagedDocument *database = self.shaderDatabase;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[self.getDBFileDirURL URLByAppendingPathComponent:@"persistentStore"] path]]) {
        
        // COPY FROM BUNDLE
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        
        NSURL *url = [self getDBFileDirURL];
        NSString* urlStr = [url absoluteString];
        if(![[NSFileManager defaultManager] fileExistsAtPath:urlStr]){
            [fileManager createDirectoryAtURL: url withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        if(error)
            NSLog(@"create directory error: %@",error);
        
        NSURL *DB = [url URLByAppendingPathComponent:@"persistentStore"];
        NSURL *shippedDB = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"defaultDB"];
        //NSLog(@"%d",[fileManager fileExistsAtPath:[shippedDB absoluteString]]);
        [fileManager copyItemAtURL:shippedDB toURL:DB error:&error];
        
        if (error)
            NSLog(@"Copy error %@",error);
        
        [database openWithCompletionHandler:^(BOOL success) {
            handler([self createFetchedResultsControllerWithType:type]);
        }];
        
        /* // does not exist on disk, so create it
        [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            handler([self createFetchedResultsControllerWithType:type]);
            [self writeDefaultDataIntoDocument:database];
            
        }];
         */
    } else if (database.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [database openWithCompletionHandler:^(BOOL success) {
            handler([self createFetchedResultsControllerWithType:type]);
        }];
    } else if (database.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        handler([self createFetchedResultsControllerWithType:type]);
    }
    else {
        handler(nil);
    }
}

- (void)addBookmark:(NSString*)re im:(NSString*)im zooming:(NSString*)zooming  colorIndex:(int)colorIndex textureIndex:(int)textureIndex iterIndex:(int)iterIndex thumbnail:(NSData*)thumbnail
{
    UIManagedDocument *database = self.shaderDatabase;
    ShaderSource *shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:database.managedObjectContext];
    shader.im = im;
    shader.re = re;
    shader.zomming = zooming;
    shader.thumbnail = thumbnail;
    shader.date = [NSDate dateWithTimeIntervalSinceNow: 0];
    shader.colorIndex = [[NSNumber alloc] initWithUnsignedInteger: (colorIndex & 0x0000ffff) + (textureIndex << 16)];
    shader.iterCountIndex = [[NSNumber alloc] initWithUnsignedInt: iterIndex];
    [self save];
}

- (void)save
{
    UIManagedDocument *database = self.shaderDatabase;
    if (database.documentState == UIDocumentStateNormal) {
        [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }
}
/*
 NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 url = [url URLByAppendingPathComponent:dbPath];
 url = [url URLByAppendingPathComponent:dbFileNameV1];
 */

- (void)deleteDatabaseFile
{
    UIManagedDocument *database = self.shaderDatabase;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[database.fileURL path]]) 
    {
        if(database.documentState == UIDocumentStateNormal)
        {
            [database closeWithCompletionHandler:^(BOOL success) {
                [[NSFileManager defaultManager] removeItemAtURL:database.fileURL error:nil];
            }];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtURL:database.fileURL error:nil];
        }
        mShaderDatabase = nil;
    }
}

@end

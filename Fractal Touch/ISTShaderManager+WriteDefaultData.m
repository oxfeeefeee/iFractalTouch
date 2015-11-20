    //
//  ISTShaderManager+WriteDefaultData.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTShaderManager+WriteDefaultData.h"
#import "ShaderSource.h"

@implementation ISTShaderManager (WriteDefaultData)

- (void) writeDefaultDataIntoDocument:(UIManagedDocument *)document
{
 /*
    ShaderSource *shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];
    shader.im = @"0.22221";
    shader.re = @"0.22222";
    shader.zomming = @"0.22223";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.22224";
    shader.re = @"0.22225";
    shader.zomming = @"0.22226";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.22224";
    shader.re = @"0.22228";
    shader.zomming = @"0.22229";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.22220";
    shader.re = @"0.22221";
    shader.zomming = @"0.22222";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.22223";
    shader.re = @"0.22224";
    shader.zomming = @"0.22225";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.2222";
    shader.re = @"0.2222";
    shader.zomming = @"0.2222";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.2222";
    shader.re = @"0.2222";
    shader.zomming = @"0.2222";
    
    shader = [NSEntityDescription insertNewObjectForEntityForName:@"FractalBookmark" inManagedObjectContext:document.managedObjectContext];	
    shader.im = @"0.2222";
    shader.re = @"0.2222";
    shader.zomming = @"0.2222";
    
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
  */
     
    if(![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]])
    {
        // COPY FROM BUNDLE
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *DB = [[paths lastObject] stringByAppendingPathComponent:@"defaultDB"];
        DB = [DB stringByAppendingPathComponent:@"StoreContent"];
        
        [fileManager createDirectoryAtPath:DB withIntermediateDirectories:YES attributes:nil error:&error];
        
        NSLog(@"create directory error: %@",error);
        
        DB = [DB stringByAppendingPathComponent:@"persistentStore"];
        
        NSString *shippedDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"persistentStore"];
        NSLog(@"%d",[fileManager fileExistsAtPath:shippedDB]);
        [fileManager copyItemAtPath:shippedDB toPath:DB error:&error];
        
        NSLog(@"Copy error %@",error);
    }
}

@end

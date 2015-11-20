//
//  ISTViewController.h
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "ISTShaderManager.h"

@interface ISTTableViewController : CoreDataTableViewController

@property (nonatomic, readonly) DataFetchType dataFetchType;

@end

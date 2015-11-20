//
//  ISTAddToFavoritesViewController.h
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTTableViewController.h"

@interface ISTAddToFavoritesViewController : ISTTableViewController

@property (nonatomic, strong) NSNumber *nextFavoriteValue;

- (IBAction)cancel:(id)sender;

@end

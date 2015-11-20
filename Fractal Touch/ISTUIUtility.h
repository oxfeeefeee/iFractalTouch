//
//  ISTUIUtility.h
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ISTUIUtility : NSObject<UITabBarControllerDelegate>

+ (ISTUIUtility*)instance;

// get the 'right' destination view controller, return the first child if it's a UINavigationController
+ (id)getDestControllerOfSegue:(UIStoryboardSegue*)segue;

@end

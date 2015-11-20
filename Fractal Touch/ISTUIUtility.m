//
//  ISTUIUtility.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTUIUtility.h"

static ISTUIUtility *gInstance = NULL;


@implementation ISTUIUtility

+ (ISTUIUtility *)instance
{
    @synchronized(self)
    {
        if (gInstance == NULL)
            gInstance = [[self alloc] init];
    }
    return(gInstance);
}

+ (id)getDestControllerOfSegue:(UIStoryboardSegue*)segue
{
    if([segue.destinationViewController isKindOfClass:[UINavigationController class]])
    {
        return ((UINavigationController*)segue.destinationViewController).viewControllers.lastObject;
    }else{
        return segue.destinationViewController;
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController*)viewController;
        //[navController popToRootViewControllerAnimated:NO];
        [navController popViewControllerAnimated:NO];
    }
}

@end

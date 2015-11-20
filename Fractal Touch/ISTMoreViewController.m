//
//  ISTMoreViewController.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTMoreViewController.h"
#import "ISTShaderManager.h"
#import "ISTUtility.h"
#import "ftGlobalStates.h"

@implementation ISTMoreViewController

@synthesize resetButton = mResetButton;
static NSString *resetActionTitle = @"This will restore default data and settings, all changes you made will be lost.";
static NSString* sViewSegueID = @"view";

- (DataFetchType) dataFetchType
{
    return DataFetchTypeAllShaders;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startPlay)];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ftGlobalStates instance].jumpToBuyTag != nil) {
        [self performSegueWithIdentifier:[ftGlobalStates instance].jumpToBuyTag sender:self];
        [ftGlobalStates instance].jumpToBuyTag = nil;
    }
    
}

- (void)startPlay
{
    [self performSegueWithIdentifier:sViewSegueID sender:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView cellForRowAtIndexPath:indexPath] == mResetButton)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:resetActionTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Erase All" otherButtonTitles:nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    [mResetButton setSelected:NO];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:resetActionTitle])
    {
        if(buttonIndex == 0)
        {
            [ISTShaderManager.instance deleteDatabaseFile];
        }
    }
}

@end

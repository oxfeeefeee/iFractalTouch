//
//  ISTFullListViewController.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTFullListViewController.h"
#import "ShaderSource.h"

@interface ISTFullListViewController()

@property (nonatomic,strong) ShaderSource* toBeDeletedObject;

@end

@implementation ISTFullListViewController

@synthesize toBeDeletedObject = mToBeDeletedObject;
static NSString *deleteActionTitle = @"Are you sure to delete this bookmark?";

- (DataFetchType) dataFetchType
{
    return DataFetchTypeAllShaders;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startPlay)];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEditing:NO animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIDeviceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    mToBeDeletedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:deleteActionTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString: deleteActionTitle])
    {
        if(buttonIndex == 0 && mToBeDeletedObject)
        {
            [self.fetchedResultsController.managedObjectContext deleteObject:mToBeDeletedObject];
            [ISTShaderManager.instance save];
        }
    }
    mToBeDeletedObject = nil;
}


@end

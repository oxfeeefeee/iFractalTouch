//
//  ISTFavoritesViewController.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTFavoritesViewController.h"
#import "ShaderSource.h"
#import "ISTAddToFavoritesViewController.h"
#import "ISTUIUtility.h"

@implementation ISTFavoritesViewController

static NSString* showAllToAddSegueID = @"show all to add";
static NSString* sViewSegueID = @"view";

- (DataFetchType) dataFetchType
{
    return DataFetchTypeFavorites;
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
        //save data
        [ISTShaderManager.instance save];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([segue.identifier isEqualToString:showAllToAddSegueID])
    {
        id lastFav = self.fetchedResultsController.fetchedObjects.lastObject;
        int nextFavValue = 0;
        if (lastFav) {
            nextFavValue = ((ShaderSource*)lastFav).favorite.integerValue + 1;
        }
        ISTAddToFavoritesViewController* destVC = (ISTAddToFavoritesViewController*)[ISTUIUtility getDestControllerOfSegue:segue];
        destVC.nextFavoriteValue = [NSNumber numberWithInt:nextFavValue];
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

- (NSIndexPath *)tableView:(UITableView *)tableView 
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if(proposedDestinationIndexPath.row >= self.fetchedResultsController.fetchedObjects.count)
    {
        return sourceIndexPath;
    }
    return [super tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShaderSource *shaderSource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    shaderSource.favorite = [NSNumber numberWithInt:-1];
    [ISTShaderManager.instance save];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // we have only one section
    NSInteger section = fromIndexPath.section;
    
    ShaderSource *movingObj = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    ShaderSource *destObj = [self.fetchedResultsController objectAtIndexPath:toIndexPath];
    movingObj.favorite = [NSNumber numberWithInt:destObj.favorite.integerValue];
    if(fromIndexPath.row > toIndexPath.row){
        for (int i = fromIndexPath.row - 1; i >= toIndexPath.row; --i) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:i inSection:section];
            ShaderSource *shaderSource = [self.fetchedResultsController objectAtIndexPath:cellPath];
            shaderSource.favorite = [NSNumber numberWithInt:(shaderSource.favorite.integerValue + 1)];
        }
    }
    else if(fromIndexPath.row < toIndexPath.row){
        for (int i = fromIndexPath.row + 1; i <= toIndexPath.row; ++i) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:i inSection:section];
            ShaderSource *shaderSource = [self.fetchedResultsController objectAtIndexPath:cellPath];
            shaderSource.favorite = [NSNumber numberWithInt:(shaderSource.favorite.integerValue - 1)];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= self.fetchedResultsController.fetchedObjects.count){
        
        static NSString *CellIdentifier = @"add more";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:
                    CellIdentifier];
        }
        //UILabel *label = (UILabel *)[cell viewWithTag:2];
        
        //cell.textLabel.text = @"Add more";
        //cell.detailTextLabel.text = @"Tap here to add more favorites from library.";
        //cell.showsReorderControl = NO;
        //cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //asuming only one section!
    if(indexPath.row >= self.fetchedResultsController.fetchedObjects.count){
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //asuming only one section!
    if(indexPath.row >= self.fetchedResultsController.fetchedObjects.count){
        return NO;
    }
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = [super tableView:tableView numberOfRowsInSection:section];
    return number + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= self.fetchedResultsController.fetchedObjects.count){
        [self performSegueWithIdentifier:showAllToAddSegueID sender:self];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end

//
//  ISTAddToFavoritesViewController.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTAddToFavoritesViewController.h"
#import "ShaderSource.h"

@implementation ISTAddToFavoritesViewController

@synthesize nextFavoriteValue = mNextFavoriteValue;

- (DataFetchType) dataFetchType
{
    return DataFetchTypeAddingFavorites;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)cancel:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UITableViewDelegate
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"shader list cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:
                CellIdentifier];
    }
    
    // Configure the cell...
    ShaderSource *shaderSource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    cell.textLabel.text = shaderSource.zomming;
    cell.detailTextLabel.text = shaderSource.date.description;
    cell.showsReorderControl = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}
 */ 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    ShaderSource *shader = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.nextFavoriteValue) {
        shader.favorite = self.nextFavoriteValue;
        [ISTShaderManager.instance save];
    }
}
@end

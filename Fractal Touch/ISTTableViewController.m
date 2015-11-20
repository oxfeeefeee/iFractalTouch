//
//  ISTViewController.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "ISTTableViewController.h"
#import "ShaderSource.h"
#import "ISTInfoViewController.h"
#import "ISTFractalViewController.h"
#import "ISTUIUtility.h"
#import "ftGlobalStates.h"


@implementation ISTTableViewController

static NSString* sViewDetailsSegueID = @"view details";
static NSString* sViewSegueID = @"view";

- (DataFetchType) dataFetchType
{
    return DataFetchTypeAllShaders;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)startPlay
{
    [self performSegueWithIdentifier:sViewSegueID sender:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.sectionIndexMinimumDisplayRowCount = 30;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [ISTShaderManager.instance getFetchedResultControllerWithType:self.dataFetchType completionHandler:^(NSFetchedResultsController *controller){
        if (controller) {
            self.fetchedResultsController = controller;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if([segue.identifier isEqualToString:sViewDetailsSegueID])//not in use
    {
        ISTInfoViewController* destVC = (ISTInfoViewController*)[ISTUIUtility getDestControllerOfSegue:segue];
        ShaderSource* shader = (ShaderSource*)sender;
        destVC.titleText = shader.re;
        destVC.descText = shader.im;
        destVC.sourceText = shader.desc;
    }else if ([segue.identifier isEqualToString:sViewSegueID]) {
        //ISTFractalViewController* destVC = (ISTFractalViewController*)[ISTUIUtility getDestControllerOfSegue:segue];
        if([sender class] == [ShaderSource class])
        {
            //destVC.currentBookmark = (ShaderSource*)sender;
            [ftGlobalStates instance].dbObject = (ShaderSource*)sender;
        }
    }
}

#pragma mark - UITableViewDataSource

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
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setLocale:[NSLocale currentLocale]];
    //[dateFormat setDateFormat:@"dd LLL YYYY"];
    //NSString* dateStr = [dateFormat stringFromDate:shaderSource.date];
    label.text = [NSString stringWithFormat: @"RE: %@\nIM: %@\nZoom: x%@", shaderSource.re, shaderSource.im, shaderSource.zomming];
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:1];
    imageView.image = [UIImage imageWithData:shaderSource.thumbnail];
    //[imageView.layer setMasksToBounds:YES];
    //[imageView.layer setCornerRadius:5.0];
    
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0, 1);
    CGRect shadowFrame = imageView.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    imageView.layer.shadowPath = shadowPath;
    imageView.layer.shadowOpacity = 0.6;
    imageView.layer.shadowRadius = 1.0;
    imageView.clipsToBounds = NO;
    
    //thumbnailView.image = [UIImage imageWithData:shaderSource.thumbnail];
    //thumbnailView.frame = shadowView.frame;
    //[thumbnailView.layer setMasksToBounds:YES];
    //[thumbnailView.layer setCornerRadius:4.0];
    
    // Then configure the cell using it ...
    //cell.textLabel.text = shaderSource.title;
    //cell.detailTextLabel.text = shaderSource.shaderDesc;
    cell.showsReorderControl = YES;
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView 
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.section != sourceIndexPath.section)
    {
        //keep cell where it was...
        return sourceIndexPath;
    }
    //ok to move cell to proposed path...
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ShaderSource *shaderSource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:sViewDetailsSegueID sender:shaderSource];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShaderSource *shaderSource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:sViewSegueID sender:shaderSource];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77.0f;
}

@end

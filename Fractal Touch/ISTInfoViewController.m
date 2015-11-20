//
//  ISTSourceViewController.m
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ISTInfoViewController.h"
#import "ISTUIUtility.h"

@implementation ISTInfoViewController

static int landScapeSourceMaxWidth = 440;
static int portraitSourceMaxWidth = 280;

@synthesize titleLabel = mTitleLabel;
@synthesize descLabel = mDescLabel;
@synthesize sourceLabel = mSourceLabel;
@synthesize titleText = mTitleText;
@synthesize descText = mDescText;
@synthesize sourceText = mSourceText;

- (void)setTitleText:(NSString *)titleText
{
    mTitleText = titleText;
    // titleLabel may be nil here, so we need to set it again on init
    self.titleLabel.text = titleText;
}

- (void)setDescText:(NSString *)descText
{
    mDescText = descText;
    // descLabel may be nil here, so we need to set it again on init
    self.descLabel.text = descText;
}

- (void)setSourceText:(NSString *)sourceText
{
    mSourceText = sourceText;
    // sourceLabel may be nil here, so we need to set it again on init
    if (self.sourceLabel) {
        int maxwidth = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight? landScapeSourceMaxWidth : portraitSourceMaxWidth;
        self.sourceLabel.text = sourceText;
        CGRect frame = self.sourceLabel.frame;
        CGSize maximumSize = CGSizeMake(maxwidth, 9999);
        CGSize size = [self.sourceLabel.text sizeWithFont:self.sourceLabel.font constrainedToSize:maximumSize lineBreakMode:self.sourceLabel.lineBreakMode];
        CGRect newFrame;
        newFrame.origin = frame.origin;
        newFrame.size = size;
        self.sourceLabel.frame = newFrame;  
        
        CGFloat viewHeight = newFrame.origin.y + size.height + 20;
        UIScrollView* scrollView = (UIScrollView*)self.view;
        CGSize viewSize = CGSizeMake(scrollView.contentSize.width, viewHeight);
        scrollView.contentSize = viewSize;
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([segue.identifier isEqualToString:@"SelectColorSegue"]) 
    {
        ISTSPViewController *vc = segue.destinationViewController;
    }*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleText = mTitleText;
    self.descText = mDescText;
    self.sourceText = mSourceText;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(!self.tabBarController.delegate)
    {
        self.tabBarController.delegate = ISTUIUtility.instance;
    }
    
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setDescLabel:nil];
    [self setSourceLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    //re-format 
    self.sourceText = mSourceText;
}


@end

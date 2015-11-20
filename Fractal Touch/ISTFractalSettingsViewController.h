//
//  ISTFractalSettingsViewController.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ftExtendedHitAreaViewContainer;

@interface ISTFractalSettingsViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) UIViewController* segueSender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *iterationSelector;
@property (weak, nonatomic) IBOutlet UILabel *imLabel;
@property (weak, nonatomic) IBOutlet UILabel *reLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoomingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *calculatingIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectorSelector;
@property (weak, nonatomic) IBOutlet UILabel *iterationLimitText;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet ftExtendedHitAreaViewContainer *previewerMask;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButtonOnToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButtonOnToolbar;



- (IBAction)backToList:(id)sender;

- (IBAction)addBookmark:(id)sender;

- (IBAction)backToViewer:(id)sender;

- (IBAction)reset:(id)sender;

- (IBAction)saveImage:(id)sender;

- (IBAction)shareToSns:(id)sender;

- (IBAction)selectorSelectorValueChange:(id)sender;

@end

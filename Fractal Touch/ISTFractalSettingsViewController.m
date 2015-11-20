//
//  ISTFractalSettingsViewController.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "ISTFractalSettingsViewController.h"
#import "ISTColorSelection.h"
#import "ISTColorCalculator.h"
#import "ISTFractalViewController.h"
#import "ISTMegaFractal.h"
#import "ISTShaderManager.h"
#import "ISTIterationSelection.h"
#import "ftTextureSelection.h"
#import "ISTUtility.h"
#import "ftGlobalStates.h"
#import "ftExtendedHitAreaViewContainer.h"
#import "ftRenderTarget.h"
#import <UIKit/UIImage.h>


@interface ISTFractalSettingsViewController ()

@property (nonatomic, strong) NSString* reValueText;
@property (nonatomic, strong) NSString* imValueText;
@property (nonatomic, strong) NSString* zoomingValueText;
@property (nonatomic, assign) size_t tempColorIndex;
@property (nonatomic, assign) size_t tempColorStyleIndex;
@property (nonatomic, assign) size_t tempTextureIndex;
@property (nonatomic, assign) size_t oldColorIndex;
@property (nonatomic, assign) size_t oldColorStyleIndex;
@property (nonatomic, assign) size_t oldTextureIndex;
@property (nonatomic, assign) enum ScrollingSelectorMode oldSelectorMode;
@property (nonatomic, strong) NSMutableDictionary* previewUIViews;
@property (nonatomic, strong) NSMutableDictionary* previewShadowViews;

@property (nonatomic, weak) UIActionSheet* buyColorLoverActionSheet;
@property (nonatomic, weak) UIActionSheet* buyCollectorActionSheet;

@end

@implementation ISTFractalSettingsViewController

@synthesize segueSender = mSegueSender;
@synthesize scrollView = mScrollView;
@synthesize previewerMask = mPreviewerMask;
@synthesize pageControl = mPageControl;
@synthesize iterationSelector = mInterationSelector;
@synthesize imLabel = mIMLabel;
@synthesize reLabel = mRELabel;
@synthesize zoomingLabel = mZoomingLabel;
@synthesize calculatingIndicator;
@synthesize toolBar = mToolBar;
@synthesize selectorSelector = mSelectorSelector;
@synthesize iterationLimitText = mIterationLimitText;
@synthesize reValueText = mREValueText;
@synthesize imValueText = mIMValueText;
@synthesize zoomingValueText = mZoomingValueText;
@synthesize tempColorIndex = mTempColorIndex;
@synthesize tempColorStyleIndex = mTempColorStyleIndex;
@synthesize tempTextureIndex = mTempTextureIndex;
@synthesize oldColorIndex = mOldColorIndex;
@synthesize oldColorStyleIndex = mOldColorStyleIndex;
@synthesize oldTextureIndex = mOldTextureIndex;
@synthesize oldSelectorMode = mOldSelectorMode;
@synthesize previewUIViews = mPreviewUIViews;
@synthesize previewShadowViews = mPreviewShadowViews;
@synthesize buyColorLoverActionSheet = mBuyColorLoverActionSheet;
@synthesize buyCollectorActionSheet = mBuyCollectorActionSheet;
static float thumbnailWidth = 42.f;
static int smShadowViewTag = 9999;

- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [mScrollView subviews];
    int width = mScrollView.frame.size.width;
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = (width - [ISTUtility previewWidth]) / 2;
    int count = 0;
	for (view in subviews)
	{
		if (view.tag == smShadowViewTag)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += width;
            ++count;
		}
	}
	
	// set the content size so it can be scrollable
	[mScrollView setContentSize:CGSizeMake(count * width, [mScrollView bounds].size.height)];
}

- (void)setupEffectAndAddToScrollView:(UIImage*)image withIndex:(int)index
{
    NSNumber* key = [NSNumber numberWithInt:index];
    UIImageView *imageView = [mPreviewUIViews objectForKey:key];
    if (!imageView) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        CGRect rect = imageView.frame;
        rect.size.height = [ISTUtility previewWidth] * [ISTUtility heightOverWidth];
        rect.size.width = [ISTUtility previewWidth];
        imageView.frame = rect;
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setCornerRadius:7.0];
        imageView.tag = index+1;
        UIView* shadowView = [[UIView alloc]initWithFrame: imageView.frame];
        shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        shadowView.layer.shadowOffset = CGSizeMake(0, 1);
        CGRect shadowFrame = shadowView.bounds;
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        shadowView.layer.shadowPath = shadowPath;
        shadowView.layer.shadowOpacity = 0.6;
        shadowView.layer.shadowRadius = 2.0;
        shadowView.clipsToBounds = NO;
        shadowView.tag = smShadowViewTag;
        [shadowView addSubview:imageView];
        [mPreviewUIViews setObject:imageView forKey:key];
        [mPreviewShadowViews setObject:shadowView forKey:key];
    }else {
        imageView.image = image;
    }
    UIView* shadowView = [mPreviewShadowViews objectForKey:key];
    [mScrollView addSubview:shadowView];
}

- (void)preparePreviewData
{
    ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
    [fvc.megaFractal prepareForColorPreview:[ISTUtility previewWidth]];
    [[ISTColorSelection instance] generatePreviewData: [ISTUtility previewWidth] * [ISTUtility screenScale]];
}

- (void)initTexturePreviewImages;
{
    [[ftTextureSelection instance] generatePreview];
    NSMutableArray* previews = [ftTextureSelection instance].allPreviewImages;
    size_t num = previews.count;
    mPageControl.numberOfPages = num;
    for (int i = 0; i < num; i++)
	{
        ISTHandMadeUIImage* image = [previews objectAtIndex:i];
        UIImage* uiimage = image.uiImage;
		[self setupEffectAndAddToScrollView:uiimage withIndex:i];
    }
    [self setCurrentPage:mTempTextureIndex];
	[self layoutScrollImages];
}

- (void)initColorPreviewImages;
{
    [[ISTColorSelection instance] generatePreviewImages];
    NSMutableArray* calculators = [ISTColorSelection instance].colorCalculators;
    size_t num = calculators.count;
    mPageControl.numberOfPages = num;
	for (int i = 0; i < num; i++)
	{
        ISTColorCalculator* calculator = [calculators objectAtIndex:i];
		UIImage *image = calculator.preview.uiImage; 
        [self setupEffectAndAddToScrollView:image withIndex:i];
	}
    [self setCurrentPage:mTempColorIndex];
	[self layoutScrollImages];
}


- (void)initColorStylePreviewImages;
{
    [[ISTColorSelection instance] generatePreviewImages];
    NSMutableArray* calculators = [ISTColorSelection instance].colorStyleCalculators;
    size_t num = calculators.count;
    mPageControl.numberOfPages = num;
	for (int i = 0; i < num; i++)
	{
        ISTColorCalculator* calculator = [calculators objectAtIndex:i];
		UIImage *image = calculator.preview.uiImage;
        [self setupEffectAndAddToScrollView:image withIndex:i];
	}
    [self setCurrentPage:mTempColorStyleIndex];
	[self layoutScrollImages];
}

- (void)initSelector
{
    mTempColorIndex = [ISTColorSelection instance].currentColorIndex;
    mTempColorStyleIndex = [ISTColorSelection instance].currentColorStyleIndex;
    mTempTextureIndex = [ftTextureSelection instance].currentIndex;
    NSArray* previews = [[NSArray alloc]initWithArray:mScrollView.subviews];
    for (UIView* view in previews){
        [view removeFromSuperview];
    }
    if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Color) {
        [self initColorPreviewImages];
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Style) {
        [self initColorStylePreviewImages];
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Texture) {
        [self initTexturePreviewImages];
    }
}

- (void)initTexts
{
    if(self.segueSender){
        ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
        ISTMegaFractal* mf = fvc.megaFractal;
        NSArray* texts = [ISTUtility getFractalLocStrings:mf];
        mZoomingValueText = [texts objectAtIndex:2];
        mZoomingLabel.text = [NSString stringWithFormat:@"Zoom: x%.2f (2^%.1f)", mf.absScale, log2(mf.absScale)];
        mREValueText = [texts objectAtIndex:0];
        mIMValueText = [texts objectAtIndex:1];
        mRELabel.text = [NSString stringWithFormat:@"RE: %@", mREValueText];
        mIMLabel.text = [NSString stringWithFormat:@"IM: %@", mIMValueText];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	mScrollView.clipsToBounds = NO;
	mScrollView.scrollEnabled = YES;
	mScrollView.pagingEnabled = YES;
    mScrollView.delegate = self;
    mPreviewUIViews = [[NSMutableDictionary alloc]init];
    mPreviewShadowViews = [[NSMutableDictionary alloc]init];
    self.pageControl.hidden = YES;
    mSelectorSelector.hidden = YES;
    mInterationSelector.hidden = YES;
    [mInterationSelector addTarget:self action:@selector(onIterationSelected) forControlEvents:UIControlEventValueChanged];
    mIterationLimitText.hidden = YES;
    mToolBar.hidden = YES;
    mRELabel.hidden = YES;
    mIMLabel.hidden = YES;
    mZoomingLabel.hidden = YES;
    
    if ([ISTUtility isTallScreenPhone]) {
        int diff = [ISTUtility screenHeight] - 480;
        [mIterationLimitText setFrame: CGRectOffset(mIterationLimitText.frame, 0, diff)];
        [mInterationSelector setFrame: CGRectOffset(mInterationSelector.frame, 0, diff)];
        
        [mSelectorSelector setFrame: CGRectOffset(mSelectorSelector.frame, 0, diff)];
        [self.pageControl setFrame: CGRectOffset(self.pageControl.frame, 0, diff)];
        
        float perviewDiff = (float)[ISTUtility previewWidth] * ([ISTUtility heightOverWidth] - 1.5f);
        diff = diff - (int)perviewDiff;
        
        [mPreviewerMask setFrame: CGRectMake(mPreviewerMask.frame.origin.x,
                                             mPreviewerMask.frame.origin.y + diff,
                                             mPreviewerMask.frame.size.width,
                                             mPreviewerMask.frame.size.height + perviewDiff)];
        
        [mIMLabel setFrame: CGRectOffset(mIMLabel.frame, 0, diff)];
        [mRELabel setFrame: CGRectOffset(mRELabel.frame, 0, diff)];
        [mZoomingLabel setFrame: CGRectOffset(mZoomingLabel.frame, 0, diff)];
        
        [self.calculatingIndicator setFrame: CGRectOffset(self.calculatingIndicator.frame, 0, diff-perviewDiff)];
    }
    
    
    [self initTexts];
    self.iterationSelector.selectedSegmentIndex = [ISTIterationSelection instance].iterationLimitIndex;
    if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Color) {
        mSelectorSelector.selectedSegmentIndex = 0;
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Style) {
        mSelectorSelector.selectedSegmentIndex = 1;
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Texture) {
        mSelectorSelector.selectedSegmentIndex = 2;
    }

    [self.view layoutIfNeeded];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setCalculatingIndicator:nil];
    [self setIterationSelector:nil];
    [self setZoomingLabel:nil];
    [self setImLabel:nil];
    [self setReLabel:nil];
    [self setToolBar:nil];
    [self setSelectorSelector:nil];
    mPreviewUIViews = nil;
    mPreviewShadowViews = nil;
    [self setIterationLimitText:nil];
    [self setPreviewerMask:nil];
    [self setAddButtonOnToolbar:nil];
    [self setAddButtonOnToolbar:nil];
    [self setResetButtonOnToolbar:nil];
    [super viewDidUnload];
    [[ISTColorSelection instance] clearPreviewData];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
    fvc.forcePause = NO;
    [self.calculatingIndicator startAnimating];
    self.pageControl.hidden = NO;
    mSelectorSelector.hidden = NO;
    mInterationSelector.hidden = NO;
    mIterationLimitText.hidden = NO;
    mToolBar.hidden = NO;
    mRELabel.hidden = NO;
    mIMLabel.hidden = NO;
    mZoomingLabel.hidden = NO;
    mScrollView.alpha = 0.0;
    self.pageControl.alpha = 0.0;
    mSelectorSelector.alpha = 0.0;
    mInterationSelector.alpha = 0.0;
    mIterationLimitText.alpha = 0.0;
    mRELabel.alpha = 0.0;
    mIMLabel.alpha = 0.0;
    mZoomingLabel.alpha = 0.0;
    mToolBar.alpha = 0.0;
    [self preparePreviewData];
    [self initSelector];
    
    mOldColorIndex = [ISTColorSelection instance].currentColorIndex;
    mOldColorStyleIndex = [ISTColorSelection instance].currentColorStyleIndex;
    mOldTextureIndex = [ftTextureSelection instance].currentIndex;
    mOldSelectorMode = [ftGlobalStates instance].selectorMode;
    
    UITapGestureRecognizer *singleFingerPreviewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePreviewSingleTap:)];
    singleFingerPreviewTap.numberOfTapsRequired = 1;
    [mScrollView addGestureRecognizer:singleFingerPreviewTap];
    
    [self updateAddButtonVisibility];
    
    [UIView animateWithDuration:0.2 animations:^{
        [mScrollView setAlpha:1.0];
        [self.pageControl setAlpha:1.0];
        [mSelectorSelector setAlpha:1.0];
        mInterationSelector.alpha = 1.0;
        mIterationLimitText.alpha = 1.0;
        mRELabel.alpha = 1.0;
        mIMLabel.alpha = 1.0;
        mZoomingLabel.alpha = 1.0;
        mToolBar.alpha = 1.0;
    } completion:nil];
    [self.view layoutIfNeeded];
    [self.calculatingIndicator stopAnimating];
}

- (void)handlePreviewSingleTap:(UIGestureRecognizer *)sender
{
    int currentIndex = -1;
    if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Color) {
        currentIndex = mTempColorIndex;
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Style) {
        currentIndex = mTempColorStyleIndex;
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Texture) {
        currentIndex = mTempTextureIndex;
    }
    
    if([mPreviewShadowViews count] > currentIndex){
        NSNumber* key = [NSNumber numberWithInt:currentIndex];
        UIImageView *imageView = [mPreviewShadowViews objectForKey:key];
        CGPoint point = [sender locationInView:imageView];
        if ([imageView pointInside:point withEvent:nil]) {
            [self onMainPreviewTaped: imageView];
        }
    }
}

- (void)onMainPreviewTaped:(UIImageView*) tappedView
{
    if (![ISTUtility isIAP_ColorLoverEnabled]) {
        if (mTempColorIndex != mOldColorIndex ||
            mTempColorStyleIndex != mOldColorStyleIndex ||
            mTempTextureIndex != mOldTextureIndex){
            UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"Appying coloring changes is not enabled.\nWould you like to purchase the \"Color Lover\" feature to enable it?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Learn More", nil];
            mBuyColorLoverActionSheet = as;
            mBuyColorLoverActionSheet.actionSheetStyle = UIBarStyleDefault;
            [mBuyColorLoverActionSheet showFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
            return;
        }
    }
    
    
    for(UIImageView* view in mPreviewShadowViews.objectEnumerator){
        if (view != tappedView) {
            view.hidden = TRUE;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        //[mScrollView setAlpha:0.0];
        [self.pageControl setAlpha:0.0];
        [mSelectorSelector setAlpha:0.0];
        mInterationSelector.alpha = 0.0;
        mIterationLimitText.alpha = 0.0;
        mRELabel.alpha = 0.0;
        mIMLabel.alpha = 0.0;
        mZoomingLabel.alpha = 0.0;
        mToolBar.alpha = 0.0;
        
        float scale = (float)[ISTUtility screenWidth] / [ISTUtility previewWidth];
        [mPreviewerMask setTransform:CGAffineTransformMakeScale(scale, scale)];
        [mPreviewerMask setAlpha:0.0];
    } completion:^(BOOL finished){
        NSArray* previews = [[NSArray alloc]initWithArray:mScrollView.subviews];
        for (UIView* view in previews){
            [view removeFromSuperview];
        }
        
        ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
        fvc.forcePause = YES;
        [self dismissViewControllerAnimated:YES completion:^{
            ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
            fvc.forcePause = NO;
            [ftGlobalStates instance].iterLimitIndex = self.iterationSelector.selectedSegmentIndex;
            [ftGlobalStates instance].colorIndex = mTempColorIndex;
            [ftGlobalStates instance].colorStyleIndex = mTempColorStyleIndex;
            [ftGlobalStates instance].textureIndex = mTempTextureIndex;
            [fvc onFractalViewSettingChange];
        }];

    }];
}

- (void)updateAddButtonVisibility
{
    return;
    
    if (mTempColorIndex == mOldColorIndex &&
        mTempColorStyleIndex == mOldColorStyleIndex &&
        mTempTextureIndex == mOldTextureIndex &&
        self.iterationSelector.selectedSegmentIndex == [ISTIterationSelection instance].iterationLimitIndex) {
        //self.addButtonOnToolbar.enabled = TRUE;
    }else{
        ///self.addButtonOnToolbar.enabled = FALSE;
    }
}

- (void)onIterationSelected
{
    [self backToViewer:self];
}

//UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Color) {
        mTempColorIndex = page;
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Style) {
        mTempColorStyleIndex = page;
    }else if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Texture) {
        mTempTextureIndex = page;
    }
    
    [self updateAddButtonVisibility];
}

- (void)setCurrentPage:(int)page
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.scrollView.contentOffset = CGPointMake(page * pageWidth, 0);
    self.pageControl.currentPage = page;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    mPageControlBeingUsed = NO;
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    mPageControlBeingUsed = NO;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backToViewer:(id)sender {
    //to make to animation smoother and stable
    [UIView animateWithDuration:0.2 animations:^{
        [mScrollView setAlpha:0.0];
        [self.pageControl setAlpha:0.0];
        [mSelectorSelector setAlpha:0.0];
        mInterationSelector.alpha = 0.0;
        mIterationLimitText.alpha = 0.0;
        mRELabel.alpha = 0.0;
        mIMLabel.alpha = 0.0;
        mZoomingLabel.alpha = 0.0;
        mToolBar.alpha = 0.0;
    } completion:^(BOOL finished){
        NSArray* previews = [[NSArray alloc]initWithArray:mScrollView.subviews];
        for (UIView* view in previews){
            [view removeFromSuperview];
        }
        [UIView animateWithDuration:0.1 animations:^{
            [mScrollView setAlpha:1.0];
        } completion:^(BOOL finished){
            ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
            fvc.forcePause = YES;
            [self dismissViewControllerAnimated:YES completion:^{
                ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
                fvc.forcePause = NO;
                [ftGlobalStates instance].iterLimitIndex = self.iterationSelector.selectedSegmentIndex;
                if ([ISTUtility isIAP_ColorLoverEnabled]) {
                    [ftGlobalStates instance].colorIndex = mTempColorIndex;
                    [ftGlobalStates instance].colorStyleIndex = mTempColorStyleIndex;
                    [ftGlobalStates instance].textureIndex = mTempTextureIndex;
                }
                [fvc onFractalViewSettingChange];
            }];
        }];
    }];
}

- (IBAction)selectorSelectorValueChange:(id)sender {
    NSInteger currentIndex = 0;
    NSInteger newIndex = 0;
    
    if ([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Color) {
        currentIndex = mTempColorIndex;
    }else if([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Style) {
        currentIndex = mTempColorStyleIndex;
    }else if([ftGlobalStates instance].selectorMode == ScrollingSelectorMode_Texture) {
        currentIndex = mTempTextureIndex;
    }
    
    if (mSelectorSelector.selectedSegmentIndex == 0) {
        [ftGlobalStates instance].selectorMode = ScrollingSelectorMode_Color;
        newIndex = mTempColorIndex;
    }else if (mSelectorSelector.selectedSegmentIndex == 1) {
        [ftGlobalStates instance].selectorMode = ScrollingSelectorMode_Style;
        newIndex = mTempColorStyleIndex;
    }else if (mSelectorSelector.selectedSegmentIndex == 2) {
        [ftGlobalStates instance].selectorMode = ScrollingSelectorMode_Texture;
        newIndex = mTempTextureIndex;
    }
    
    /*[ftGlobalStates instance].colorIndex = mTempColorIndex;
    [ftGlobalStates instance].textureIndex = mTempTextureIndex;
    [self initSelector];
    return;*/
    
    for (NSNumber* viewid in [mPreviewShadowViews allKeys]){
        UIView* view = [mPreviewShadowViews objectForKey:viewid];
        [view.layer removeAllAnimations];
        [view setAlpha:1.0];
    }
    
    self.pageControl.hidden = YES;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    UIView* currentView1 = [mPreviewShadowViews objectForKey:[NSNumber numberWithInt:(currentIndex - 1)]];
    UIView* currentView2 = [mPreviewShadowViews objectForKey:[NSNumber numberWithInt:(currentIndex + 1)]];
    UIView* newView1 = [mPreviewShadowViews objectForKey:[NSNumber numberWithInt:(newIndex - 1)]];
    UIView* newView2 = [mPreviewShadowViews objectForKey:[NSNumber numberWithInt:(newIndex + 1)]];
                           
    [UIView animateWithDuration:0.2 animations:^{
        [currentView1 setAlpha:0.0];
        [currentView2 setAlpha:0.0];
     } completion:^(BOOL finished){
         [currentView1 setAlpha:1.0];
         [currentView2 setAlpha:1.0];
         [ftGlobalStates instance].colorIndex = mTempColorIndex;
         [ftGlobalStates instance].colorStyleIndex = mTempColorStyleIndex;
         [ftGlobalStates instance].textureIndex = mTempTextureIndex;
         if (finished) {
             [self initSelector];
             [newView1 setAlpha:0.0];
             [newView2 setAlpha:0.0];
             [UIView animateWithDuration:0.05 animations:^{
                 [newView1 setAlpha:1.0];
                 [newView2 setAlpha:1.0];
             }completion:^(BOOL finished){
                 self.pageControl.hidden = NO;
             }];
         }else {
             [self initSelector];
             self.pageControl.hidden = NO;
         }
     }];
}

- (IBAction)reset:(id)sender {
    
    ftGlobalStates.instance.selectorMode = mOldSelectorMode;
    mTempColorIndex = mOldColorIndex;
    mTempColorStyleIndex = mOldColorStyleIndex;
    mTempTextureIndex = mOldTextureIndex;
    [ftGlobalStates instance].colorIndex = mTempColorIndex;
    [ftGlobalStates instance].colorStyleIndex = mTempColorStyleIndex;
    [ftGlobalStates instance].textureIndex = mTempTextureIndex;
    
    [self backToViewer:self];
}

- (IBAction)backToList:(id)sender {
    ISTFractalViewController* fvc = (ISTFractalViewController*)self.segueSender;
    ISTMegaFractal* mf = fvc.megaFractal;
    [[ftGlobalStates instance] updateFractalLocInfo:mf];
    __weak UIViewController* vc = self.segueSender;
    [self dismissViewControllerAnimated:NO completion:^{
        [[vc navigationController] popViewControllerAnimated:YES];
        //[vc dismissViewControllerAnimated:YES completion:NULL];
    }];
    
}

- (IBAction)addBookmark:(id)sender {
    UIActionSheet *actionSheet = nil;
    if (![ISTUtility isIAP_CollectorEnabled]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Adding to Bookmarks is not enabled.\nWould you like to purchase the \"Collector\" feature to enable it?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Learn More", nil];
        mBuyCollectorActionSheet = actionSheet;
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Bookmarks", nil];
    }

    actionSheet.actionSheetStyle = UIBarStyleDefault;
    [actionSheet showFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)jumpToBuy
{
    __weak UIViewController* vc = self.segueSender;
    [self dismissViewControllerAnimated:NO completion:^{
        
        UITabBarController *tabBar = (UITabBarController *)vc.view.window.rootViewController;
        [tabBar setSelectedIndex:2];
        UINavigationController * controllerMore = (UINavigationController*)[tabBar selectedViewController];
        [controllerMore popToRootViewControllerAnimated:NO];
        [[vc navigationController] popToRootViewControllerAnimated:YES];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (actionSheet == mBuyCollectorActionSheet) {
            [ftGlobalStates instance].jumpToBuyTag = @"Collector";
            [self jumpToBuy];
            return;
        }else if (actionSheet == mBuyColorLoverActionSheet)
        {
            [ftGlobalStates instance].jumpToBuyTag = @"ColorLover";
            [self jumpToBuy];
            return;
        }
        
        NSInteger page = self.pageControl.currentPage + 1;
        UIImageView* imageView = (UIImageView*)[self.scrollView viewWithTag:page];
        UIImage* image = imageView.image;
        
        CGImageRef imageRef = NULL;
        if ([ISTUtility isTallScreenPhone]) {
            float perviewDiff = (float)[ISTUtility previewWidth] * ([ISTUtility heightOverWidth] - 1.5f);
            imageRef = CGImageCreateWithImageInRect([image CGImage],
                                                               CGRectMake(0, perviewDiff*0.5, image.size.width, image.size.height-perviewDiff));
            image = [UIImage imageWithCGImage:imageRef];
        }
        
        UIImage* tnImage = [ISTFractalSettingsViewController imageWithImage:image scaledToSize:CGSizeMake(thumbnailWidth*2.f, thumbnailWidth*2.f*1.5f) ];
        //int i = UIImageJPEGRepresentation(tnImage, 0.8f).length;
        [[ISTShaderManager instance] addBookmark:mREValueText im:mIMValueText zooming:mZoomingValueText colorIndex: [ISTColorSelection getColorCalcIndexWithColorIndex:mTempColorIndex andStyleIndex:mTempColorStyleIndex] textureIndex:mTempTextureIndex iterIndex:self.iterationSelector.selectedSegmentIndex thumbnail:UIImagePNGRepresentation(tnImage)];
        
        if(imageRef != NULL)
        {
            CGImageRelease(imageRef);
        }
    }
}
/*
 CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
 // or use the UIImage wherever you like
 [UIImageView setImage:[UIImage imageWithCGImage:imageRef]];
 CGImageRelease(imageRef);
 */

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end



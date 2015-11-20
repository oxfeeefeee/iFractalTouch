//
//  FractalViewController.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "ISTFractalViewController.h"
#import "ISTDrawImageShader.h"
#import "ISTMegaFractalShader.h"
#import "ISTFractalSettingsViewController.h"
#import "ISTUtility.h"
#import "ISTColorSelection.h"
#import "ISTFractalHUD.h"
#import "ISTShaderManager.h"
#import "ISTColorSelection.h"
#import "ISTIterationSelection.h"
#import "ftRenderTarget.h"
#import "ftPostProcessImage.h"
#import "ftpostProcessBlendShader.h"
#import "ftTextureSelection.h"
#import "ftGlobalStates.h"
#import "ISTUtility.h"

@interface ISTFractalViewController()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) ISTFractalHUD* hud;
@property (strong, nonatomic) ftPostProcessImage* fractalImage;

- (void)setupGL;
- (void)setupContent;
- (void)setupGestureRecognizers;
- (void)handleSingleTap:(UIGestureRecognizer *)sender;

@end

@implementation ISTFractalViewController

@synthesize context = mContext;
@synthesize megaFractal = mMegaFractal;
@synthesize fractalRT = mFractalRT;
@synthesize fractalImage = mFractalImage;
@synthesize mainButton = mMainButton;
@synthesize shareButton = mShareButton;
@synthesize backButton = mBackButton;
@synthesize hud = mHud;
@synthesize forcePause = mForcePause;

static NSString* smViewerSettings = @"viewer settings";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.contentScaleFactor = [ISTUtility screenScale];
    self.preferredFramesPerSecond = 60;
    
    [ISTDrawImageShader releaseInstance];
    [ISTMegaFractalShader releaseInstance];
    [ftPostProcessBlendShader releaseInstance];
    [ftTextureSelection releaseInstance];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    [self setupContent];
}

- (void)viewDidUnloaddrawInRect
{
    mHud = nil;
    mMainButton = nil;
    mShareButton = nil;
    //releaseing megaFractal
    mMegaFractal = nil;
    [super viewDidUnload];
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self setupGestureRecognizers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    mHud = nil;
    mMainButton = nil;
    mShareButton = nil;
    //releaseing megaFractal
    [mMegaFractal releaseResource];
    mMegaFractal = nil;
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    glDisable(GL_DEPTH_TEST);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)setupContent
{
    mFractalRT = [[ftRenderTarget alloc] initWithSize:CGSizeMake([ISTUtility screenWidthInPixel], [ISTUtility screenHeightInPixel])];
    mFractalImage = [[ftPostProcessImage alloc] initWithFrame:CGRectMake(0, 0, [ISTUtility screenWidth], [ISTUtility screenHeight]) andTextureName:mFractalRT.textureName andBlendingTextureUV:CGPointMake((float)[ISTUtility screenWidthInPixel]/[ISTUtility blendingTextureVirtualSize], (float)[ISTUtility screenHeightInPixel]/[ISTUtility blendingTextureVirtualSize])];
    
    mFractalImage.blendTextureName = [ftTextureSelection instance].currentTexture.name;
    mMegaFractal = [[ISTMegaFractal alloc]initWithRefreshTarget:self];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    f.locale = usLocale;
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    mMegaFractal.absScale = [f numberFromString: [ftGlobalStates instance].zoomingText].doubleValue;
    mMegaFractal.absLocationX = [f numberFromString: [ftGlobalStates instance].reText].doubleValue;
    mMegaFractal.absLocationY = [f numberFromString: [ftGlobalStates instance].imText].doubleValue;
    
    //mMainButton = [[ISTButton alloc]initWithOrigin:CGPointMake(250.f, 430.f) andResourcePath:@"home" ofType:@"png"];
    mMainButton = [[ISTButton alloc]initWithOrigin:CGPointMake(270.f, [ISTUtility screenHeight] - 40.f) andSize:CGSizeMake(50.f, 40.f)];
    [mMainButton setTarget:self action:@selector(onMainButtonTap)];
    mShareButton = [[ISTButton alloc]initWithOrigin:CGPointMake(320.f/2.f - 25.f, [ISTUtility screenHeight] - 40.f) andSize:CGSizeMake(50.f, 40.f)];
    [mShareButton setTarget:self action:@selector(onShareButtonTap)];
    mBackButton = [[ISTButton alloc]initWithOrigin:CGPointMake(0.f, [ISTUtility screenHeight] - 40.f) andSize:CGSizeMake(50.f, 40.f)];
    [mBackButton setTarget:self action:@selector(onBackButtonTap)];
    mHud = [[ISTFractalHUD alloc]init];
    
    //[self.view.layer setMasksToBounds:YES];
    //[self.view.layer setCornerRadius:7.0];
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleSingleTap:)];
    singleFingerTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleFingerTap];
    
    UITapGestureRecognizer *singleFingerDoubleTap = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(handleSingleDoubleTap:)];
    singleFingerDoubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:singleFingerDoubleTap];
    
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(handleTwoFingerTap:)];
    twoFingerTap.numberOfTouchesRequired = 2;
    twoFingerTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:twoFingerTap];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGesture];
}

- (void)handleSingleTap:(UIGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationInView:sender.view];
    if( [mMainButton inMyFrame:tapPoint])
    {
        [mMainButton handleTap];
    }else if ([mShareButton inMyFrame:tapPoint]) {
        [mShareButton handleTap];
    }else if ([mBackButton inMyFrame:tapPoint]) {
        [mBackButton handleTap];
    }
}

- (void)handleSingleDoubleTap:(UIGestureRecognizer *)sender
{
    UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer*)sender;
    [mMegaFractal handleDoubleTapGesture:tapGesture];
    self.paused = NO;
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)sender
{
    UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer*)sender;
    [mMegaFractal handleTwoFingerTapGesture:tapGesture];
    self.paused = NO;
}

- (void)handlePan:(UIGestureRecognizer*)sender
{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)sender;
    [mMegaFractal handlePanGesture:panGesture];
    self.paused = NO;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer*)sender;
    [mMegaFractal handlePinchGesture:pinchGesture];
    self.paused = NO;
}

- (void)onMainButtonTap
{
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:smViewerSettings sender:self];
}

- (void)onShareButtonTap
{
    self.paused = NO;
    mHud.animating = TRUE;
    
    [mFractalRT applyRenderTarget];
    glClear(GL_COLOR_BUFFER_BIT);
    [mMegaFractal draw];
    [mFractalImage draw];
    ISTHandMadeUIImage* image = [self.fractalRT getResultAsUIImage];
    [mFractalRT restorePreviousRenderTarget];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [image dataUpsideDown];
        [image generateUIImage];

        dispatch_async(dispatch_get_main_queue(), ^{
            mHud.animating = NO;
            
            NSArray* texts = [ISTUtility getFractalLocStrings:self.megaFractal];
            NSString *textToShare = [NSString stringWithFormat:@"Fractal image created with @iFractalTouch (RE%@ IM%@ x%@).", [texts objectAtIndex:0], [texts objectAtIndex:1], [texts objectAtIndex:2]];
            UIImage *imageToShare = image.uiImage;
            NSURL *urlToShare = [ISTUtility getMyAppUrl];
            NSArray *activityItems = @[textToShare, imageToShare, urlToShare];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
            activityVC. excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeMessage];
            [self presentViewController:activityVC animated:TRUE completion:nil];
        });
    });
}

- (void)onBackButtonTap
{
    [[ftGlobalStates instance] updateFractalLocInfo:mMegaFractal];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:smViewerSettings]) 
    {
        ISTFractalSettingsViewController *vc = segue.destinationViewController;
        vc.segueSender = self;
        mForcePause = YES;
    }
}

- (void)forceRefresh
{
    self.paused = NO;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (mForcePause) {
        return;
    }
    
    [mMegaFractal update];
    
    if(!mMegaFractal.dirty && !mHud.animating)
    {
        self.paused = YES;
    }
    
    if (0) {//DO NOT draw to render target, as we are reading data from it
        glClearColor(0.85f, 0.85f, 0.85f, 1.0f);
        glClearStencil(0x00);
        [mFractalImage draw];
        [mHud draw:CGPointMake(mMegaFractal.absLocationX, mMegaFractal.absLocationY) scale:mMegaFractal.scale];
        return;
    }
    
    //glClearColor(0.15f, 0.65f, 0.65f, 1.0f);
    glClearColor(0.85f, 0.85f, 0.85f, 1.0f);
    glClearStencil(0x00);
    [mFractalRT applyRenderTarget];
    glClear(GL_COLOR_BUFFER_BIT);
    [mMegaFractal draw];
    [mFractalRT restorePreviousRenderTarget];
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    if ([ftTextureSelection instance].needUpdateViewer) {
        mFractalImage.blendTextureName = [ftTextureSelection instance].currentTexture.name;
        [ftTextureSelection instance].needUpdateViewer = NO;
    }
    [mFractalImage draw];
    [mHud draw:CGPointMake(mMegaFractal.absLocationX, mMegaFractal.absLocationY) scale:mMegaFractal.scale];
}

- (void)onFractalViewSettingChange
{
    [ftTextureSelection instance].needUpdateViewer = YES;
    [mMegaFractal onFractalViewSettingChange];
}

@end

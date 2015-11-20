//
//  FractalViewController.h
//  FractalPlus
//
//  Created by On Mac No5 on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "ISTButton.h"
#import "ISTMegaFractal.h"
#import "ShaderSource.h"

@class ftRenderTarget;

@interface ISTFractalViewController : GLKViewController

@property (nonatomic, strong) ISTButton* mainButton;
@property (nonatomic, strong) ISTButton* shareButton;
@property (nonatomic, strong) ISTButton* backButton;
@property (strong, nonatomic) ftRenderTarget* fractalRT;
@property (nonatomic, strong) ISTMegaFractal* megaFractal;
@property (assign, nonatomic) BOOL forcePause;

- (void)onFractalViewSettingChange;

@end

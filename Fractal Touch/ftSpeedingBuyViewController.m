//
//  ftSpeedingBuyViewController.m
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-3.
//
//

#import "ftSpeedingBuyViewController.h"
#import "ISTUtility.h"
#import <StoreKit/StoreKit.h>

@interface ftSpeedingBuyViewController ()

@end

@implementation ftSpeedingBuyViewController

- (UIButton*)theBuyButton{
    return self.buyButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [(UIScrollView*)self.view setContentSize:CGSizeMake(320, 420)];
    
    [self refreshProductStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshProductStatus{
    BOOL enabled = [ISTUtility isFeatureEnabled:self.productID];
    if (enabled) {
        [self gotoUISate:BuyViewUIState_Enabled];
    }else{
        [self gotoUISate:BuyViewUIState_Normal];
    }
}

- (void)gotoUISate:(enum BuyViewUIState) state
{
    if (state == BuyViewUIState_Normal) {
        [self.priceLoadingIndicator stopAnimating];
        
        [self.priceLoadingIndicator stopAnimating];
        self.buyFullVersionButton.hidden = YES;
        self.fullVersionText.hidden = YES;
        self.buyButton.hidden = YES;
        
        self.isEnabledText.hidden = NO;
        self.restoreButton.enabled = NO;
        self.isEnabledText.text = @"This feature is NOT enabled.";
        self.fullVersionText.hidden = NO;
        self.buyFullVersionButton.hidden = NO;
        
    }else if (state == BuyViewUIState_Enabled){
        [self.priceLoadingIndicator stopAnimating];
        self.buyFullVersionButton.hidden = YES;
        self.fullVersionText.hidden = YES;
        self.buyButton.hidden = YES;
        
        self.isEnabledText.hidden = NO;
        self.restoreButton.enabled = NO;
    }else if (state == BuyViewUIState_Processing){
        [self.priceLoadingIndicator startAnimating];
        self.buyFullVersionButton.hidden = YES;
        self.fullVersionText.hidden = YES;
        self.buyButton.hidden = NO;
        self.buyButton.enabled = NO;
        self.isEnabledText.hidden = YES;
        self.restoreButton.enabled = NO;
    }else if (state == BuyViewUIState_NoConnection){
        [self.priceLoadingIndicator stopAnimating];
        self.buyFullVersionButton.hidden = YES;
        self.fullVersionText.hidden = YES;
        self.buyButton.hidden = YES;
        
        self.isEnabledText.hidden = YES;
        self.restoreButton.enabled = NO;
    }
}

- (IBAction)buyClick:(id)sender {
    [self buyProduct];
}

- (IBAction)buyFullVersionClick:(id)sender {
    [self goToFullVersion];
}

- (NSString*)productID
{
    return [ISTUtility iapSpeedingPID];
}
@end

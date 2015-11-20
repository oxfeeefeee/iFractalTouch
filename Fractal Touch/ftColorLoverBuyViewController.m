//
//  ftColorLoverBuyViewController.m
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-2.
//
//

#import "ftColorLoverBuyViewController.h"
#import "ISTUtility.h"
#import <StoreKit/StoreKit.h>

@interface ftColorLoverBuyViewController ()

@end

@implementation ftColorLoverBuyViewController

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

- (void)gotoUISate:(enum BuyViewUIState) state
{
    if (state == BuyViewUIState_Normal) {
        [self.priceLoadingIndicator stopAnimating];
        self.fullVersionButton.hidden = NO;
        self.fullVersionDesc.hidden = NO;
        self.buyButton.hidden = NO;
        self.buyButton.enabled = YES;
        self.isEnabledText.hidden = YES;
        self.restoreButton.enabled = YES;
    }else if (state == BuyViewUIState_Enabled){
        [self.priceLoadingIndicator stopAnimating];
        self.fullVersionButton.hidden = YES;
        self.fullVersionDesc.hidden = YES;
        self.buyButton.hidden = YES;
        
        self.isEnabledText.hidden = NO;
        self.restoreButton.enabled = NO;
    }else if (state == BuyViewUIState_Processing){
        [self.priceLoadingIndicator startAnimating];
        self.fullVersionButton.hidden = YES;
        self.fullVersionDesc.hidden = YES;
        self.buyButton.hidden = NO;
        self.buyButton.enabled = NO;
        self.isEnabledText.hidden = YES;
        self.restoreButton.enabled = NO;
    }else if (state == BuyViewUIState_NoConnection){
        [self.priceLoadingIndicator stopAnimating];
        self.fullVersionButton.hidden = YES;
        self.fullVersionDesc.hidden = YES;
        self.buyButton.hidden = YES;
        
        self.isEnabledText.hidden = YES;
        self.restoreButton.enabled = NO;
    }
}

- (IBAction)buyNowClick:(id)sender {
    [self buyProduct];
}

- (IBAction)fullVersionClick:(id)sender {
    [self goToFullVersion];
}

- (NSString*)productID
{
    return [ISTUtility iapColorLoverPID];
}

@end

//
//  ftColorLoverBuyViewController.h
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-2.
//
//

#import "ftBuyViewController.h"

@interface ftColorLoverBuyViewController : ftBuyViewController 

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *fullVersionButton;
@property (weak, nonatomic) IBOutlet UILabel *fullVersionDesc;
@property (weak, nonatomic) IBOutlet UILabel *isEnabledText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *priceLoadingIndicator;

- (IBAction)buyNowClick:(id)sender;
- (IBAction)fullVersionClick:(id)sender;

- (void)gotoUISate:(enum BuyViewUIState) state;


@end

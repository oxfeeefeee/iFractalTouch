//
//  ftSpeedingBuyViewController.h
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-3.
//
//

#import "ftBuyViewController.h"

@interface ftSpeedingBuyViewController : ftBuyViewController
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *isEnabledText;
@property (weak, nonatomic) IBOutlet UILabel *fullVersionText;
@property (weak, nonatomic) IBOutlet UIButton *buyFullVersionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *priceLoadingIndicator;

- (IBAction)buyClick:(id)sender;
- (IBAction)buyFullVersionClick:(id)sender;
- (void)gotoUISate:(enum BuyViewUIState) state;

@end

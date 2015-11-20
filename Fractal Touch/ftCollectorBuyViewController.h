//
//  ftCollectorBuyViewController.h
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-3.
//
//

#import "ftBuyViewController.h"

@interface ftCollectorBuyViewController : ftBuyViewController
@property (weak, nonatomic) IBOutlet UILabel *fullVersionDesc;
@property (weak, nonatomic) IBOutlet UIButton *fullVersionButton;

@property (weak, nonatomic) IBOutlet UILabel *isEnabledText;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *priceLoadingIndicator;
- (IBAction)buyClick:(id)sender;
- (IBAction)fullVersionClick:(id)sender;
@end

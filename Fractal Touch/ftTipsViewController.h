//
//  ftTipsViewController.h
//  Fractal Touch
//
//  Created by Hao Wu on 13-1-1.
//
//

#import <UIKit/UIKit.h>

@interface ftTipsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *appNameText;
@property (weak, nonatomic) IBOutlet UILabel *appVersionText;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
- (IBAction)buyClick:(id)sender;

@end

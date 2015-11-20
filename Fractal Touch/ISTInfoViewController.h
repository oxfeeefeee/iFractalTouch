//
//  ISTSourceViewController.h
//  iShaderToy
//
//  Created by On Mac No5 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISTInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *descText;
@property (strong, nonatomic) NSString *sourceText;

@end

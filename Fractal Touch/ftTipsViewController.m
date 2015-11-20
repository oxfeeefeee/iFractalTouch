//
//  ftTipsViewController.m
//  Fractal Touch
//
//  Created by Hao Wu on 13-1-1.
//
//

#import "ftTipsViewController.h"
#import "ISTUtility.h"

@interface ftTipsViewController ()

@end

@implementation ftTipsViewController

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
    [(UIScrollView*)self.view setContentSize:CGSizeMake(320, 460)];
    
    //self.appNameText.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];;
    self.appVersionText.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (![ISTUtility isFreeVersion]) {
        self.buyButton.hidden = TRUE;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buyClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[ISTUtility getMyAppUrl]];
}
@end

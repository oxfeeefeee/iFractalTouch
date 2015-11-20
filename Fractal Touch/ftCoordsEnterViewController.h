//
//  ftCoordsEnterViewController.h
//  Fractal Touch
//
//  Created by Hao Wu on 13-1-1.
//
//

#import <UIKit/UIKit.h>

@interface ftCoordsEnterViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *realCompTF;
@property (weak, nonatomic) IBOutlet UITextField *imaginaryCompTF;
@property (weak, nonatomic) IBOutlet UITextField *zoomingCompTF;

- (IBAction)cancel:(id)sender;

- (IBAction)ok:(id)sender;

@end

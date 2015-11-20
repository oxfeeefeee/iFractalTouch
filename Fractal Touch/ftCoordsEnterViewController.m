//
//  ftCoordsEnterViewController.m
//  Fractal Touch
//
//  Created by Hao Wu on 13-1-1.
//
//

#import "ftCoordsEnterViewController.h"
#import "ftGlobalStates.h"

@interface ftCoordsEnterViewController ()

@end

@implementation ftCoordsEnterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)ok:(id)sender {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    f.locale = usLocale;
    double realc = [f numberFromString:self.realCompTF.text].doubleValue;
    double imagc = [f numberFromString:self.imaginaryCompTF.text].doubleValue;
    double zoomingc = [f numberFromString:self.zoomingCompTF.text].doubleValue;
    
    if (realc >= -2.0 && realc <= 2.0 && imagc >= -2.0 && imagc <= 2.0 && zoomingc >= 1.0 && zoomingc <= 35184372088832.0) {
        [ftGlobalStates instance].zoomingText = self.zoomingCompTF.text;
        [ftGlobalStates instance].reText = self.realCompTF.text;
        [ftGlobalStates instance].imText = self.imaginaryCompTF.text;
        [self performSegueWithIdentifier:@"directGotoSegue" sender:self];
        return;
    }
    
    
    UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"Invalid Coordinates!" message:@"Coordinate range: [-2.0, 2.0]; Zoom-in level range: [1.0, 35184372088832.0]" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [slpp show];
}
- (void)viewDidUnload {
    [self setRealCompTF:nil];
    [self setImaginaryCompTF:nil];
    [self setZoomingCompTF:nil];
    [super viewDidUnload];
}
@end

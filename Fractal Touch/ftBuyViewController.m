//
//  ftBuyViewController.m
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-2.
//
//

#import "ftBuyViewController.h"
#import "ISTUtility.h"

@interface ftBuyViewController ()

@end

@implementation ftBuyViewController

@synthesize productReqeust = mProductRequest;
@synthesize product = mProduct;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString*)productID
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    self.restoreButton  = self.navigationItem.rightBarButtonItem;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

// Add new method
- (void)restoreTapped:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    [self gotoUISate:BuyViewUIState_Processing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    self.productReqeust.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) goToFullVersion
{
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"This will take you to the App Store, proceed?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Go to App Store", nil];
    [as showFromRect:CGRectMake(0, 0, 0, 0) inView:self.view.superview animated:YES];
}

-(void) onProductRequestDone:(BOOL) success price:(NSString*) price
{
    if (success) {
        [self.theBuyButton setTitle:price forState:(UIControlStateNormal)];
        [self.theBuyButton setTitle:price forState:(UIControlStateHighlighted)];
        [self.theBuyButton setTitle:@"" forState:(UIControlStateDisabled)];
        
        [self gotoUISate:BuyViewUIState_Normal];
    }else{
        [self gotoUISate:BuyViewUIState_NoConnection];
    }
}

-(void) requestProduct
{
    NSSet * productIdentifiers = [NSSet setWithObjects:
                                  self.productID,
                                  nil];
    mProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    mProductRequest.delegate = self;
    [mProductRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    mProductRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    if (skProducts.count > 0) {
        SKProduct* pro = skProducts.lastObject;
        if ([pro.productIdentifier isEqualToString:self.productID]) {
            mProduct = pro;
            NSNumberFormatter * _priceFormatter;
            
            // Add to end of viewDidLoad
            _priceFormatter = [[NSNumberFormatter alloc] init];
            [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
            // Add to bottom of tableView:cellForRowAtIndexPath (before return cell)
            [_priceFormatter setLocale:mProduct.priceLocale];
            NSString* price = [_priceFormatter stringFromNumber:mProduct.price];
            
            [self onProductRequestDone:YES price:price];
            return;
        }
    }
    UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"Failed to get information from App Store, please check your internet connection." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [slpp show];
    [self onProductRequestDone:NO price:nil];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    mProductRequest = nil;
    mProduct = nil;
    
    [self onProductRequestDone:NO price:nil];
}

-(void) buyProduct
{
    NSLog(@"Buying %@...", mProduct.productIdentifier);
    
    [self gotoUISate:BuyViewUIState_Processing];
    
    SKPayment * payment = [SKPayment paymentWithProduct:mProduct];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    BOOL enabled = [ISTUtility isFeatureEnabled:self.productID];
    if (enabled) {
        UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"Feature restored" message:@"This feature has already been puchased before and is now restored." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [slpp show];
    }else{
        UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"Restoration failed" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [slpp show];
    }
    [self refreshProductStatus];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"Restoration failed" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [slpp show];
    }
    [self refreshProductStatus];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"The feature is now enabled!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [slpp show];
    
    [self refreshProductStatus];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction... %@", transaction.originalTransaction.payment.productIdentifier);
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        
        UIAlertView *slpp=[[UIAlertView alloc] initWithTitle:@"Transaction failed" message:transaction.error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [slpp show];
        
        [self gotoUISate:BuyViewUIState_NoConnection];
    }
    
    [self transactionCanceled];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self gotoUISate:BuyViewUIState_Normal];
}

- (void)gotoUISate:(enum BuyViewUIState) state{
}

- (void)refreshProductStatus{
    BOOL enabled = [ISTUtility isFeatureEnabled:self.productID];
    if (enabled) {
        [self gotoUISate:BuyViewUIState_Enabled];
    }else{
        if (self.product == nil) {
            [self gotoUISate:BuyViewUIState_Processing];
            [self requestProduct];
        }else{
            [self gotoUISate:BuyViewUIState_Normal];
        }
    }
}

- (void)transactionCanceled{
    [self gotoUISate:BuyViewUIState_Normal];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [ISTUtility enableFeature:productIdentifier];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[ISTUtility getMyAppUrl]];
    }
}

@end

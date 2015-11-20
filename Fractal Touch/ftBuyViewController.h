//
//  ftBuyViewController.h
//  Fractal Touch
//
//  Created by Hao Wu on 13-2-2.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

enum BuyViewUIState{
    BuyViewUIState_Normal,
    BuyViewUIState_Enabled,
    BuyViewUIState_Processing,
    BuyViewUIState_NoConnection,
};

@interface ftBuyViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIActionSheetDelegate>

@property (nonatomic, readonly)NSString* productID;
@property (nonatomic, weak, readonly)UIButton* theBuyButton;
@property (nonatomic, strong) SKProductsRequest* productReqeust;
@property (nonatomic, strong) SKProduct* product;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *restoreButton;

- (void)goToFullVersion;

- (void)requestProduct;

- (void)buyProduct;

- (void)onProductRequestDone:(BOOL) success price:(NSString*) price;

- (void)gotoUISate:(enum BuyViewUIState) state;

- (void)refreshProductStatus;

@end

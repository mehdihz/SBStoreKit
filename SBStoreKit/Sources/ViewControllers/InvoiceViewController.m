//
//  InvoiceViewController.m
//  SBStoreKit
//
//  Created by Mehdi on 3/25/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "InvoiceViewController.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import "FilledButton.h"
#import "SibcheHelper.h"
#import "Constants.h"

@interface InvoiceViewController ()

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet FilledButton *confirmButton;


@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBalanceLabel;

@end

@implementation InvoiceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadPurchasablePackage];

    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self newNotification:note];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self paymentCanceledWithNotifying:NO];
}

- (void)paymentSucceeded {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.confirmButton removeTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmButton removeTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
        
        self.confirmButton.backgroundColor = [UIColor colorWithRed:0 green:200.0/255.0 blue:83.0/255.0 alpha:1];
        [self.confirmButton setTitle:@"پرداخت شما با موفقیت انجام شد" forState:UIControlStateNormal];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_SUCCESSFUL object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)paymentCanceledWithNotifying:(BOOL)withNotifying {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (withNotifying) {
            [self.confirmButton removeTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
            [self.confirmButton removeTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
            
            self.confirmButton.backgroundColor = UIColor.redColor;
            [self.confirmButton setTitle:@"عدم پرداخت موفق" forState:UIControlStateNormal];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_CANCELED object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_CANCELED object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)loadPurchasablePackage{
    [self setLoading:YES withMessage:@""];
    NSString* packageId = [DataManager sharedManager].purchasingPackageId;
    NSString* url = [NSString stringWithFormat:@"sdk/inAppPurchasePackages/%@/purchase", packageId];
    NSString* token = [SibcheHelper getToken];
    [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        [DataManager sharedManager].showingInvoiceData = json;
        [self fillPackageData];
//        [self setLoading:NO withMessage:@""];
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        // TODO: We should handle errors in a better way
//        [self setLoading:NO withMessage:@"در روند خرید مشکلی پیش آمد. لطفا دوباره امتحان کنید."];
    }];
}

- (void)fillPackageData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
        if (showingInvoiceData) {
            NSString* name = [showingInvoiceData valueForKeyPath:@"data.attributes.name"];
            NSNumber* totalPrice = [showingInvoiceData valueForKeyPath:@"data.attributes.total_price"];
            NSNumber* price = [showingInvoiceData valueForKeyPath:@"data.attributes.price"];
            self.packageNameLabel.text = name;
            NSMutableAttributedString* attributedText = nil;
            NSString* priceText = [NSString stringWithFormat:@"%@ تومان", [SibcheHelper formatNumber:price]];
            NSString* totalPriceText = [NSString stringWithFormat:@"%@ تومان", [SibcheHelper formatNumber:totalPrice]];
            if (price > totalPrice) {
                attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"قیمت: %@   %@", priceText, totalPriceText]];
                [attributedText addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(6, [priceText length])];
                [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1] range:NSMakeRange(6, [priceText length])];
            }else{
                attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"قیمت: %@", priceText]];
                [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1] range:NSMakeRange(6, [priceText length])];
            }
            [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"RiSans-Bold" size:14] range:NSMakeRange(0, 5)];
            self.packagePriceLabel.attributedText = attributedText;
            
            NSDictionary* profileData = [DataManager sharedManager].profileData;
            int balance = 0;
            if (profileData) {
                NSNumber* balanceData = [profileData valueForKeyPath:@"data.attributes.balance"];
                if (balanceData && [balanceData isKindOfClass:[NSNumber class]]) {
                    balance = [(NSNumber*)balanceData intValue];
                }
            }
            
            NSString* balanceText = @"";
            NSString* buttonTitle = @"";
            
            balanceText = [NSString stringWithFormat:@"موجودی: %@ تومان", [SibcheHelper formatNumber:[NSNumber numberWithInt:balance]]];
            buttonTitle = @"پرداخت";

            if (balance >= [totalPrice intValue]) {
                [self.confirmButton removeTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [self.confirmButton addTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.confirmButton removeTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [self.confirmButton addTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [DataManager sharedManager].balanceToAdd = [totalPrice intValue] - balance;
            }
            self.userBalanceLabel.text = balanceText;
            [self.confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
    });
}

- (void)confirmPurchase:(UIButton*)sender {
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    if (!showingInvoiceData) {
        return;
    }
    
    NSString* invoiceId = [showingInvoiceData valueForKeyPath:@"data.id"];
    NSString* url = [NSString stringWithFormat:@"invoices/%@/pay", invoiceId];
    NSString* token = [SibcheHelper getToken];
    [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                [self paymentSucceeded];
            }];
        });
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        [self setLoading:NO withMessage:@"در روند خرید مشکلی پیش آمد. لطفا دوباره امتحان کنید."];
    }];
}

- (void)sendToAddCreditAndPurchase:(UIButton*)sender {
    int balance = [DataManager sharedManager].balanceToAdd;
    if (balance < 100) {
        balance = 100;
    }
    NSString* token = [SibcheHelper getToken];
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    NSDictionary* data = @{
                           @"invoice_id": showingInvoiceData && [showingInvoiceData valueForKeyPath:@"data.id"] ? [showingInvoiceData valueForKeyPath:@"data.id"] : @"",
                           @"price": [[NSNumber numberWithInt:balance] stringValue]
                           };
    [[NetworkManager sharedManager] post:@"transactions/create" withData:data withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        NSString* payLink = [json valueForKeyPath:@"data.attributes.pay_link"];
        NSString* transactionId = [json valueForKeyPath:@"data.id"];
        if (payLink && [payLink isKindOfClass:[NSString class]] && payLink.length > 0) {
            NSString* openUrl=[NSString stringWithFormat:@"%@://SBStoreKit/transactions/%@", [DataManager sharedManager].appScheme, transactionId];
            NSString* escapedOpenUrl = [openUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString* url = [NSString stringWithFormat:@"%@?callback=%@", payLink, escapedOpenUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
            });
        }else{
            // TODO: We should improve user experience on errors
            [self paymentCanceledWithNotifying:YES];
        }
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        // TODO: We should improve user experience on errors
        [self paymentCanceledWithNotifying:YES];
    }];

}

- (void)newNotification:(NSNotification*)note {
    NSString* name = note.name;
    if ([name isEqualToString:ADDCREDIT_SUCCESSFUL]) {
        [self paymentSucceeded];
    } else if ([name isEqualToString:ADDCREDIT_CANCELED]){
        [self paymentCanceledWithNotifying:YES];
    }
}

- (void)setLoading:(BOOL)isLoading withMessage:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isLoading || message.length > 0) {
            self.loadingView.hidden = NO;
            if (isLoading) {
                [self.loadingIndicator startAnimating];
            } else {
                [self.loadingIndicator stopAnimating];
            }
            self.loadingLabel.text = message;
        }else{
            self.loadingView.hidden = YES;
        }
    });
}

@end

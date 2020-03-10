//
//  InvoiceViewController.m
//  SibcheStoreKit
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
#import "SibcheError.h"
#import "SibcheStoreKit.h"
#import "VoucherButton.h"

@interface InvoiceViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *loadingIndicator;
@property (weak, nonatomic) IBOutlet FilledButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;


@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *packageDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBalanceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voucherViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *showVourcherButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceAndButtonSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIView *voucherView;
@property (weak, nonatomic) IBOutlet VoucherButton *voucherButton;
@property (weak, nonatomic) IBOutlet UITextField *voucherTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorViewHeightConstraint;

@property NSDictionary* voucherItem;

@end

@implementation InvoiceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadPurchasablePackage];

    [SibcheHelper setIconPropertiesForImageView:self.imageView];

    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self newNotification:note];
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self paymentCanceledWithNotifying:NO];
}

- (void)paymentSucceeded:(NSObject*)attachedObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.confirmButton removeTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmButton removeTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
        
        self.confirmButton.backgroundColor = [UIColor colorWithRed:0 green:200.0/255.0 blue:83.0/255.0 alpha:1];
        [self.confirmButton setTitle:@"پرداخت شما با موفقیت انجام شد" forState:UIControlStateNormal];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_SUCCESSFUL object:attachedObject];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}
    
- (void)newNotification:(NSNotification*)note {
    NSString* name = note.name;
    if ([name isEqualToString:ADDCREDIT_SUCCESSFUL]) {
        [self.closeButton setEnabled:NO];
        NSString* packageId = [DataManager sharedManager].purchasingPackageId;
        NSDictionary* purchasingPackage = [DataManager sharedManager].purchasingPackage;
        NSString* packageGroup = purchasingPackage && [purchasingPackage valueForKeyPath:@"attributes.group"] ? [purchasingPackage valueForKeyPath:@"attributes.group"] : @"";

        [SibcheStoreKit fetchActiveInAppPurchasePackages:^(BOOL isSuccessful, SibcheError *error, NSArray *purchasePackagesArray) {
            BOOL called = NO;
            if (isSuccessful) {
                SibchePurchasePackage* purchasePackage = nil;
                for (int i = 0; i < purchasePackagesArray.count; i++) {
                    purchasePackage = purchasePackagesArray[i];
                    if ([purchasePackage.code isEqualToString:packageId] || (purchasePackage.package && purchasePackage.package.packageId && [purchasePackage.package.packageId isEqualToString:packageId]) ||
                        (purchasePackage.package && purchasePackage.package.code && [purchasePackage.package.code isEqualToString:packageId]) ||
                        (packageGroup.length > 0 && [purchasePackage.code isEqualToString:packageGroup])) {
                        called = YES;
                        [self paymentSucceeded:purchasePackage];
                    }
                }
            }
            if (!called) {
                [self paymentCanceledWithNotifying:YES];
            }
        }];
    }else if ([name isEqualToString:ADDCREDIT_CANCELED]){
        [self.closeButton setEnabled:NO];
        [self paymentCanceledWithNotifying:YES];
    }
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
        [self extractPackage];
        [self fillPackageData];
        [self setLoading:NO withMessage:@""];
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
        if (httpStatusCode == 503) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"ShowMaintenanceSegue" sender:self];
            });
        }else{
            SibcheError* error = [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode];
            NSString* errorMessage = @"در روند خرید مشکلی پیش آمده است. لطفا دوباره امتحان کنید.";
            if ([error.errorCode intValue] == alreadyHaveThisPackageError) {
                [SibcheStoreKit fetchActiveInAppPurchasePackages:^(BOOL isSuccessful, SibcheError *error, NSArray *purchasePackagesArray) {
                    if (isSuccessful) {
                        SibchePurchasePackage* purchasePackage = nil;
                        for (int i = 0; i < purchasePackagesArray.count; i++) {
                            purchasePackage = purchasePackagesArray[i];
                            if ([purchasePackage.code isEqualToString:packageId] || (purchasePackage.package && purchasePackage.package.packageId && [purchasePackage.package.packageId isEqualToString:packageId])) {
                                [self paymentSucceeded:purchasePackage];
                                return;
                            }
                        }
                    } else {
                        NSString* errorMessage = @"شما قبلا این بسته را خریداری کرده<U+200C>اید. لطفا در صورت قابل مصرف بودن، آن را مصرف کنید و سپس دوباره اقدام به خرید کنید.";
                        [self setLoading:NO withMessage:errorMessage];
                        
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:response];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                        return;
                    }
                }];
            } else {
                [self setLoading:NO withMessage:errorMessage];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:response];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }
    }];
}

- (void)fillPackageData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
        if (showingInvoiceData) {
            NSString* name = [showingInvoiceData valueForKeyPath:@"data.attributes.name"];
            self.packageNameLabel.text = name;

            NSString* description = [showingInvoiceData valueForKeyPath:@"data.attributes.description"];
            self.packageDescriptionLabel.text = description;

            NSNumber* totalPrice = [showingInvoiceData valueForKeyPath:@"data.attributes.total_price"];
            NSNumber* price = [showingInvoiceData valueForKeyPath:@"data.attributes.price"];
            NSMutableAttributedString* attributedText = nil;
            NSString* priceText = [NSString stringWithFormat:@"%@ تومان", [SibcheHelper formatNumber:price]];
            NSString* totalPriceText = [NSString stringWithFormat:@"%@ تومان", [SibcheHelper formatNumber:totalPrice]];
            if ([price intValue] != [totalPrice intValue]) {
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
            
            NSMutableAttributedString* balanceText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"موجودی: %@ تومان", [SibcheHelper formatNumber:[NSNumber numberWithInt:balance]]]];
            [balanceText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"RiSans-Bold" size:14] range:NSMakeRange(0, 7)];
            self.userBalanceLabel.attributedText = balanceText;


            NSString* buttonTitle = @"پرداخت";
            [self.confirmButton setTitle:buttonTitle forState:UIControlStateNormal];

            if (balance >= [totalPrice intValue]) {
                [self.confirmButton removeTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [self.confirmButton addTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.confirmButton removeTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [self.confirmButton addTarget:self action:@selector(sendToAddCreditAndPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [DataManager sharedManager].balanceToAdd = [totalPrice intValue] - balance;
            }
            [self fillVoucherData];
        }
    });
}

- (void)fillVoucherData{
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    if (showingInvoiceData) {
        NSString* voucherId = [showingInvoiceData valueForKeyPath:@"data.relationships.voucherItem.data.id"];
        NSString* voucherType = [showingInvoiceData valueForKeyPath:@"data.relationships.voucherItem.data.type"];
        if(voucherId && voucherId.length > 0 && voucherType && voucherType.length > 0){
            NSDictionary* voucherItem = [SibcheHelper fetchIncludedObject:voucherId withType:voucherType fromData:showingInvoiceData];
            if (voucherItem && [voucherItem isKindOfClass:[NSDictionary class]]) {
                self.voucherItem = voucherItem;
                NSString* code = [voucherItem valueForKeyPath:@"attributes.code"];
                self.voucherTextField.text = code;
                [self.voucherButton changeButtonMode:VoucherButtonModeDelete];
                [self prepareViewForVoucher];
                return;
            }
        }
    }
    [self.voucherButton changeButtonMode:VoucherButtonModeNormal];
}

- (void)extractPackage{
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    if (showingInvoiceData) {
        NSString* packageId = [showingInvoiceData valueForKeyPath:@"data.relationships.saleable.data.id"];
        NSString* packageType = [showingInvoiceData valueForKeyPath:@"data.relationships.saleable.data.type"];
        if(packageId && packageId.length > 0 && packageType && packageType.length > 0){
            NSDictionary* packageItem = [SibcheHelper fetchIncludedObject:packageId withType:packageType fromData:showingInvoiceData];
            if (packageItem && [packageItem isKindOfClass:[NSDictionary class]]) {
                [DataManager sharedManager].purchasingPackage = packageItem;
            }
        }
    }
}

- (void)confirmPurchase:(UIButton*)sender {
    [self dismissKeyboard];
    
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    if (!showingInvoiceData) {
        return;
    }
    
    NSString* invoiceId = [showingInvoiceData valueForKeyPath:@"data.id"];
    NSString* url = [NSString stringWithFormat:@"invoices/%@/pay", invoiceId];
    NSString* token = [SibcheHelper getToken];
    [self.confirmButton setLoading:YES];
    [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        [self.confirmButton setLoading:NO];
        
        NSString* packageId = [DataManager sharedManager].purchasingPackageId;
        [SibcheStoreKit fetchActiveInAppPurchasePackages:^(BOOL isSuccessful, SibcheError *error, NSArray *purchasePackagesArray) {
            BOOL called = NO;
            if (isSuccessful) {
                SibchePurchasePackage* purchasePackage = nil;
                for (int i = 0; i < purchasePackagesArray.count; i++) {
                    purchasePackage = purchasePackagesArray[i];
                    if ([purchasePackage.code isEqualToString:packageId] || (purchasePackage.package && purchasePackage.package.packageId && [purchasePackage.package.packageId isEqualToString:packageId])) {
                        called = YES;
                        [self paymentSucceeded:purchasePackage];
                    }
                }
            }
            if (!called) {
                [self paymentCanceledWithNotifying:YES];
            }
        }];
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
        if (httpStatusCode == 503) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"ShowMaintenanceSegue" sender:self];
            });
        }else{
            [self.confirmButton setLoading:NO];
            NSString* errorMessage = @"در روند خرید مشکلی پیش آمده است. لطفا دوباره امتحان کنید.";

            [self setLoading:NO withMessage:errorMessage];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:response];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
}

- (void)setLoading:(BOOL)isLoading withMessage:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isLoading || message.length > 0) {
            self.loadingView.hidden = NO;
            if (isLoading) {
                [self.loadingIndicator setHidden:NO];
            } else {
                [self.loadingIndicator setHidden:YES];
            }
            self.loadingLabel.text = message;
        }else{
            self.loadingView.hidden = YES;
        }
    });
}

- (void)sendToAddCreditAndPurchase:(UIButton*)sender {
    [self dismissKeyboard];

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
    [self.confirmButton setLoading:YES];
    [[NetworkManager sharedManager] post:@"transactions/create" withData:data withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        [self.confirmButton setLoading:NO];
        NSString* payLink = [json valueForKeyPath:@"data.attributes.pay_link"];
        NSString* transactionId = [json valueForKeyPath:@"data.id"];
        if (payLink && [payLink isKindOfClass:[NSString class]] && payLink.length > 0) {
            NSString* successOpenUrl=[NSString stringWithFormat:@"%@://SibcheStoreKit/transactions/%@/success", [DataManager sharedManager].appScheme, transactionId];
            NSString* successEscapedOpenUrl = [successOpenUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString* failureOpenUrl=[NSString stringWithFormat:@"%@://SibcheStoreKit/transactions/%@/failure", [DataManager sharedManager].appScheme, transactionId];
            NSString* failureEscapedOpenUrl = [failureOpenUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString* url = [NSString stringWithFormat:@"%@?autoInvoicePay=true&successCallback=%@&failureCallback=%@", payLink, successEscapedOpenUrl, failureEscapedOpenUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (@available(iOS 10, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }
            });
        }else{
            [self setLoading:NO withMessage:@"لینک پرداخت نامعتبر است. لطفا دوباره تلاش نمایید و یا از پشتیبانی سیبچه راهنمایی بخواهید."];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
        if (httpStatusCode == 503) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"ShowMaintenanceSegue" sender:self];
            });
        }else{
            [self.confirmButton setLoading:NO];
            [self setLoading:NO withMessage:@"در آماده‌سازی لینک پرداخت مشکلی پیش آمد. لطفا اینترنت خود را چک کرده و دوباره امتحان نمایید."];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILED object:response];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
}

- (void)prepareViewForVoucher{
    self.priceAndButtonSpacingConstraint.active = NO;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.voucherViewHeightConstraint.constant = 57;
                         self.showVourcherButton.hidden = YES;
                         self.voucherView.hidden = NO;
                         [self.view layoutIfNeeded];
                     }];
}

- (IBAction)voucherOpenPressed:(id)sender {
    [self prepareViewForVoucher];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.voucherTextField becomeFirstResponder];
    });
}

- (IBAction)voucherApplyPressed:(id)sender {
    [self dismissKeyboard];

    self.errorViewHeightConstraint.constant = 0;
    [self.view layoutIfNeeded];

    [self.voucherButton changeButtonMode:VoucherButtonModeLoading];

    NSString* token = [SibcheHelper getToken];
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    NSString* invoiceId = showingInvoiceData && [showingInvoiceData valueForKeyPath:@"data.id"] ? [showingInvoiceData valueForKeyPath:@"data.id"] : @"";

    if (self.voucherItem) {
        NSDictionary* data = @{
                               };
        [[NetworkManager sharedManager] post:[NSString stringWithFormat:@"invoices/%@/removeVoucher", invoiceId] withData:data withAdditionalHeaders:nil withToken:token withSuccess:^(NSString * _Nullable response, NSDictionary * _Nullable json) {
            self.voucherItem = nil;
            [DataManager sharedManager].showingInvoiceData = json;
            [self fillPackageData];
        } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString * _Nullable response) {
            SibcheError* error = [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode];
            NSString* errorMessage = error.message ? error.message : @"در روند حذف کد تخفیف مشکلی پیش آمد.";
            [self.voucherButton changeButtonMode:VoucherButtonModeError];
            [self setErrorMessage:errorMessage];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.voucherButton changeButtonMode:VoucherButtonModeDelete];
                [self setErrorMessage:@""];
            });
        }];
    }else{
        NSDictionary* data = @{
                               @"code": self.voucherTextField.text
                               };
        [[NetworkManager sharedManager] post:[NSString stringWithFormat:@"invoices/%@/applyVoucher", invoiceId] withData:data withAdditionalHeaders:nil withToken:token withSuccess:^(NSString * _Nullable response, NSDictionary * _Nullable json) {
            [DataManager sharedManager].showingInvoiceData = json;
            [self fillPackageData];
        } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString * _Nullable response) {
            SibcheError* error = [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode];
            NSString* errorMessage = error.message ? error.message : @"در روند ثبت کد تخفیف مشکلی پیش آمد.";
            [self.voucherButton changeButtonMode:VoucherButtonModeError];
            [self setErrorMessage:errorMessage];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.voucherButton changeButtonMode:VoucherButtonModeNormal];
                [self setErrorMessage:@""];
            });
        }];
    }
}

- (void)setErrorMessage:(NSString*)errorMessage{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorMessage && errorMessage.length > 0) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.errorViewHeightConstraint.constant = 57;
                                 self.errorLabel.text = errorMessage;
                                 [self.view layoutIfNeeded];
                             }];
        }else{
            if (!self.voucherTextField.isFirstResponder) {
                self.errorViewHeightConstraint.constant = 0;
            }
            self.errorLabel.text = @"";
            [self.view layoutIfNeeded];
        }

    });
}

- (IBAction)voucherTextFieldReturned:(id)sender {
    [self voucherApplyPressed:self];
}

- (IBAction)closeButton:(id)sender {
}
@end

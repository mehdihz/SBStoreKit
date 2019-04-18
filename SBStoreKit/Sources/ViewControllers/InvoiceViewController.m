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
@property (weak, nonatomic) IBOutlet UIView *invoiceView;
@property (weak, nonatomic) IBOutlet FilledButton *confirmButton;


@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *packageDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBalanceLabel;

@end

@implementation InvoiceViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadPurchasablePackage];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self paymentCanceled];
}

- (void)paymentSucceeded{
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_SUCCESSFUL object:nil];
}

- (void)paymentCanceled{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_CANCELED object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
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
        [self setLoading:NO withMessage:@""];
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        [self setLoading:NO withMessage:@"در روند خرید مشکلی پیش آمد. لطفا دوباره امتحان کنید."];
    }];
}

- (void)fillPackageData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
        if (showingInvoiceData) {
            NSString* name = [showingInvoiceData valueForKeyPath:@"data.attributes.name"];
            NSString* description = [showingInvoiceData valueForKeyPath:@"data.attributes.description"];
            NSNumber* totalPrice = [showingInvoiceData valueForKeyPath:@"data.attributes.total_price"];
            NSNumber* price = [showingInvoiceData valueForKeyPath:@"data.attributes.price"];
            self.packageNameLabel.text = name;
            self.packageDescriptionLabel.text = description;
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
            
            if (balance >= [totalPrice intValue]) {
                balanceText = [NSString stringWithFormat:@"موجودی: %@ تومان", [SibcheHelper formatNumber:[NSNumber numberWithInt:balance]]];
                buttonTitle = @"پرداخت";
                [self.confirmButton removeTarget:self action:@selector(addCredit:) forControlEvents:UIControlEventTouchUpInside];
                [self.confirmButton addTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                balanceText = @"موجودی شما کافی نیست.";
                buttonTitle = @"افزایش اعتبار";
                [self.confirmButton removeTarget:self action:@selector(confirmPurchase:) forControlEvents:UIControlEventTouchUpInside];
                [self.confirmButton addTarget:self action:@selector(addCredit:) forControlEvents:UIControlEventTouchUpInside];
                [DataManager sharedManager].balanceToAdd = [totalPrice intValue] - balance;
            }
            self.userBalanceLabel.text = balanceText;
            [self.confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
    });
}

-(void)confirmPurchase:(UIButton*)sender{
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

-(void)addCredit:(UIButton*)sender{
    [self performSegueWithIdentifier:@"ShowAddCreditSegue" sender:self];
}


- (void)setLoading:(BOOL)isLoading withMessage:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isLoading || message.length > 0) {
            self.loadingView.hidden = NO;
            self.invoiceView.hidden = YES;
            if (isLoading) {
                [self.loadingIndicator startAnimating];
            } else {
                [self.loadingIndicator stopAnimating];
            }
            self.loadingLabel.text = message;
        }else{
            self.loadingView.hidden = YES;
            self.invoiceView.hidden = NO;
        }
    });
}

@end

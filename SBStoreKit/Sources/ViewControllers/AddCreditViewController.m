//
//  AddCreditViewController.m
//  SBStoreKit
//
//  Created by Mehdi on 3/25/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "AddCreditViewController.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import "FilledButton.h"
#import "CustomTextField.h"
#import "SibcheHelper.h"
#import "Constants.h"

@interface AddCreditViewController ()

@property (weak, nonatomic) IBOutlet CustomTextField *creditTextField;
@property long balanceToAdd;

@end

@implementation AddCreditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self setInitBalance];
    [self prepareForEndOfEditing];
    self.creditTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:nil object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self newNotification:note];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)newNotification:(NSNotification*)note {
    NSString* name = note.name;
    if ([name isEqualToString:ADDCREDIT_SUCCESSFUL]) {
        NSString* token = [SibcheHelper getToken];
        [[NetworkManager sharedManager] get:@"profile" withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
            [DataManager sharedManager].profileData = json;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else if ([name isEqualToString:ADDCREDIT_CANCELED]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self paymentCanceled];
}

- (void)paymentCanceled {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_CANCELED object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)plusButtonPressed:(id)sender {
    [self dismissKeyboard];
    self.balanceToAdd += 1000;
    [self prepareForEndOfEditing];
}

- (IBAction)minusButtonPressed:(id)sender {
    [self dismissKeyboard];
    self.balanceToAdd -= 1000;
    [self prepareForEndOfEditing];
}

- (void)setInitBalance {
    int balanceToAdd = [DataManager sharedManager].balanceToAdd;
    if (!balanceToAdd) {
        self.balanceToAdd = 5000;
    } else if (balanceToAdd < 100) {
        self.balanceToAdd = 100;
    } else {
        self.balanceToAdd = balanceToAdd;
    }
}

- (void)prepareForEndOfEditing {
    if (self.balanceToAdd < 100) {
        self.balanceToAdd = 100;
    }
    
    NSString* balanceToAddText = [NSString stringWithFormat:@"%@ تومان", [SibcheHelper formatNumber:[NSNumber numberWithLong:self.balanceToAdd]]];
    [self.creditTextField setText:balanceToAddText];
}

- (void)prepareForBeginningOfEditing {
    NSString* balanceToAddText = [NSString stringWithFormat:@"%@", [SibcheHelper formatNumber:[NSNumber numberWithLong:self.balanceToAdd]]];
    [self.creditTextField setText:balanceToAddText];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self prepareForBeginningOfEditing];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* oldStr = self.creditTextField.text;
    NSString* newStr = [oldStr stringByReplacingCharactersInRange:range withString: string];
    long number = [SibcheHelper extractNumberFromString:newStr];
    self.balanceToAdd = number;
    if (newStr.length > 0) {
        self.creditTextField.text = [SibcheHelper formatNumber:[NSNumber numberWithLong:number]];
    }else{
        self.creditTextField.text = @"";
    }
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self prepareForEndOfEditing];
}

- (IBAction)confirmButtonPressed:(id)sender {
    [self dismissKeyboard];
    [self prepareForEndOfEditing];
    
    NSString* token = [SibcheHelper getToken];
    NSDictionary* showingInvoiceData = [DataManager sharedManager].showingInvoiceData;
    NSDictionary* data = @{
                 @"invoice_id": showingInvoiceData && [showingInvoiceData valueForKeyPath:@"data.id"] ? [showingInvoiceData valueForKeyPath:@"data.id"] : @"",
                 @"price": [[NSNumber numberWithLong:self.balanceToAdd] stringValue]
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
            [self paymentCanceled];
        }
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        // TODO: We should improve user experience on errors
        [self paymentCanceled];
    }];
}

@end

//
//  PhoneGettingViewController.m
//  SBStoreKit
//
//  Created by Mehdi on 2/19/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "PhoneGettingViewController.h"
#import "NetworkManager.h"
#import "PhoneVerificationViewController.h"
#import "Constants.h"
#import "SibcheHelper.h"
#import "DataManager.h"

@interface PhoneGettingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation PhoneGettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneTextField.delegate=self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self clearError];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)closeButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_CANCELED object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingChanged:(id)sender {
    NSString* text = [SibcheHelper changeNumberFormat:self.phoneTextField.text changeToPersian:YES];
    self.phoneTextField.text = [SibcheHelper numberizeText:text];
}

- (IBAction)confirmButtonPressed:(id)sender {
    [self.phoneTextField resignFirstResponder];
    NSString* phoneText = [SibcheHelper changeNumberFormat:self.phoneTextField.text changeToPersian:NO];
    if (![SibcheHelper isValidPhone:phoneText]) {
        [self showError:@"فرمت شماره موبایل درست نیست."];
        return;
    }

    [DataManager sharedManager].userPhoneNumber = phoneText;
    
    NSDictionary* data = @{
                 @"mobile":phoneText
                 };
    
    [[NetworkManager sharedManager] post:@"profile/sendCode" withData:data withAdditionalHeaders:nil withToken:nil  withSuccess:^(NSString *response, NSDictionary *json) {
        [DataManager sharedManager].lastSendCodeTime = [NSDate date];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ShowVerificationSegue" sender:self];
        });
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        [self showError:@"خطا در ارتباط با مرکز. لطفا از اتصال اینترنت مطمئن شوید و دوباره امتحان نمایید."];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self confirmButtonPressed:self];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self clearError];
    return YES;
}

- (void)showError:(NSString*)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messageLabel.textColor = [UIColor redColor];
        self.messageLabel.text = error;
        self.messageLabel.hidden = NO;
    });
}

- (void)clearError{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messageLabel.text = @"";
        self.messageLabel.hidden = YES;
    });
}

@end

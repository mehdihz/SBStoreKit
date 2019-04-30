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

@interface PhoneGettingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation PhoneGettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneTextField.delegate=self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[SBKeyboardManager defaultManager] addObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[SBKeyboardManager defaultManager] removeObserver:self];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)closeButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_CANCELED object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingChanged:(id)sender {
    self.phoneTextField.text = [SibcheHelper changeNumberFormat:self.phoneTextField.text changeToPersian:YES];
}

- (IBAction)confirmButtonPressed:(id)sender {
    [self.phoneTextField resignFirstResponder];
    NSString* phoneText = [SibcheHelper changeNumberFormat:self.phoneTextField.text changeToPersian:NO];
    if (![SibcheHelper isValidPhone:phoneText]) {
        [self showError:@"فرمت شماره موبایل درست نیست."];
        return;
    }
    
    NSDictionary* data = @{
                 @"mobile":phoneText
                 };
    
    [[NetworkManager sharedManager] post:@"profile/sendCode" withData:data withAdditionalHeaders:nil withToken:nil  withSuccess:^(NSString *response, NSDictionary *json) {
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
//        self.messageLabel.textColor = [UIColor redColor];
//        self.messageLabel.text = error;
//        self.messageLabel.hidden = NO;
    });
}

- (void)clearError{
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.messageLabel.text = @"";
//        self.messageLabel.hidden = YES;
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController* vc = segue.destinationViewController;
    if ([vc isKindOfClass:[PhoneVerificationViewController class]]) {
        PhoneVerificationViewController* verificationVc = (PhoneVerificationViewController*)vc;
        NSString* phoneText = [SibcheHelper changeNumberFormat:self.phoneTextField.text changeToPersian:NO];
        verificationVc.phone = phoneText;
    }
}

- (void)keyboardChangedWithTransition:(SBKeyboardTransition)transition{
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[SBKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        CGRect bottomViewframe = self.bottomView.frame;
        bottomViewframe.origin.y = kbFrame.origin.y - bottomViewframe.size.height;
        self.bottomView.frame = bottomViewframe;
    } completion:^(BOOL finished) {
        
    }];
}
@end

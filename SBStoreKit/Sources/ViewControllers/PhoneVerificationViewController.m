//
//  PhoneVerificationViewController.m
//  SBStoreKit
//
//  Created by Mehdi on 2/19/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "PhoneVerificationViewController.h"
#import "NetworkManager.h"
#import "Constants.h"
#import "SibcheHelper.h"
#import "DataManager.h"
#import "FilledButton.h"

@interface PhoneVerificationViewController ()

@property (weak, nonatomic) IBOutlet FilledButton *confirmButton;
@property (weak, nonatomic) IBOutlet UITextField *verificationTextField;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendCodeButton;

@property NSTimer* timer;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.verificationTextField.delegate=self;
    NSString* encodedPhone = [SibcheHelper changeNumberFormat:[DataManager sharedManager].userPhoneNumber changeToPersian:YES];
    self.topLabel.text = [NSString stringWithFormat:@"کد ارسال شده به %@ را وارد کنید", encodedPhone];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self clearError];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateResendButton) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)updateResendButton{
    NSDate* lastSendCode = [DataManager sharedManager].lastSendCodeTime;
    NSDate* now = [NSDate date];
    NSTimeInterval diff = [now timeIntervalSinceDate:lastSendCode];
    if (diff > 90) {
        // Enable resend button
        [self setNormalModeForResendButton];
    }else{
        // Disable resend button and set to remaining time
        [self setTimeTextForResendButton:90-lroundf(diff)];
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_CANCELED object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingChanged:(id)sender {
    NSString* text = [SibcheHelper changeNumberFormat:self.verificationTextField.text changeToPersian:YES];
    self.verificationTextField.text = [SibcheHelper numberizeText:text];
}

- (IBAction)confirmButtonPressed:(id)sender {
    [self.verificationTextField resignFirstResponder];
    NSString* verificationText = [SibcheHelper changeNumberFormat:self.verificationTextField.text changeToPersian:NO];
    if (verificationText.length < 4) {
        [self showError:@"فرمت کد تایید درست نمی‌باشد."];
        return;
    }
    
    NSDictionary* data = @{
                 @"mobile": [DataManager sharedManager].userPhoneNumber,
                 @"code": verificationText
                 };
    
    [self.confirmButton setLoading:YES];
    [[NetworkManager sharedManager] post:@"profile/authenticate" withData:data withAdditionalHeaders:[SibcheHelper getHttpHeaders] withToken:nil withSuccess:^(NSString *response, NSDictionary *json){
        [self.confirmButton setLoading:NO];
        if (json) {
            id token = [json valueForKeyPath:@"meta.token"];
            if (token && [token isKindOfClass: [NSString class]]) {
                [SibcheHelper setToken:token];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSFUL object:nil];
            }else{
                [self showError:@"در روند ثبت اطلاعات مشکلی پیش آمد. لطفا از پشتیبانی سیبچه راهنمایی بگیرید."];
            }
        }else{
            [self showError:@"مشکل در گرفتن اطلاعات سیبچه. لطفا از پشتیبانی سیبچه راهنمایی بگیرید."];
        }
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode){
        [self.confirmButton setLoading:NO];
        if (httpStatusCode == 401) {
            [self showError:@"کد وارد شده درست نمی‌باشد"];
        }else{
            [self showError:@"خطا در ارتباط با مرکز. لطفا از اتصال اینترنت مطمئن شوید."];
        }
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

- (void)setTimeTextForResendButton:(NSInteger)remainingTime {
    int seconds = remainingTime % 60;
    int minutes = floor(remainingTime / 60);
    NSString* str = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    str = [SibcheHelper changeNumberFormat:str changeToPersian:YES];
    [self.resendCodeButton setEnabled:NO];

    [UIView performWithoutAnimation:^{
        [self.resendCodeButton setTitle:str forState:UIControlStateNormal];
        [self.resendCodeButton setTintColor:[UIColor blackColor]];
        [self.resendCodeButton layoutIfNeeded];
    }];
}

- (void)setNormalModeForResendButton {
    [self.resendCodeButton setEnabled:YES];
    [self.resendCodeButton setTitle:@"دریافت مجدد کد تایید" forState:UIControlStateNormal];
    [self.resendCodeButton setTintColor:[UIColor colorWithRed:30.0/255.0 green:136.0/255.0 blue:229.0/255.0 alpha:1]];
}

- (IBAction)resendButtonPressed:(id)sender {
    NSDictionary* data = @{
                           @"mobile":[DataManager sharedManager].userPhoneNumber
                           };
    
    [self.confirmButton setLoading:YES];
    [[NetworkManager sharedManager] post:@"profile/sendCode" withData:data withAdditionalHeaders:nil withToken:nil  withSuccess:^(NSString *response, NSDictionary *json) {
        [self.confirmButton setLoading:NO];
        [DataManager sharedManager].lastSendCodeTime = [NSDate date];
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        [self.confirmButton setLoading:NO];
        [self showError:@"خطا در ارتباط با مرکز. لطفا از اتصال اینترنت مطمئن شوید و دوباره امتحان نمایید."];
    }];
}

@end

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

@interface PhoneVerificationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *verificationTextField;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@end

@implementation PhoneVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.verificationTextField.delegate=self;
    NSString* encodedPhone = [SibcheHelper changeNumberFormat:self.phone changeToPersian:YES];
    self.topLabel.text = [NSString stringWithFormat:@"کد تایید به شماره %@ ارسال شد.", encodedPhone];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)closeButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_CANCELED object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingChanged:(id)sender {
    self.verificationTextField.text = [SibcheHelper changeNumberFormat:self.verificationTextField.text changeToPersian:YES];
}

- (IBAction)confirmButtonPressed:(id)sender {
    [self.verificationTextField resignFirstResponder];
    NSString* verificationText = [SibcheHelper changeNumberFormat:self.verificationTextField.text changeToPersian:NO];
    if (verificationText.length < 4) {
        [self showError:@"فرمت کد تایید درست نمی‌باشد."];
        return;
    }
    
    NSDictionary* data = @{
                 @"mobile": self.phone,
                 @"code": verificationText
                 };
    
    [[NetworkManager sharedManager] post:@"profile/authenticate" withData:data withAdditionalHeaders:[SibcheHelper getHttpHeaders] withToken:nil withSuccess:^(NSString *response, NSDictionary *json){
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

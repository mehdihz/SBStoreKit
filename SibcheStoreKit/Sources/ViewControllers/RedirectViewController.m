//
//  RedirectViewController.m
//  SibcheStoreKit
//
//  Created by Mehdi on 3/09/20.
//  Copyright © 2020 Sibche. All rights reserved.
//

#import "RedirectViewController.h"
#import "SibcheStoreKit.h"
#import "Constants.h"
#import "DataManager.h"
#import "SibcheHelper.h"

@interface RedirectViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *redirectingLabel;
@property NSDate* viewShowingTime;

@property NSTimer* timer;

@end

@implementation RedirectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DataManager* manager = [DataManager sharedManager];
    NSString* userCellphone = [manager.profileData valueForKeyPath:@"data.attributes.mobile"];
    if (!userCellphone) {
        userCellphone = @"";
    }
    userCellphone = [SibcheHelper changeNumberFormat:userCellphone changeToPersian:YES];
    self.userDataLabel.text = [NSString stringWithFormat:@"شما با شماره تلفن %@ اقدام به خرید می‌کنید.\nدر صورتی که می‌خواهید با کاربر دیگری خرید انجام دهید، دکمه خروج از حساب کاربری را بزنید.", userCellphone];
    [self setTimeOfRedirection:REDIRECTION_TIME];
    
    self.viewShowingTime = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)setTimeOfRedirection:(NSInteger)remainingTime {
    NSString* text = [NSString stringWithFormat:@"پس از %ld ثانیه دیگر به صفحه پرداخت هدایت خواهید شد.", remainingTime];
    text = [SibcheHelper changeNumberFormat:text changeToPersian:YES];
    self.redirectingLabel.text = text;
}
                              
- (void)updateLabel{
  NSDate* now = [NSDate date];
  NSTimeInterval diff = [now timeIntervalSinceDate:self.viewShowingTime];
  if (diff > REDIRECTION_TIME) {
      // We should redirect
      dispatch_async(dispatch_get_main_queue(), ^{
          [self performSegueWithIdentifier:@"ShowPaymentSegue" sender:self];
      });
  }else{
      [self setTimeOfRedirection:REDIRECTION_TIME-lroundf(diff)];
  }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGE_REQUESTED object:nil];
    }];
}

@end

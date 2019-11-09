//
//  ViewController.m
//  SibcheDevApp
//
//  Created by Mehdi on 2/9/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "MainViewController.h"
#import <SibcheStoreKit/SibcheStoreKit.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (IBAction)fetchSpecificPurchaseItem:(id)sender {
    [SibcheStoreKit fetchInAppPurchasePackage:@"1" withPackagesCallback:^(BOOL isSuccessful, SibcheError* error, SibchePackage *package) {
        NSLog(@"Specific package has been loaded with status: %@ with package json data:%@", isSuccessful ? @"YES" : @"NO", [package toJson]);
    }];
}

- (IBAction)loginUser:(id)sender {
    [SibcheStoreKit loginUser:^(BOOL isLoginSuccessful, SibcheError* error, NSString *userName, NSString *userId) {
        NSLog(@"User Logged-in with status: %d", isLoginSuccessful);
    }];
}

- (IBAction)logoutUser:(id)sender{
    [SibcheStoreKit logoutUser:^{
        NSLog(@"User logged out");
    }];
}

- (IBAction)getCurrentUserData:(id)sender{
    [SibcheStoreKit getCurrentUserData:^(BOOL isSuccessful, SibcheError *error, LoginStatusType loginStatus, NSString *userCellphoneNumber, NSString *userId) {
        NSLog(@"Current user data: isLoggedIn: %@, userCellphone: %@, userId: %@", loginStatus == loginStatusTypeIsLoggedIn ? @"Logged In" : @"Logged out", userCellphoneNumber, userId);
    }];
}

@end

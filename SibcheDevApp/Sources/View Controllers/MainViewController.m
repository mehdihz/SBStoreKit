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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)fetchSpecificPurchaseItem:(id)sender {
    [SibcheStoreKit fetchInAppPurchasePackage:@"1" withPackagesCallback:^(BOOL isSuccessful, SibchePackage *package) {
        NSLog(@"Specific package has been loaded with status: %d", isSuccessful);
    }];
}

- (IBAction)loginUser:(id)sender {
    [SibcheStoreKit loginUser:^(BOOL isLoginSuccessful, NSString *userName, NSString *userId) {
        NSLog(@"User Logged-in with status: %d", isLoginSuccessful);
    }];
}

- (IBAction)logoutUser:(id)sender{
    [SibcheStoreKit logoutUser];
}

@end

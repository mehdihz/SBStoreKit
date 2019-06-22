//
//  ActivePackageViewController.m
//  SibcheDevApp
//
//  Created by Mehdi on 3/12/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "ActivePackageViewController.h"
#import <SibcheStoreKit/SibcheStoreKit.h>
#import "CustomTableViewCell.h"

@interface ActivePackageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *packagesTable;
@property NSArray* purchasesArray;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end

@implementation ActivePackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPurchasablePackages];
    self.packagesTable.dataSource = self;
    self.packagesTable.delegate = self;
}

- (void)fetchPurchasablePackages{
    [self setLoading:YES withMessage:@"Loading..."];

    [SibcheStoreKit fetchActiveInAppPurchasePackages:^(BOOL isSuccessful, NSArray *purchasePackagesArray) {
        if (isSuccessful) {
            self.purchasesArray = purchasePackagesArray;
            [self setLoading:NO withMessage:@""];
        }else{
            [self setLoading:NO withMessage:@"There was an error on package list fetching!"];
        }
    }];
}

- (void)setLoading:(BOOL)isLoading withMessage:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isLoading || message.length > 0) {
            self.loadingView.hidden = NO;
            if (isLoading) {
                [self.loadingIndicator startAnimating];
            }else{
                [self.loadingIndicator stopAnimating];
            }
            self.loadingLabel.text = message;
        }else{
            self.loadingView.hidden = YES;
            [self.packagesTable reloadData];
        }
    });
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row >= self.purchasesArray.count) {
        return [UITableViewCell new];
    }

    CustomTableViewCell* cell = [self.packagesTable dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    SibchePurchasePackage* purchaseData = [self.purchasesArray objectAtIndex:indexPath.row];
    if (purchaseData) {
        [cell.packageActionButton setTitle:@"Consume" forState:UIControlStateNormal];

        if ([purchaseData.package isKindOfClass:[SibcheConsumablePackage class]]) {
            [cell.packageActionButton setEnabled:YES];
        }else{
            [cell.packageActionButton setEnabled:NO];
        }

        cell.packageName.text = purchaseData.package.name;
        cell.packageDescription.text = purchaseData.package.packageDescription;
        cell.packagePrice.text = [purchaseData.package.price stringValue];

        cell.packageActionButton.tag = indexPath.row;
        [cell.packageActionButton addTarget:self action:@selector(consumeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)consumeTapped:(UIButton*)sender{
    if (sender.tag >= self.purchasesArray.count) {
        return;
    }
    
    SibchePurchasePackage* purchasePackageData = [self.purchasesArray objectAtIndex:sender.tag];

    [SibcheStoreKit consumePurchasePackage:purchasePackageData.purchasePackageId withCallback:^(BOOL isSuccessful) {
        NSLog(@"Consume response is: %d", isSuccessful);
    }];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.purchasesArray && self.purchasesArray.count > 0) {
        return self.purchasesArray.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

@end

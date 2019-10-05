//
//  PayablePackageViewController.m
//  SibcheDevApp
//
//  Created by Mehdi on 3/12/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "PayablePackageViewController.h"
#import <SibcheStoreKit/SibcheStoreKit.h>
#import "CustomTableViewCell.h"

@interface PayablePackageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *packagesTable;
@property NSArray* packagesArray;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end

@implementation PayablePackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPurchasablePackages];
    self.packagesTable.dataSource = self;
    self.packagesTable.delegate = self;
}

- (void)fetchPurchasablePackages{
    [self setLoading:YES withMessage:@"Loading..."];
    
    [SibcheStoreKit fetchInAppPurchasePackages:^(BOOL isSuccessful, SibcheError* error, NSArray *packagesArray) {
        if (isSuccessful) {
            if (packagesArray && [packagesArray isKindOfClass:[NSArray class]] && packagesArray.count > 0) {
                self.packagesArray = packagesArray;
            }
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
    if (indexPath.row >= self.packagesArray.count) {
        return [UITableViewCell new];
    }

    CustomTableViewCell* cell = [self.packagesTable dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    SibchePackage* packageData = [self.packagesArray objectAtIndex:indexPath.row];
    if (packageData) {
        cell.packageName.text = packageData.name;
        cell.packageDescription.text = packageData.packageDescription;
        cell.packagePrice.text = [packageData.totalPrice stringValue];
        [cell.packageActionButton setTitle:@"Purchase" forState:UIControlStateNormal];
        cell.packageActionButton.tag = indexPath.row;
        [cell.packageActionButton addTarget:self action:@selector(purchaseTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)purchaseTapped:(UIButton*)sender{
    if (sender.tag >= self.packagesArray.count) {
        return;
    }
    
    SibchePackage* packageData = [self.packagesArray objectAtIndex:sender.tag];

    // You can use both packageData.code & packageData.packageId
    // We support both of package bundle code and packageId
    [SibcheStoreKit purchasePackage:packageData.code withCallback:^(BOOL isSuccessful, SibcheError* error, SibchePurchasePackage* package) {
        NSLog(@"Just testing purchase for %@ with Response: %d", packageData.packageId, isSuccessful);
    }];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.packagesArray && self.packagesArray.count > 0) {
        return self.packagesArray.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

@end

//
//  SibchePackageFactory.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/14/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibchePackageFactory.h"
#import "SibcheConsumablePackage.h"
#import "SibcheNonConsumablePackage.h"
#import "SibcheSubscriptionPackage.h"

@implementation SibchePackageFactory

+ (id)getPackageWithData:(NSDictionary*)data{
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSString* packageType = [data valueForKeyPath:@"type"];
        if ([packageType isEqualToString:@"ConsumableInAppPackage"]) {
            return [[SibcheConsumablePackage alloc] initWithData:data];
        } else if ([packageType isEqualToString:@"NonConsumableInAppPackage"]) {
            return [[SibcheNonConsumablePackage alloc] initWithData:data];
        } else if ([packageType isEqualToString:@"SubscriptionInAppPackage"]) {
            return [[SibcheSubscriptionPackage alloc] initWithData:data];
        }
    }
    
    return nil;
}

@end

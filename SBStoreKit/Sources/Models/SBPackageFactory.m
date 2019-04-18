//
//  SBPackageFactory.m
//  SBStoreKit
//
//  Created by Mehdi on 4/14/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SBPackageFactory.h"
#import "SBConsumablePackage.h"
#import "SBNonConsumablePackage.h"
#import "SBSubscriptionPackage.h"

@implementation SBPackageFactory

+ (id)getPackageWithData:(NSDictionary*)data{
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSString* packageType = [data valueForKeyPath:@"type"];
        if ([packageType isEqualToString:@"ConsumableInAppPackage"]) {
            return [[SBConsumablePackage alloc] initWithData:data];
        } else if ([packageType isEqualToString:@"NonConsumableInAppPackage"]) {
            return [[SBNonConsumablePackage alloc] initWithData:data];
        } else if ([packageType isEqualToString:@"SubscriptionInAppPackage"]) {
            return [[SBSubscriptionPackage alloc] initWithData:data];
        }
    }
    
    return nil;
}

@end

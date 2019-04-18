//
//  SBPackage.m
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SBPackage.h"
#import "SBPackage-priv.h"

@implementation SBPackage

- (instancetype)initWithData:(NSDictionary*)data{
    if (self = [super init]) {
        _packageId = [data valueForKeyPath:@"id"];
        _packageType = [data valueForKeyPath:@"type"];
        _packageName = [data valueForKeyPath:@"attributes.name"];
        _packageDescription = [data valueForKeyPath:@"attributes.description"];
        _packageCode = [data valueForKeyPath:@"attributes.code"];
        _packageTotalPrice = [data valueForKeyPath:@"attributes.total_price"];
        _packagePrice = [data valueForKeyPath:@"attributes.price"];
        _packageDiscount = [data valueForKeyPath:@"attributes.discount"];
    }
    
    return self;
}

@end

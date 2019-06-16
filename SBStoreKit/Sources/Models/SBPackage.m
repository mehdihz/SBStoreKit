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
        _type = [data valueForKeyPath:@"type"];
        _name = [data valueForKeyPath:@"attributes.name"];
        _packageDescription = [data valueForKeyPath:@"attributes.description"];
        _code = [data valueForKeyPath:@"attributes.code"];
        _totalPrice = [data valueForKeyPath:@"attributes.total_price"];
        _price = [data valueForKeyPath:@"attributes.price"];
        _discount = [data valueForKeyPath:@"attributes.discount"];
    }
    
    return self;
}

@end

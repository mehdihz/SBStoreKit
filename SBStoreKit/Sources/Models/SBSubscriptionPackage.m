//
//  SBSubscriptionPackage.m
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SBSubscriptionPackage.h"

@interface SBSubscriptionPackage()

@property NSString* duration;
@property NSString* group;

@end

@implementation SBSubscriptionPackage

- (instancetype)initWithData:(NSDictionary*)data{
    if (self = [super initWithData:data]) {
//        _packageName = [data valueForKeyPath:@"attributes.duration"];
//        _packageDescription = [data valueForKeyPath:@"attributes.group"];
    }
    
    return self;
}

@end

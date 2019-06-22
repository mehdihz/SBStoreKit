//
//  SibcheSubscriptionPackage.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibcheSubscriptionPackage.h"

@interface SibcheSubscriptionPackage()

@property NSString* duration;
@property NSString* group;

@end

@implementation SibcheSubscriptionPackage

- (instancetype)initWithData:(NSDictionary*)data{
    if (self = [super initWithData:data]) {
//        _packageName = [data valueForKeyPath:@"attributes.duration"];
//        _packageDescription = [data valueForKeyPath:@"attributes.group"];
    }
    
    return self;
}

@end

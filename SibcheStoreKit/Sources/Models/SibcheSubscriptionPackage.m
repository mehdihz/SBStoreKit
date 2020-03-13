//
//  SibcheSubscriptionPackage.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibcheSubscriptionPackage.h"

@interface SibcheSubscriptionPackage()

@property NSNumber* duration;
@property NSString* group;

@end

@implementation SibcheSubscriptionPackage

- (instancetype)initWithData:(NSDictionary*)data{
    if (self = [super initWithData:data]) {
        _duration = [data valueForKeyPath:@"attributes.duration"];
        if ([_duration isKindOfClass:[NSString class]]) {
            NSString* stringValue = [data valueForKeyPath:@"attributes.duration"];
            NSInteger duration = [stringValue integerValue];
            _duration = [NSNumber numberWithUnsignedInteger:duration];
        }
        _group = [data valueForKeyPath:@"attributes.group"];
    }
    
    return self;
}

- (NSString *)toJson {
    return [super toJson];
}

- (NSDictionary*)toDictionary {
    return [super toDictionary];
}

@end

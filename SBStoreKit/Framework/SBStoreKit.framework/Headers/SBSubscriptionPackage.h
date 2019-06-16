//
//  SBSubscriptionPackage.h
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBPackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBSubscriptionPackage : SBPackage

- (NSString*)duration;
- (NSString*)group;

- (instancetype)initWithData:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END

//
//  SBPackage.h
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBPackage : NSObject

- (NSString*)packageId;
- (NSString*)packageType;
- (NSString*)packageCode;
- (NSString*)packageName;
- (NSString*)packageDescription;
- (NSNumber*)packagePrice;
- (NSNumber*)packageTotalPrice;
- (NSNumber*)packageDiscount;

- (instancetype)initWithData:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END

//
//  SBPurchasePackage.h
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBPackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBPurchasePackage : NSObject

- (NSString*)purchasePackageId;
- (NSString*)type;
- (NSString*)code;
- (NSDate*)expireAt;
- (NSDate*)createdAt;
- (SBPackage*)package;

- (instancetype)initWithData:(NSDictionary *)data withPackage:(NSDictionary*)package;

+ (NSArray*)parsePurchasePackagesList:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END

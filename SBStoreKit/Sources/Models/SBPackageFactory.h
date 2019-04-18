//
//  SBPackageFactory.h
//  SBStoreKit
//
//  Created by Mehdi on 4/14/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBPackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SBPackageFactory : NSObject

+ (id)getPackageWithData:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END

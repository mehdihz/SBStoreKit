//
//  SibchePackageFactory.h
//  SibcheStoreKit
//
//  Created by Mehdi on 4/14/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SibchePackage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SibchePackageFactory : NSObject

+ (id)getPackageWithData:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END

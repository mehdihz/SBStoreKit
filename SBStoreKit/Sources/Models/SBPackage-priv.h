//
//  SBPackage-priv.h
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#ifndef SBPackage_priv_h
#define SBPackage_priv_h

@interface SBPackage()

@property NSString* packageId;
@property NSString* packageType;
@property NSString* packageCode;
@property NSString* packageName;
@property NSString* packageDescription;
@property NSNumber* packagePrice;
@property NSNumber* packageTotalPrice;
@property NSNumber* packageDiscount;

@end


#endif /* SBPackage_priv_h */

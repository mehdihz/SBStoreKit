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
@property NSString* type;
@property NSString* code;
@property NSString* name;
@property NSString* packageDescription;
@property NSNumber* price;
@property NSNumber* totalPrice;
@property NSNumber* discount;

@end


#endif /* SBPackage_priv_h */

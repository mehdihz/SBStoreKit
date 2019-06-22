//
//  SibchePackage-priv.h
//  SibcheStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#ifndef SibchePackage_priv_h
#define SibchePackage_priv_h

@interface SibchePackage()

@property NSString* packageId;
@property NSString* type;
@property NSString* code;
@property NSString* name;
@property NSString* packageDescription;
@property NSNumber* price;
@property NSNumber* totalPrice;
@property NSNumber* discount;

@end


#endif /* SibchePackage_priv_h */

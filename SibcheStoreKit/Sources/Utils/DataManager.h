//
//  DataManager.h
//  SibcheStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property NSString* purchasingPackageId;
@property NSDictionary* profileData;
@property NSDictionary* showingInvoiceData;
@property int balanceToAdd;

@property NSString* appId;
@property NSString* appScheme;

@property NSDate* lastSendCodeTime;
@property NSString* userPhoneNumber;

+ (DataManager *)sharedManager;

@end

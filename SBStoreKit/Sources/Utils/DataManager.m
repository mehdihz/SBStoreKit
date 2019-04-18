//
//  DataManager.m
//  SBStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

+ (DataManager *)sharedManager {
    static DataManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [DataManager new];
    });
    return sharedManager;
}

@end

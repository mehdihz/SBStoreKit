//
//  SBPurchasePackage.m
//  SBStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SBPurchasePackage.h"
#import "SBPackageFactory.h"

@interface SBPurchasePackage()

@property NSString* purchasePackageId;
@property NSString* type;
@property NSString* code;
@property NSDate* expireAt;
@property NSDate* createdAt;
@property SBPackage* package;

@end

@implementation SBPurchasePackage

- (instancetype)initWithData:(NSDictionary *)data withPackage:(SBPackage*)package{
    if (self = [super init]) {
        _purchasePackageId = [data valueForKeyPath:@"id"];
        _type = [data valueForKeyPath:@"type"];
        _code = [data valueForKeyPath:@"attributes.code"];
        _package = package;
        
        NSDictionary* expireAt = [data valueForKeyPath:@"attributes.expire_at"];
        NSDictionary* createdAt = [data valueForKeyPath:@"attributes.created_at"];
        
        if (expireAt && [expireAt isKindOfClass:[NSDictionary class]]) {
            NSString* expireAtString = [expireAt valueForKeyPath:@"date"];
            if (expireAtString && [expireAtString isKindOfClass:[NSString class]]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                _expireAt = [dateFormatter dateFromString:expireAtString];
            }
        }

        if (createdAt && [createdAt isKindOfClass:[NSDictionary class]]) {
            NSString* createdAtString = [createdAt valueForKeyPath:@"date"];
            if (createdAtString && [createdAtString isKindOfClass:[NSString class]]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
                _createdAt = [dateFormatter dateFromString:createdAtString];
            }
        }
    }
    
    return self;
}

+ (NSArray*)parsePurchasePackagesList:(NSDictionary*)data{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    NSArray* purchaseArray = [data valueForKeyPath:@"data"];
    if (purchaseArray && [purchaseArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary* purchase in purchaseArray) {
            if (purchase && [purchase isKindOfClass:[NSDictionary class]]) {
                NSString* packageId = [purchase valueForKeyPath:@"relationships.inAppPurchasePackage.data.id"];
                NSDictionary* packageData = [self fetchIncludedPackageId:packageId fromData:data];
                SBPackage* package = [SBPackageFactory getPackageWithData:packageData];
                SBPurchasePackage* purchasePackage = [[self alloc] initWithData:purchase withPackage:package];
                [returnArray addObject:purchasePackage];
            }
        }
    }
    
    return returnArray;
}

+ (NSDictionary*)fetchIncludedPackageId:(NSString*)packageId fromData:(NSDictionary*)data{
    NSArray* includedData = [data valueForKeyPath:@"included"];

    if (includedData && includedData.count > 0 && packageId && packageId.length > 0) {
        for (int i = 0; i < includedData.count; i++) {
            NSDictionary* data = [includedData objectAtIndex:i];
            NSString* includedPackageId = [data valueForKeyPath:@"id"];
            if (includedPackageId && [includedPackageId isEqualToString:packageId]) {
                return data;
            }
        }
    }
    
    return nil;
}

@end

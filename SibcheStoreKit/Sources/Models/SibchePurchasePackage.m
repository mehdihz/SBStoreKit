//
//  SibchePurchasePackage.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibchePurchasePackage.h"
#import "SibchePackageFactory.h"
#import "SibcheHelper.h"

@interface SibchePurchasePackage()

@property NSString* purchasePackageId;
@property NSString* type;
@property NSString* code;
@property NSDate* expireAt;
@property NSDate* createdAt;
@property SibchePackage* package;

@end

@implementation SibchePurchasePackage

- (instancetype)initWithData:(NSDictionary *)data withPackage:(SibchePackage*)package{
    if (self = [super init]) {
        _purchasePackageId = [data valueForKeyPath:@"id"];
        _type = [data valueForKeyPath:@"type"];
        _code = [data valueForKeyPath:@"attributes.code"];
        _package = package;
        
        NSObject* expireAt = [data valueForKeyPath:@"attributes.expire_at"];
        NSObject* createdAt = [data valueForKeyPath:@"attributes.created_at"];
        
        _expireAt = [SibcheHelper convertDate:expireAt];
        _createdAt = [SibcheHelper convertDate:createdAt];
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
                SibchePackage* package = [SibchePackageFactory getPackageWithData:packageData];
                SibchePurchasePackage* purchasePackage = [[self alloc] initWithData:purchase withPackage:package];
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

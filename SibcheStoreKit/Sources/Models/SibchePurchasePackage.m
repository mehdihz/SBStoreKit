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

- (NSDictionary*)toDictionary{
    return @{
    @"purchasePackageId": _purchasePackageId,
    @"type": _type,
    @"code": _code,
    @"package": [_package toJson],
    @"expireAt": _expireAt ? [NSNumber numberWithDouble:[_expireAt timeIntervalSince1970]] : @0,
    @"createdAt": _createdAt ? [NSNumber numberWithDouble:[_createdAt timeIntervalSince1970]] : @0,
    };
}

- (NSString *)toJson {
    NSMutableDictionary* dict =
    [[NSMutableDictionary alloc] initWithDictionary:[self toDictionary]];
    
    for (id key in dict) {
        if (!key || ![dict objectForKey:key]) {
            [dict removeObjectForKey:key];
        }
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error
                        ];
    
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"";
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}


+ (NSArray*)parsePurchasePackagesList:(NSDictionary*)data{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    NSArray* purchaseArray = [data valueForKeyPath:@"data"];
    if (purchaseArray && [purchaseArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary* purchase in purchaseArray) {
            if (purchase && [purchase isKindOfClass:[NSDictionary class]]) {
                NSString* packageId = [purchase valueForKeyPath:@"relationships.inAppPurchasePackage.data.id"];
                NSString* packageType = [purchase valueForKeyPath:@"relationships.inAppPurchasePackage.data.type"];
                NSDictionary* packageData = [SibcheHelper fetchIncludedObject:packageId withType:packageType fromData:data];
                SibchePackage* package = [SibchePackageFactory getPackageWithData:packageData];
                SibchePurchasePackage* purchasePackage = [[self alloc] initWithData:purchase withPackage:package];
                [returnArray addObject:purchasePackage];
            }
        }
    }
    
    return returnArray;
}

@end

//
//  SibchePackage.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibchePackage.h"
#import "SibchePackage-priv.h"

@implementation SibchePackage

- (instancetype)initWithData:(NSDictionary*)data{
    if (self = [super init]) {
        _packageId = [data valueForKeyPath:@"id"];
        _type = [data valueForKeyPath:@"type"];
        _name = [data valueForKeyPath:@"attributes.name"];
        _packageDescription = [data valueForKeyPath:@"attributes.description"];
        _code = [data valueForKeyPath:@"attributes.code"];
        _totalPrice = [data valueForKeyPath:@"attributes.total_price"];
        _price = [data valueForKeyPath:@"attributes.price"];
        _discount = [data valueForKeyPath:@"attributes.discount"];
    }
    
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary* dict =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      @"packageId": _packageId,
                                                      @"type": _type,
                                                      @"name": _name,
                                                      @"packageDescription": _packageDescription,
                                                      @"code": _code,
                                                      @"totalPrice": _totalPrice,
                                                      @"price": _price,
                                                      @"discount": _discount,
                                                      }];
    if ([self respondsToSelector:NSSelectorFromString(@"duration")]) {
        NSNumber* duration = [self performSelector:NSSelectorFromString(@"duration")];
        if (duration && [duration isKindOfClass:[NSNumber class]]) {
            [dict setObject:[duration stringValue] forKey:@"duration"];
        }
    }
    if ([self respondsToSelector:NSSelectorFromString(@"group")]) {
        NSString* group = [self performSelector:NSSelectorFromString(@"group")];
        if (group && [group isKindOfClass:[NSString class]]) {
            [dict setObject:group forKey:@"group"];
        }
    }
    return dict;
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

@end

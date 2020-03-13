//
//  SibcheError.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/13/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibcheError.h"
#import "SibcheHelper.h"

@implementation SibcheError

- (instancetype)initWithData:(NSString*)jsonStr withHttpStatusCode:(NSInteger)httpStatusCode {
    if (self = [super init]) {
        if (jsonStr && jsonStr.length > 0) {
            NSDictionary* json = [SibcheHelper getJsonObjectFromString:jsonStr];
            
            int errorCodeInt = [[json valueForKeyPath:@"error_code"] intValue];
            _errorCode = [NSNumber numberWithInt:errorCodeInt];
            _message = [json valueForKeyPath:@"message"];
            _statusCode = [json valueForKeyPath:@"status_code"];
        } else {
            _errorCode = @-1;
            _message = @"";
            _statusCode = [NSNumber numberWithInteger:httpStatusCode];
        }
    }
    
    return self;
}

- (instancetype)initWithErrorCode:(SibcheErrorType)errorCode {
    if (self = [super init]) {
        _errorCode = [NSNumber numberWithInteger:errorCode];
        _message = @"";
        _statusCode = @200;
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _errorCode = [NSNumber numberWithInteger:unknownError];
        _message = @"";
        _statusCode = @400;
    }
    
    return self;
}

- (NSDictionary*)toDictionary {
    return @{
    @"errorCode": _errorCode,
    @"message": _message,
    @"statusCode": _statusCode,
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

@end

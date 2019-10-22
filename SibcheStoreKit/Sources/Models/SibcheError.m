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
            
            _errorCode = [[json valueForKeyPath:@"error_code"] intValue];
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

@end

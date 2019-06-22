//
//  NetworkManager.h
//  SibcheStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessAction)(NSString* response, NSDictionary* json);
typedef void (^FailureAction)(NSInteger errorCode, NSInteger httpStatusCode);

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedManager;
- (void)get:(NSString*)url withAdditionalHeaders:(nullable NSDictionary*)headers withToken:(nullable NSString*)token withSuccess:(SuccessAction)successAction withFailure:(FailureAction)failureAction;
- (void)post:(NSString*)url withData:(NSDictionary*)data withAdditionalHeaders:(nullable NSDictionary*)headers withToken:(nullable NSString*)token withSuccess:(SuccessAction)successAction withFailure:(FailureAction)failureAction;

@end

//
//  NetworkManager.h
//  SibcheStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessAction)(NSString* _Nullable response, NSDictionary* _Nullable json);
typedef void (^FailureAction)(NSInteger errorCode, NSInteger httpStatusCode, NSString* _Nullable response);

@interface NetworkManager : NSObject

+ (nonnull NetworkManager*)sharedManager;
- (void)get:(nonnull NSString*)url withAdditionalHeaders:(nullable NSDictionary*)headers withToken:(nullable NSString*)token withSuccess:(nonnull SuccessAction)successAction withFailure:(nonnull FailureAction)failureAction;
- (void)post:(nonnull NSString*)url withData:(nullable NSDictionary*)data withAdditionalHeaders:(nullable NSDictionary*)headers withToken:(nullable NSString*)token withSuccess:(nonnull SuccessAction)successAction withFailure:(nonnull FailureAction)failureAction;

@end

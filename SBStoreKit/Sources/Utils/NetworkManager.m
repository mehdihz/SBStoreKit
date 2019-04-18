//
//  NetworkManager.m
//  SBStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "NetworkManager.h"
#import "SibcheHelper.h"

@interface NetworkManager ()
@property (strong, nonatomic) NSURLSession *sharedSession;
@end


@implementation NetworkManager

+ (NetworkManager *)sharedManager {
    static NetworkManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [NetworkManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _sharedSession = [NSURLSession sessionWithConfiguration:[self configurationWithCachingPolicy:NSURLRequestUseProtocolCachePolicy]];
    }
    
    return self;
}

- (NSURLSessionConfiguration *)configurationWithCachingPolicy:(NSURLRequestCachePolicy)policy {
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 60;
    configuration.timeoutIntervalForResource = 60;
    
    configuration.requestCachePolicy = policy;
    
    return configuration;
}

- (void)get:(NSString*)url withAdditionalHeaders:(nullable NSDictionary*)headers withToken:(nullable NSString*)token withSuccess:(SuccessAction)successAction withFailure:(FailureAction)failureAction{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[SibcheHelper getServerUrl:url]];
    [urlRequest setHTTPMethod:@"GET"];
    NSMutableDictionary* mainHeaders = [[NSMutableDictionary alloc] initWithDictionary:[SibcheHelper getHttpHeaders]];
    if (headers) {
        [mainHeaders addEntriesFromDictionary:headers];
    }
    if (token) {
        [mainHeaders addEntriesFromDictionary:@{
                                                @"Authorization": [NSString stringWithFormat:@"Bearer %@", token]
                                                }];
    }
    urlRequest.allHTTPHeaderFields = mainHeaders;

    NSURLSessionDataTask *dataTask = [self.sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode >= 200 && httpResponse.statusCode <= 202)
        {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSString* responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            successAction(responseStr, responseDictionary);
        }
        else
        {
            failureAction(error.code, httpResponse.statusCode);
        }
    }];
    [dataTask resume];
}

- (void)post:(NSString*)url withData:(NSDictionary*)data withAdditionalHeaders:(nullable NSDictionary*)headers withToken:(nullable NSString*)token withSuccess:(SuccessAction)successAction withFailure:(FailureAction)failureAction{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[SibcheHelper getServerUrl:url]];
    [urlRequest setHTTPMethod:@"POST"];
    NSMutableDictionary* mainHeaders = [[NSMutableDictionary alloc] initWithDictionary:[SibcheHelper getHttpHeaders]];
    if (headers) {
        [mainHeaders addEntriesFromDictionary:headers];
    }
    if (token) {
        [mainHeaders addEntriesFromDictionary:@{
                                                @"Authorization": [NSString stringWithFormat:@"Bearer %@", token]
                                                }];
    }
    urlRequest.allHTTPHeaderFields = mainHeaders;
    
    NSString *params = [self makeParamtersString:data withEncoding:NSUTF8StringEncoding];
    NSData *body = [params dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:body];

    NSURLSessionDataTask *dataTask = [self.sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          if(httpResponse.statusCode >= 200 && httpResponse.statusCode <= 202)
                                          {
                                              NSError *parseError = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                              NSString* responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                              successAction(responseStr, responseDictionary);
                                          }
                                          else
                                          {
                                              failureAction(error.code, httpResponse.statusCode);
                                          }
                                      }];
    [dataTask resume];
}

- (NSString*)makeParamtersString:(NSDictionary*)parameters withEncoding:(NSStringEncoding)encoding
{
    if (nil == parameters || [parameters count] == 0)
        return nil;
    
    NSMutableString* stringOfParamters = [[NSMutableString alloc] init];
    NSEnumerator *keyEnumerator = [parameters keyEnumerator];
    id key = nil;
    while ((key = [keyEnumerator nextObject]))
    {
        NSString *value = [[parameters valueForKey:key] isKindOfClass:[NSString class]] ?
        [parameters valueForKey:key] : [[parameters valueForKey:key] stringValue];
        [stringOfParamters appendFormat:@"%@=%@&",
         [self urlencode:key],
         [self urlencode:value]];
    }
    
    // Delete last character of '&'
    NSRange lastCharRange = {[stringOfParamters length] - 1, 1};
    [stringOfParamters deleteCharactersInRange:lastCharRange];
    return stringOfParamters;
}

- (NSString *)urlencode:(NSString*)toEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[toEncode UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

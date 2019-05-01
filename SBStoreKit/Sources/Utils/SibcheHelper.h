//
//  SibcheHelper.h
//  SBStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface SibcheHelper : NSObject

+ (BOOL)isValidPhone:(NSString*) phoneNumber;
+ (NSString*)numberizeText:(NSString*) input;
+ (int)phoneNumberLength;
+ (NSString*)changeNumberFormat:(NSString*)inputStr changeToPersian:(BOOL)changeToPersian;
+ (NSDictionary*)getHttpHeaders;
+ (NSURL*)getServerUrl:(NSString*)suburl;
+ (NSString*)formatNumber:(NSNumber*)number;
+ (long)extractNumberFromString:(NSString *)string;

+ (void)setToken:(NSString*)token;
+ (NSString*)getToken;
+ (void)deleteToken;

+ (UIViewController*) topMostController;

@end

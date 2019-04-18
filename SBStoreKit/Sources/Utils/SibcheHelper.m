//
//  SibcheHelper.m
//  SBStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibcheHelper.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import "SBStoreKit.h"
#import "SBKeychain.h"
#import "DataManager.h"

@import AdSupport;

@implementation SibcheHelper

+ (BOOL)isValidPhone:(NSString*) phoneNumber{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([phoneNumber rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        if (phoneNumber.length == [self phoneNumberLength] && [[phoneNumber substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"09"]) {
            return YES;
        }
    }
    
    return NO;
}

+ (int)phoneNumberLength{
    return 11;
}

+ (NSString*)changeNumberFormat:(NSString*)inputStr changeToPersian:(BOOL)changeToPersian{
    NSDictionary* encodeDictionary = @{
        @"0": @"۰",
        @"1": @"۱",
        @"2": @"۲",
        @"3": @"۳",
        @"4": @"۴",
        @"5": @"۵",
        @"6": @"۶",
        @"7": @"۷",
        @"8": @"۸",
        @"9": @"۹",
    };
    
    NSString* str = inputStr;
    for (int i = 0; i < encodeDictionary.count; i++) {
        NSString* from = changeToPersian? [[encodeDictionary allKeys] objectAtIndex:i] : [[encodeDictionary allValues] objectAtIndex:i];
        NSString* to = changeToPersian? [[encodeDictionary allValues] objectAtIndex:i] : [[encodeDictionary allKeys] objectAtIndex:i];
        str = [str stringByReplacingOccurrencesOfString:from withString:to];
    }
    
    return str;
}

+ (NSDictionary *)getHttpHeaders{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"App-Version": [self getAppVersion],
        @"Device-Name": [self getDeviceName],
        @"Device-Type": [self getDeviceType],
        @"OS": [self getOSName],
        @"OS-Version": [self getOSVersion],
        @"Store": [self getStore],
        @"Uuid": [self getUuid],
        @"App-Key": [DataManager sharedManager].appId
    }];
    
    return dictionary;
}

+ (NSString*)getAppVersion{
    NSBundle* bundle = [NSBundle bundleForClass:[SBStoreKit class]];
    NSString *version = [[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString*)getDeviceName{
    return [[UIDevice currentDevice] name];
}

+ (NSString*)getDeviceType{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString*)getOSName{
    return @"iOS";
}

+ (NSString*)getOSVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*)getStore{
    return @"Sdk";
}

+ (NSString*)getUuid{
    NSString *id = @"";
    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSUUID *identifier = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        id = [identifier UUIDString];
    } else {
        NSUUID *deviceId = [UIDevice currentDevice].identifierForVendor;
        id = [deviceId UUIDString];
    }
    
    return id;
}

+ (NSString*)getServerBaseAddress{
    return @"https://api.sibche.com/";
}

+ (NSURL*)getServerUrl:(NSString*)suburl{
    NSString* url = [NSString stringWithFormat:@"%@%@", [self getServerBaseAddress], suburl];
    return [NSURL URLWithString:url];
}

+ (NSString*)getKeychainService{
    return @"tk";
}

+ (NSString*)getKeychainAccount{
    return @"com.sibche.sdk";
}

+ (void)setToken:(NSString*)key{
    [SBKeychain setPassword:key forService:[self getKeychainService] account:[self getKeychainAccount]];
}

+ (NSString*)getToken{
    return [SBKeychain passwordForService:[self getKeychainService] account:[self getKeychainAccount]];
}

+ (void)deleteToken{
    [SBKeychain deletePasswordForService:[self getKeychainService] account:[self getKeychainAccount]];
}

+ (NSString*)formatNumber:(NSNumber*)number{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *formatted = [formatter stringFromNumber:number];
    return [self convertEnglishNumbersToPersian:formatted];
}

+ (NSString *)convertEnglishNumbersToPersian:(NSString *)inputString {
    NSArray         *persianDigits = @[@"۰", @"۱", @"۲", @"۳", @"۴", @"۵", @"۶", @"۷", @"۸", @"۹"];
    NSMutableString *result        = [[NSMutableString alloc] init];
    NSArray         *digits        = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    
    [inputString enumerateSubstringsInRange:NSMakeRange(0, inputString.length)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if ([persianDigits containsObject:substring]) {
                                         [result appendString:substring];
                                     } else if ([substring isEqualToString:@"."]) {
                                         [result appendString:@"٫"];
                                     } else if ([substring isEqualToString:@","]) {
                                         [result appendString:@","];
                                     } else if ([substring isEqualToString:@"-"]) {
                                         [result appendString:@"-"];
                                     } else if ([substring isEqualToString:@"٫"]) {
                                         [result appendString:@"٫"];
                                     } else if ([digits containsObject:substring]) {
                                         [result appendString:persianDigits[[substring intValue]]];
                                     } else {
                                         [result appendString:substring];
                                     }
                                 }];
    return result;
}

+ (NSString *)convertPersianNumbersToEnglish:(NSString *)inputString {
    NSArray         *englishDigits = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    NSMutableString *result        = [[NSMutableString alloc] init];
    NSArray         *digits        = @[@"۰", @"۱", @"۲", @"۳", @"۴", @"۵", @"۶", @"۷", @"۸", @"۹"];
    
    [inputString enumerateSubstringsInRange:NSMakeRange(0, inputString.length)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if ([englishDigits containsObject:substring]) {
                                         [result appendString:substring];
                                     } else if ([substring isEqualToString:@"٫"]) {
                                         [result appendString:@"."];
                                     } else if ([substring isEqualToString:@","]) {
                                         [result appendString:@","];
                                     } else if ([substring isEqualToString:@"-"]) {
                                         [result appendString:@"-"];
                                     } else if ([substring isEqualToString:@"٫"]) {
                                         [result appendString:@"٫"];
                                     } else if ([digits containsObject:substring]) {
                                         [result appendString:englishDigits[[substring intValue]]];
                                     } else {
                                         [result appendString:substring];
                                     }
                                 }];
    return result;
}

+ (long)extractNumberFromString:(NSString *)string{
    NSString* englishText = [self convertPersianNumbersToEnglish:string];
    
    NSMutableString* result = [[NSMutableString alloc] init];
    NSArray* numberDigits = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];

    [englishText enumerateSubstringsInRange:NSMakeRange(0, englishText.length)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if ([numberDigits containsObject:substring]) {
                                         [result appendString:substring];
                                     }
                                 }];
    return [result longLongValue];
}

@end

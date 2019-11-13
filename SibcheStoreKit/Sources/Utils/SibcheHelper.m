//
//  SibcheHelper.m
//  SibcheStoreKit
//
//  Created by Mehdi on 2/20/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "SibcheHelper.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import "SibcheStoreKit.h"
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

+ (NSString*)numberizeText:(NSString*) input{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString* numberizedInput = input;
    while ([numberizedInput rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
        NSRange characterRange = [numberizedInput rangeOfCharacterFromSet:notDigits];
        numberizedInput = [numberizedInput stringByReplacingCharactersInRange:characterRange withString:@""];
    }
    
    return numberizedInput;
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
    NSBundle* bundle = [NSBundle bundleForClass:[SibcheStoreKit class]];
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

+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navController = (UINavigationController*)topController;
        topController = navController.visibleViewController;
    }
    
    return topController;
}

+ (void)setIconPropertiesForImageView:(UIImageView*)imageView {
    NSBundle* bundle = [NSBundle bundleForClass:[SibcheHelper class]];
    [imageView setImage:[UIImage imageNamed:@"SibcheLogo" inBundle:bundle compatibleWithTraitCollection:nil]];
    imageView.layer.cornerRadius = imageView.frame.size.height * 0.15625;
    imageView.clipsToBounds = YES;
}

+ (NSDate*)convertDate:(NSObject*)date{
    NSString* dateStr = @"";
    if (!date) {
        return nil;
    }
    
    if ([date isKindOfClass:[NSDictionary class]]) {
        dateStr = [date valueForKeyPath:@"date"];
    }else if ([date isKindOfClass:[NSString class]]){
        dateStr = (NSString*) date;
    }

    if (dateStr && [dateStr isKindOfClass:[NSString class]] && dateStr.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        if ([dateStr rangeOfString:@"."].location != NSNotFound) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        }else{
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        NSDate* convertedDate = [dateFormatter dateFromString:dateStr];
        return convertedDate;
    }
    
    return nil;
}

+ (NSDictionary*)getJsonObjectFromString:(NSString*)jsonStr{
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    json = [self cleanupDictionaryFromNSNull:json];
    return json;
}

+ (id)cleanupDictionaryFromNSNull:(id)object{
    if (!object || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }else if (![object isKindOfClass:[NSDictionary class]] && ![object isKindOfClass:[NSMutableDictionary class]]){
        return object;
    }

    NSMutableDictionary* editedDictionary = [[NSMutableDictionary alloc] init];
    for (NSString* key in object) {
        id value = object[key];
        id result = [self cleanupDictionaryFromNSNull:value];
        if (result) {
            editedDictionary[key]=result;
        }
    }
    
    return [editedDictionary copy];
}

+ (NSDictionary*)fetchIncludedObject:(NSString*)objectId withType:(NSString*)type fromData:(NSDictionary*)data{
    NSArray* includedData = [data valueForKeyPath:@"included"];
    
    if (includedData && includedData.count > 0 && objectId && objectId.length > 0 && type && type.length > 0) {
        for (int i = 0; i < includedData.count; i++) {
            NSDictionary* data = [includedData objectAtIndex:i];
            NSString* includedObjectId = [data valueForKeyPath:@"id"];
            NSString* includedObjectType = [data valueForKeyPath:@"type"];
            if (includedObjectId && [includedObjectId isEqualToString:objectId] && includedObjectType && [includedObjectType isEqualToString:type]) {
                return data;
            }
        }
    }
    
    return nil;
}


@end

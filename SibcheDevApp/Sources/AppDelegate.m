//
//  AppDelegate.m
//  SibcheDevApp
//
//  Created by Mehdi on 2/9/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "AppDelegate.h"
#import <SibcheStoreKit/SibcheStoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SibcheStoreKit initWithApiKey:@"wnl6qrLmgNadY3kK3MWz5QkAo7OEXe" withScheme:@"testapp"];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    [SibcheStoreKit openUrl:url options:options];
    return YES;
}

@end

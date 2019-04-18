#import "SBStoreKit.h"
#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "Constants.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import <CoreText/CoreText.h>
#import "SBPackageFactory.h"
#import "SibcheHelper.h"

@interface SBStoreKit()

@property NSMutableArray* loginCallbacks;
@property NSMutableArray* purchaseCallbacks;

@end


@implementation SBStoreKit

+ (id)sharedManager{
    static SBStoreKit *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if ( self = [super init] ) {
        __weak SBStoreKit *weakSelf = self;

        [[NSNotificationCenter defaultCenter] addObserverForName:nil object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf newNotification:note];
        }];
        [self loadFonts];
        [[UITextField appearance] setTintColor:BLUE_COLOR];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadFonts {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadFontWithName:@"RiSans-Black"];
        [self loadFontWithName:@"RiSans-Bold"];
        [self loadFontWithName:@"RiSans-Light"];
        [self loadFontWithName:@"RiSans-Medium"];
        [self loadFontWithName:@"RiSans-Regular"];
    });
}

- (void)loadFontWithName:(NSString *)fontName {
    NSString *fontPath = [[NSBundle bundleForClass:[SBStoreKit class]] pathForResource:fontName ofType:@"ttf"];
    NSData *fontData = [NSData dataWithContentsOfFile:fontPath];
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
    
    if (provider)
    {
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        
        if (font)
        {
            CFErrorRef error = NULL;
            if (CTFontManagerRegisterGraphicsFont(font, &error) == NO)
            {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                CFRelease(errorDescription);
            }
            
            CFRelease(font);
        }
        
        CFRelease(provider);
    }
}

- (void)newNotification:(NSNotification*)note{
    NSString* name = note.name;
    if ([name isEqualToString:LOGIN_SUCCESSFUL] || [name isEqualToString:LOGIN_CANCELED]) {
        for (int i = 0; i < self.loginCallbacks.count; i++) {
            ProfileCallback callback = self.loginCallbacks[i];
            if ([name isEqual:LOGIN_CANCELED]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(NO, nil, nil);
                });
            }else{
                [[self class] isLoggedIn:^(BOOL isLoginSuccessful, NSString *userName, NSString *userId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(isLoginSuccessful, userName, userId);
                    });
                }];
            }
        }
        
        self.loginCallbacks = nil;
    }
    else if ([name isEqualToString:PAYMENT_SUCCESSFUL] || [name isEqualToString:PAYMENT_CANCELED]){
        for (int i = 0; i < self.purchaseCallbacks.count; i++) {
            PurchaseCallback callback = self.purchaseCallbacks[i];
            if ([name isEqual:PAYMENT_CANCELED]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(NO);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(YES);
                });
            }
        }
        
        self.purchaseCallbacks = nil;
    }
}

+ (void)initWithApiKey:(NSString*)appId withScheme:(NSString*)appScheme{
    if (![self doesSibcheSchemeExists]) {
        NSLog(@"Unable to init Sibche SDK because 'newsibche' scheme is not included in your Info.plist file. Please add 'newsibche' scheme to your LSApplicationQueriesSchemes array. Refer to 'https://stackoverflow.com/a/31986544/1514637' for more informations");
        return;
    }
    
    if (![self doesAppSchemeExists:appScheme]) {
        NSLog(@"Unable to init Sibche SDK because your specified scheme is not included in your Info.plist file. Please add your specified scheme to your CFBundleURLTypes. Refer to 'https://developer.apple.com/documentation/uikit/core_app/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app?language=objc' for more information");
        return;
    }
    
    [self sharedManager];
    
    DataManager* manager = [DataManager sharedManager];
    manager.appId = appId;
    manager.appScheme = appScheme;
}

+ (BOOL)doesSibcheSchemeExists{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray* schemes = [infoPlist valueForKey:@"LSApplicationQueriesSchemes"];
    if (!schemes || [schemes count] == 0) {
        return NO;
    }
    if ([schemes containsObject:@"newsibche"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)doesAppSchemeExists:(NSString*)appScheme{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray* urlTypes = [infoPlist valueForKey:@"CFBundleURLTypes"];
    if (!urlTypes || urlTypes.count == 0) {
        return NO;
    }
    
    BOOL containsAppScheme = NO;
    for (int i = 0; i < urlTypes.count; i++) {
        NSDictionary* dict = [urlTypes objectAtIndex:i];
        NSArray* schemes = [dict valueForKeyPath:@"CFBundleURLSchemes"];
        if (!schemes || schemes.count == 0) {
            continue;
        }
        if ([schemes containsObject:appScheme]) {
            containsAppScheme = YES;
            break;
        }
    }
    return containsAppScheme;
}


+ (void)fetchInAppPurchasePackages:(PackagesCallback)packagesListCallback{
    NSString* url = @"sdk/inAppPurchasePackages";
    [[NetworkManager sharedManager] get:url withAdditionalHeaders:nil withToken:nil withSuccess:^(NSString *response, NSDictionary *json) {
        NSArray* packageList = [json valueForKeyPath:@"data"];
        NSMutableArray* returnList = [[NSMutableArray alloc] init];
        if ([packageList isKindOfClass:[NSArray class]]) {
            for (NSDictionary* packageDictionary in packageList) {
                SBPackage* package = [SBPackageFactory getPackageWithData:packageDictionary];
                if (package) {
                    [returnList addObject:package];
                }
            }
        }
        packagesListCallback(YES, returnList);
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        packagesListCallback(NO, nil);
    }];
}

+ (void)fetchInAppPurchasePackage:(NSString*)packageId withPackagesCallback:(PackageCallback)packageCallback{
    [[NetworkManager sharedManager] get:[NSString stringWithFormat:@"sdk/inAppPurchasePackages/%@", packageId] withAdditionalHeaders:nil withToken:nil withSuccess:^(NSString *response, NSDictionary *json) {
        NSDictionary* packageData = [json valueForKeyPath:@"data"];
        SBPackage* package = [SBPackageFactory getPackageWithData:packageData];
        packageCallback(YES, package);
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        packageCallback(NO, nil);
    }];
}

+ (void)fetchActiveInAppPurchasePackages:(PurchasePackagesCallback)packagesListCallback{
    [self isLoggedIn:^(BOOL isLoginSuccessful, NSString *userName, NSString *userId) {
        if (isLoginSuccessful) {
            NSString* token = [SibcheHelper getToken];
            NSString* url = @"sdk/userInAppPurchasePackages";

            [[NetworkManager sharedManager] get:url withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
                NSArray* purchasePackageList = [SBPurchasePackage parsePurchasePackagesList:json];
                packagesListCallback(YES, purchasePackageList);
            } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
                packagesListCallback(NO, nil);
            }];
        }else{
            packagesListCallback(NO, nil);
        }
    }];
}


+ (void)showLoginView{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle* bundle = [NSBundle bundleForClass:[SBStoreKit class]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:bundle];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        UIViewController* topVC = [self topMostController];
        [topVC presentViewController:vc animated:YES completion:nil];
    });
}

+ (void)showPaymentView:(void (^ __nullable)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle* bundle = [NSBundle bundleForClass:[SBStoreKit class]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:bundle];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Payment"];
        
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        UIViewController* topVC = [self topMostController];
        [topVC presentViewController:vc animated:YES completion:completion];
    });
}


+ (UIViewController*) topMostController
{
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

+ (void)isLoggedIn:(ProfileCallback)loginResultCallback{
    NSString* token = [SibcheHelper getToken];
    if (token && token.length > 0) {
        [[NetworkManager sharedManager] get:@"profile" withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
            NSString* userName = [json valueForKeyPath:@"data.attributes.name"];
            NSString* userId = [json valueForKeyPath:@"data.id"];
            [DataManager sharedManager].profileData = json;
            loginResultCallback(YES, userName, userId);
        } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
            [DataManager sharedManager].profileData = nil;
            loginResultCallback(NO, @"", @"");
        }];
    }else{
        loginResultCallback(NO, @"", @"");
    }
}

+ (void)loginUser:(ProfileCallback)loginFinishCallback actionModeAfterLogin:(ActionAfterLogin)actionMode{
    [self isLoggedIn:^(BOOL isLoginSuccessful, NSString *userName, NSString *userId) {
        if (isLoginSuccessful) {
            if (actionMode == showPayment) {
                [self showPaymentView:^{
                    loginFinishCallback(isLoginSuccessful, userName, userId);
                }];
            }else{
                loginFinishCallback(isLoginSuccessful, userName, userId);
            }
        }else{
            NSMutableArray* callbackArray = [[SBStoreKit sharedManager] loginCallbacks];
            if (callbackArray) {
                [callbackArray addObject:loginFinishCallback];
            }else{
                callbackArray = [NSMutableArray arrayWithObjects:loginFinishCallback, nil];
            }
            if (actionMode == dismiss) {
                ProfileCallback dismissCalback = ^(BOOL isSuccessful, NSString* userName, NSString* userId){
                    if (isSuccessful) {
                        [[self topMostController] dismissViewControllerAnimated:YES completion:nil];
                    }
                };
                [callbackArray addObject: dismissCalback];
            } else if(actionMode == showPayment) {
                ProfileCallback dismissCalback = ^(BOOL isSuccessful, NSString* userName, NSString* userId){
                    if (isSuccessful) {
                        [[self topMostController] performSegueWithIdentifier:@"ShowPaymentSegue" sender:self];
                    }else{
                        [[self topMostController] dismissViewControllerAnimated:YES completion:nil];
                    }
                };
                [callbackArray addObject: dismissCalback];
            }
            [[SBStoreKit sharedManager] setLoginCallbacks:callbackArray];
            [self showLoginView];
        }
    }];
}

+ (void)loginUser:(ProfileCallback)loginFinishCallback{
    [self loginUser:loginFinishCallback actionModeAfterLogin:dismiss];
}

+ (void)logoutUser{
    NSString* url = @"profile/logout";
    NSString* token = [SibcheHelper getToken];
    
    [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        [SibcheHelper deleteToken];
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        [SibcheHelper deleteToken];
    }];
}

+ (void)purchasePackage:(NSString*)packageId withCallback:(PurchaseCallback)purchaseCallback{
    [DataManager sharedManager].purchasingPackageId = packageId;
    
    [self loginUser:^(BOOL isLoginSuccessful, NSString *userName, NSString *userId) {
        if (isLoginSuccessful) {
            NSMutableArray* callbackArray = [[SBStoreKit sharedManager] purchaseCallbacks];
            if (callbackArray) {
                [callbackArray addObject:purchaseCallback];
            }else{
                callbackArray = [NSMutableArray arrayWithObjects:purchaseCallback, nil];
            }
            
            [[SBStoreKit sharedManager] setPurchaseCallbacks:callbackArray];
        } else {
            purchaseCallback(NO);
        }
    } actionModeAfterLogin:showPayment];
}

+ (void)openUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if ([[url host] isEqualToString:@"SBStoreKit"]) {
        NSArray* pathComponents = [url pathComponents];
        if (pathComponents.count > 1) {
            if ([[pathComponents objectAtIndex:1] isEqualToString:@"transactions"] && pathComponents.count > 2) {
                NSString* transactionId = [pathComponents objectAtIndex:2];
                NSString* url = [NSString stringWithFormat:@"transactions/%@", transactionId];
                NSString* token = [SibcheHelper getToken];

                [[NetworkManager sharedManager] get:url withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
                    BOOL paid = [[json valueForKeyPath:@"data.attributes.paid"] boolValue];
                    if (paid) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:ADDCREDIT_SUCCESSFUL object:nil];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:ADDCREDIT_CANCELED object:nil];
                    }
                } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
                    //TODO: We should handle errors in a better manner
                    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCREDIT_CANCELED object:nil];
                }];
            }
        }
    }
}

+ (void)consumePurchasePackage:(NSString*)purchasePackageId withCallback:(PurchaseCallback)consumeCallback{
    NSString* url = [NSString stringWithFormat:@"sdk/userInAppPurchasePackages/%@/consume", purchasePackageId];
    NSString* token = [SibcheHelper getToken];
    
    [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        consumeCallback(YES);
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode) {
        consumeCallback(NO);
    }];
}

@end

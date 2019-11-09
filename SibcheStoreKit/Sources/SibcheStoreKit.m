#import "SibcheStoreKit.h"
#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "Constants.h"
#import "NetworkManager.h"
#import "DataManager.h"
#import <CoreText/CoreText.h>
#import "SibchePackageFactory.h"
#import "SibcheHelper.h"

@interface SibcheStoreKit()

@property NSMutableArray* loginCallbacks;
@property NSMutableArray* purchaseCallbacks;

@end


@implementation SibcheStoreKit

+ (id)sharedManager{
    static SibcheStoreKit *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if ( self = [super init] ) {
        __weak SibcheStoreKit *weakSelf = self;

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
    NSString *fontPath = [[NSBundle bundleForClass:[SibcheStoreKit class]] pathForResource:fontName ofType:@"ttf"];
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
                    callback(NO, [[SibcheError alloc] initWithErrorCode:operationCanceledError], nil, nil);
                });
            }else{
                [[self class] isLoggedIn:^(BOOL isLoginSuccessful, SibcheError* error, NSString *userName, NSString *userId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(isLoginSuccessful, nil, userName, userId);
                    });
                }];
            }
        }
        
        self.loginCallbacks = nil;
    }
    else if ([name isEqualToString:PAYMENT_SUCCESSFUL] || [name isEqualToString:PAYMENT_CANCELED] || [name isEqualToString:PAYMENT_FAILED]){
        for (int i = 0; i < self.purchaseCallbacks.count; i++) {
            PurchaseCallback callback = self.purchaseCallbacks[i];
            if ([name isEqual:PAYMENT_CANCELED]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(NO, [[SibcheError alloc] initWithErrorCode:operationCanceledError], nil);
                });
            } else if ([name isEqualToString:PAYMENT_FAILED]){
                NSString* messageStr = [note object];
                SibcheError* error = nil;
                if (messageStr) {
                    error = [[SibcheError alloc] initWithData:messageStr withHttpStatusCode:400];
                }else{
                    error = [[SibcheError alloc] init];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(NO, error, nil);
                });
            } else {
                SibchePurchasePackage* purchasePackage = [note object];
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(YES, nil, purchasePackage);
                });
            }
        }
        
        self.purchaseCallbacks = nil;
    }
}

+ (void)initWithApiKey:(NSString*)appId withScheme:(NSString*)appScheme{
    if (!appId || !appScheme) {
        NSLog(@"Unable to init Sibche SDK because your specified appId or appScheme is nil. Please provide valid string values.");
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
    if (![DataManager sharedManager].appId || ![DataManager sharedManager].appScheme) {
        packagesListCallback(NO, [[SibcheError alloc] initWithErrorCode:applicationNotInitedCorrectly], nil);
        return;
    }

    [[NetworkManager sharedManager] get:url withAdditionalHeaders:nil withToken:nil withSuccess:^(NSString *response, NSDictionary *json) {
        NSArray* packageList = [json valueForKeyPath:@"data"];
        NSMutableArray* returnList = [[NSMutableArray alloc] init];
        if ([packageList isKindOfClass:[NSArray class]]) {
            for (NSDictionary* packageDictionary in packageList) {
                SibchePackage* package = [SibchePackageFactory getPackageWithData:packageDictionary];
                if (package) {
                    [returnList addObject:package];
                }
            }
        }
        packagesListCallback(YES, nil, returnList);
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
        packagesListCallback(NO, [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode], nil);
    }];
}

+ (void)fetchInAppPurchasePackage:(NSString*)packageId withPackagesCallback:(PackageCallback)packageCallback{
    if (![DataManager sharedManager].appId || ![DataManager sharedManager].appScheme) {
        packageCallback(NO, [[SibcheError alloc] initWithErrorCode:applicationNotInitedCorrectly], nil);
        return;
    }

    [[NetworkManager sharedManager] get:[NSString stringWithFormat:@"sdk/inAppPurchasePackages/%@", packageId] withAdditionalHeaders:nil withToken:nil withSuccess:^(NSString *response, NSDictionary *json) {
        NSDictionary* packageData = [json valueForKeyPath:@"data"];
        SibchePackage* package = [SibchePackageFactory getPackageWithData:packageData];
        packageCallback(YES, nil, package);
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
        packageCallback(NO, [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode], nil);
    }];
}

+ (void)fetchActiveInAppPurchasePackages:(PurchasePackagesCallback)packagesListCallback{
    if (![DataManager sharedManager].appId || ![DataManager sharedManager].appScheme) {
        packagesListCallback(NO, [[SibcheError alloc] initWithErrorCode:applicationNotInitedCorrectly], nil);
        return;
    }

    [self isLoggedIn:^(BOOL isLoginSuccessful, SibcheError* error, NSString *userName, NSString *userId) {
        if (isLoginSuccessful) {
            NSString* token = [SibcheHelper getToken];
            NSString* url = @"sdk/userInAppPurchasePackages";

            [[NetworkManager sharedManager] get:url withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
                NSArray* purchasePackageList = [SibchePurchasePackage parsePurchasePackagesList:json];
                packagesListCallback(YES, nil, purchasePackageList);
            } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
                packagesListCallback(NO, [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode], nil);
            }];
        } else {
            packagesListCallback(NO, [[SibcheError alloc] initWithErrorCode:loginFailedError], nil);
        }
    }];
}


+ (void)showLoginView:(void (^ __nullable)(void))completion{
    [self showVCWithName:@"Login" withCompletion:completion];
}

+ (void)showPaymentView:(void (^ __nullable)(void))completion{
    [self showVCWithName:@"Payment" withCompletion:completion];
}

+ (void)showVCWithName:(NSString*)name withCompletion:(void (^ __nullable)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle* bundle = [NSBundle bundleForClass:[SibcheStoreKit class]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:bundle];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:name];
        
        UIViewController* topVC = [SibcheHelper topMostController];
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        if (topVC.navigationController && [[topVC.navigationController valueForKey:@"storyboardIdentifier"] isEqualToString:@"Loading"]) {
            [topVC dismissViewControllerAnimated:YES completion:^{
                [[SibcheHelper topMostController] presentViewController:vc animated:YES completion:completion];
            }];
        }else{
            [topVC presentViewController:vc animated:YES completion:completion];
        }
    });
}

+ (void)showLoadingView:(void (^ __nullable)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle* bundle = [NSBundle bundleForClass:[SibcheStoreKit class]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:bundle];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Loading"];
        
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        UIViewController* topVC = [SibcheHelper topMostController];
        [topVC presentViewController:vc animated:YES completion:completion];
    });
}

+ (void)dismissOverlay:(void (^ __nullable)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SibcheHelper topMostController] dismissViewControllerAnimated:YES completion:completion];
    });
}

+ (void)isLoggedIn:(ProfileCallback)loginResultCallback{
    NSString* token = [SibcheHelper getToken];
    if (token && token.length > 0) {
        [[NetworkManager sharedManager] get:@"profile" withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
            NSString* userName = [json valueForKeyPath:@"data.attributes.name"];
            NSString* userId = [json valueForKeyPath:@"data.id"];
            [DataManager sharedManager].profileData = json;
            loginResultCallback(YES, nil, userName, userId);
        } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
            [DataManager sharedManager].profileData = nil;
            if (httpStatusCode == 401) {
                [self logoutUser:^{}];
            }
            loginResultCallback(NO, [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode], @"", @"");
        }];
    }else{
        loginResultCallback(NO, [[SibcheError alloc] initWithErrorCode:unknownError], @"", @"");
    }
}

+ (void)loginUser:(ProfileCallback)loginFinishCallback actionModeAfterLogin:(ActionAfterLogin)actionMode{
    if (![DataManager sharedManager].appId || ![DataManager sharedManager].appScheme) {
        loginFinishCallback(NO, [[SibcheError alloc] initWithErrorCode:applicationNotInitedCorrectly], @"", @"");
        return;
    }

    [self showLoadingView:^{
        [self isLoggedIn:^(BOOL isLoginSuccessful, SibcheError* error, NSString *userName, NSString *userId) {
            if (isLoginSuccessful) {
                if (actionMode == showPayment) {
                    [self showPaymentView:^{
                        loginFinishCallback(isLoginSuccessful, error, userName, userId);
                    }];
                }else{
                    [self dismissOverlay:^{
                        loginFinishCallback(isLoginSuccessful, error, userName, userId);
                    }];
                }
            }else{
                NSMutableArray* callbackArray = [[SibcheStoreKit sharedManager] loginCallbacks];
                if (callbackArray) {
                    [callbackArray addObject:loginFinishCallback];
                }else{
                    callbackArray = [NSMutableArray arrayWithObjects:loginFinishCallback, nil];
                }
                if (actionMode == dismiss) {
                    ProfileCallback dismissCalback = ^(BOOL isSuccessful, SibcheError* error, NSString* userName, NSString* userId){
                        if (isSuccessful) {
                            [self dismissOverlay:nil];
                        }
                    };
                    [callbackArray addObject: dismissCalback];
                } else if(actionMode == showPayment) {
                    ProfileCallback dismissCalback = ^(BOOL isSuccessful, SibcheError* error, NSString* userName, NSString* userId){
                        if (isSuccessful) {
                            [[SibcheHelper topMostController] performSegueWithIdentifier:@"ShowPaymentSegue" sender:self];
                        }else{
                            [self dismissOverlay:nil];
                        }
                    };
                    [callbackArray addObject: dismissCalback];
                }
                [[SibcheStoreKit sharedManager] setLoginCallbacks:callbackArray];
                [self showLoginView:nil];
            }
        }];
    }];
}

+ (void)loginUser:(ProfileCallback)loginFinishCallback{
    [self loginUser:loginFinishCallback actionModeAfterLogin:dismiss];
}

+ (void)logoutUser:(LogoutCallback)logoutFinishCallback{
    NSString* url = @"profile/logout";
    NSString* token = [SibcheHelper getToken];
    if (token && token.length > 0) {
        [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
            [SibcheHelper deleteToken];
            logoutFinishCallback();
        } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
            [SibcheHelper deleteToken];
            logoutFinishCallback();
        }];
    }else{
        logoutFinishCallback();
    }
}

+ (void)purchasePackage:(NSString*)packageId withCallback:(PurchaseCallback)purchaseCallback{
    if (![DataManager sharedManager].appId || ![DataManager sharedManager].appScheme) {
        purchaseCallback(NO, [[SibcheError alloc] initWithErrorCode:applicationNotInitedCorrectly], nil);
        return;
    }
    
    [DataManager sharedManager].purchasingPackageId = packageId;
    
    [self loginUser:^(BOOL isLoginSuccessful, SibcheError* error, NSString *userName, NSString *userId) {
        if (isLoginSuccessful) {
            NSMutableArray* callbackArray = [[SibcheStoreKit sharedManager] purchaseCallbacks];
            if (callbackArray) {
                [callbackArray addObject:purchaseCallback];
            }else{
                callbackArray = [NSMutableArray arrayWithObjects:purchaseCallback, nil];
            }
            
            [[SibcheStoreKit sharedManager] setPurchaseCallbacks:callbackArray];
        } else {
            purchaseCallback(NO, [[SibcheError alloc] initWithErrorCode:loginFailedError], nil);
        }
    } actionModeAfterLogin:showPayment];
}

+ (void)openUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if ([[url host] isEqualToString:@"SibcheStoreKit"]) {
        NSArray* pathComponents = [url pathComponents];
        if (pathComponents.count > 1) {
            if ([[pathComponents objectAtIndex:1] isEqualToString:@"transactions"] && pathComponents.count > 2) {
                if ([[url absoluteString] containsString:@"success"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCREDIT_SUCCESSFUL object:nil];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:ADDCREDIT_CANCELED object:nil];
                }
            }
        }
    }
}

+ (void)consumePurchasePackage:(NSString*)purchasePackageId withCallback:(ConsumeCallback)consumeCallback{
    if (![DataManager sharedManager].appId || ![DataManager sharedManager].appScheme) {
        consumeCallback(NO, [[SibcheError alloc] initWithErrorCode:applicationNotInitedCorrectly]);
        return;
    }

    NSString* url = [NSString stringWithFormat:@"sdk/userInAppPurchasePackages/%@/consume", purchasePackageId];
    NSString* token = [SibcheHelper getToken];
    
    [[NetworkManager sharedManager] post:url withData:nil withAdditionalHeaders:nil withToken:token withSuccess:^(NSString *response, NSDictionary *json) {
        consumeCallback(YES, nil);
    } withFailure:^(NSInteger errorCode, NSInteger httpStatusCode, NSString* response) {
        consumeCallback(NO, [[SibcheError alloc] initWithData:response withHttpStatusCode:httpStatusCode]);
    }];
}

+ (void)getCurrentUserData:(CurrentUserCallback)currentUserCallback{
    DataManager* manager = [DataManager sharedManager];
    if (manager.profileData) {
        NSString* userCellphone = [manager.profileData valueForKeyPath:@"data.attributes.mobile"];
        NSString* userId = [manager.profileData valueForKeyPath:@"data.id"];
        currentUserCallback(YES, nil, loginStatusTypeIsLoggedIn, userCellphone, userId);
    }else{
        NSString* token = [SibcheHelper getToken];
        if (token && token.length > 0) {
            [self isLoggedIn:^(BOOL isSuccessful, SibcheError *error, NSString *userName, NSString *userId) {
                if (isSuccessful) {
                    NSString* userCellphone = [manager.profileData valueForKeyPath:@"data.attributes.mobile"];
                    currentUserCallback(YES, nil, loginStatusTypeIsLoggedIn, userCellphone, userId);
                }else{
                    if ([error.statusCode isEqualToNumber:@401]) {
                        currentUserCallback(NO, error, loginStatusTypeIsLoggedOut, @"", @"");
                    }else{
                        currentUserCallback(NO, error, loginStatusTypeHaveTokenButFailedToCheck, @"", @"");
                    }
                }
            }];
        }else{
            currentUserCallback(YES, nil, loginStatusTypeIsLoggedOut, @"", @"");
        }
    }
}

@end

#import <UIKit/UIKit.h>
#import "SBPackage.h"
#import "SBConsumablePackage.h"
#import "SBNonConsumablePackage.h"
#import "SBSubscriptionPackage.h"
#import "SBPurchasePackage.h"

FOUNDATION_EXPORT double SBStoreKitVersionNumber;
FOUNDATION_EXPORT const unsigned char SBStoreKitVersionString[];

typedef void (^ProfileCallback)(BOOL isSuccessful, NSString* userName, NSString* userId);
typedef void (^PackageCallback)(BOOL isSuccessful, SBPackage* package);
typedef void (^PackagesCallback)(BOOL isSuccessful, NSArray* packagesArray);
typedef void (^PurchasePackagesCallback)(BOOL isSuccessful, NSArray* purchasePackagesArray);
typedef void (^PurchasePackageCallback)(BOOL isSuccessful, SBPackage* purchasePackagesArray);
typedef void (^PurchaseCallback)(BOOL isSuccessful);


@interface SBStoreKit : NSObject

// Init sdk with your app's api key
+ (void)initWithApiKey:(NSString*)appId withScheme:(NSString*)appScheme;

// Fetch list of your in-app-purchase packages
+ (void)fetchInAppPurchasePackages:(PackagesCallback)packagesListCallback;

// Fetch data of specific in-app-purchase package
+ (void)fetchInAppPurchasePackage:(NSString*)packageId withPackagesCallback:(PackageCallback)packagesCallback;

// Fetch list of active in-app-purchase packages
+ (void)fetchActiveInAppPurchasePackages:(PurchasePackagesCallback)packagesListCallback;

// This command says SDK to show login view and return result
+ (void)loginUser:(ProfileCallback)loginFinishCallback;

// This command used to logout user from sibche. Don't use unless you know what are you doing
+ (void)logoutUser;

// Purchase specific packageId. After finishing, we call PurchaseCallback
+ (void)purchasePackage:(NSString*)packageId withCallback:(PurchaseCallback)purchaseCallback;

// This function handles addCredit return and SDK's other openUrl mechanisms
+ (void)openUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

// Consumes purchased package item (if is consumable)
+ (void)consumePurchasePackage:(NSString*)purchasePackageId withCallback:(PurchaseCallback)consumeCallback;

typedef enum ActionAfterLogin : NSUInteger {
    dismiss,
    showPayment
} ActionAfterLogin;

@end

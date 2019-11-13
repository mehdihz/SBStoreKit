//
//  VoucherButton.h
//  SibcheStoreKit
//
//  Created by Mehdi on 11/12/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    VoucherButtonModeNormal,
    VoucherButtonModeDelete,
    VoucherButtonModeLoading,
    VoucherButtonModeError,
} VoucherButtonMode;

IB_DESIGNABLE
@interface VoucherButton : UIButton

@property (nonatomic) IBInspectable UIColor *normalModeBackgroundColor;
@property (nonatomic) IBInspectable UIColor *deleteModeBackgroundColor;
@property (nonatomic) IBInspectable UIColor *errorBackgroundColor;

- (void)changeButtonMode:(NSUInteger)buttonMode;

@end

NS_ASSUME_NONNULL_END

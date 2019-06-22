//
//  FilledButton.h
//  SibcheStoreKit
//
//  Created by Mehdi on 2/19/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface FilledButton : UIButton

@property (nonatomic) IBInspectable UIColor *defaultBackgroundColor;
@property (nonatomic) IBInspectable UIColor *highlightBackgroundColor;

- (void)setLoading:(BOOL)loading;

@end

NS_ASSUME_NONNULL_END

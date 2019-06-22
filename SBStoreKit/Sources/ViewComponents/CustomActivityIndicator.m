//
//  CustomActivityIndicator.m
//  SibcheStoreKit
//
//  Created by Mehdi on 5/4/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "CustomActivityIndicator.h"

@implementation CustomActivityIndicator

- (void)drawRect:(CGRect)rect {
    SBActivityIndicatorView *activityIndicatorView = [[SBActivityIndicatorView alloc] initWithType:SBActivityIndicatorAnimationTypeBallSpinFadeLoader tintColor:self.tintColor ? self.tintColor : [UIColor whiteColor] size:rect.size.width < rect.size.height ? rect.size.width : rect.size.height];
    activityIndicatorView.frame = rect;
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
}

@end

//
//  TopRoundedView.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/30/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "TopRoundedView.h"
#import "SibcheHelper.h"

@implementation TopRoundedView

- (void)layoutSubviews{
    [super layoutSubviews];
    [self roundCorners];
}

- (void)roundCorners {
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(16, 16)
                              ];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[SBKeyboardManager defaultManager] addObserver:self];
}

- (void)dealloc {
    [[SBKeyboardManager defaultManager] removeObserver:self];
}

- (void)keyboardChangedWithTransition:(SBKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[SBKeyboardManager defaultManager] convertRect:transition.toFrame toView:[SibcheHelper topMostController].view];
        CGRect bottomViewframe = self.frame;
        bottomViewframe.origin.y = kbFrame.origin.y - bottomViewframe.size.height;
        self.frame = bottomViewframe;
    } completion:^(BOOL finished) {
        
    }];
}

@end

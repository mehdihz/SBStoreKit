//
//  RoundedView.m
//  SibcheStoreKit
//
//  Created by Mehdi on 4/30/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "RoundedView.h"
#import "SibcheHelper.h"

@implementation RoundedView

- (void)layoutSubviews{
    [super layoutSubviews];
    [self roundCorners];
}

- (void)roundCorners {
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.bounds
                              byRoundingCorners:(UIRectCornerAllCorners)
                              cornerRadii:CGSizeMake(16, 16)
                              ];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end

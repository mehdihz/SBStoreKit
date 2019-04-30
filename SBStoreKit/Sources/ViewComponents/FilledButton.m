//
//  FilledButton.m
//  SBStoreKit
//
//  Created by Mehdi on 2/19/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "FilledButton.h"

@implementation FilledButton

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = self.defaultBackgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = self.highlightBackgroundColor;
    } else {
        self.backgroundColor = self.defaultBackgroundColor;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self roundCorners];
}

- (void)roundCorners {
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.bounds
                              byRoundingCorners:UIRectCornerAllCorners
                              cornerRadii:CGSizeMake(24, 24)
                              ];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end

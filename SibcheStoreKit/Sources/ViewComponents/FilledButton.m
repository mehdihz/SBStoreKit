//
//  FilledButton.m
//  SibcheStoreKit
//
//  Created by Mehdi on 2/19/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "FilledButton.h"
#import "CustomActivityIndicator.h"

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

- (void)setLoading:(BOOL)loading {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView* labelView = nil;
        UIView* indicatorView = nil;
        for (UIView* subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UIButtonLabel")]) {
                labelView = subview;
            } else if ([subview isKindOfClass:[CustomActivityIndicator class]]) {
                indicatorView = subview;
            }
        }
        
        if (!indicatorView) {
            CGFloat x = (self.frame.size.width - 20)/2;
            CGFloat y = (self.frame.size.height - 20)/2;
            indicatorView = [[CustomActivityIndicator alloc] initWithFrame:CGRectMake(x, y, 20, 20)];
            indicatorView.hidden = YES;
            [self addSubview:indicatorView];
        }
        
        if (loading) {
            indicatorView.hidden = NO;
            labelView.layer.opacity = 0.0f;
            // TODO: Use animation for showing of indicator
//            [UIView transitionWithView:self
//                              duration:0.3
//                               options:UIViewAnimationOptionCurveEaseOut
//                            animations:^{
//                                labelView.layer.opacity = 0.0f;
//                            }
//                            completion:^(BOOL finished){
//                                [UIView transitionWithView:self
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionCurveEaseIn
//                                                animations:^{
//                                                    indicatorView.hidden = NO;
//                                                }
//                                                completion:NULL];
//                            }];
        }else{
            indicatorView.hidden = YES;
            labelView.layer.opacity = 1.0f;
            // TODO: Use animation for hiding of indicator
//            [UIView transitionWithView:self
//                              duration:0.3
//                               options:UIViewAnimationOptionCurveEaseOut
//                            animations:^{
//                                indicatorView.hidden = YES;
//                            }
//                            completion:^(BOOL finished){
//                                [UIView transitionWithView:self
//                                                  duration:0.3
//                                                   options:UIViewAnimationOptionCurveEaseIn
//                                                animations:^{
//                                                    labelView.layer.opacity = 1.0f;
//                                                }
//                                                completion:NULL];
//                            }];
        }
    });
}

@end

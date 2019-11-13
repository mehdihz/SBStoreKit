//
//  VoucherButton.m
//  SibcheStoreKit
//
//  Created by Mehdi on 11/12/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "VoucherButton.h"
#import "CustomActivityIndicator.h"

@implementation VoucherButton

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = self.normalModeBackgroundColor;
    self.adjustsImageWhenHighlighted = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.7];
    } else {
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
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
                              cornerRadii:CGSizeMake(self.bounds.size.width, self.bounds.size.height)
                              ];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setLoading:(BOOL)loading {
    UIView* indicatorView = nil;
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[CustomActivityIndicator class]]) {
            indicatorView = subview;
        }
    }
    
    if (!indicatorView) {
        int indicatorSize = self.bounds.size.width - 7 * 2;
        CGFloat x = (self.bounds.size.width - indicatorSize)/2;
        CGFloat y = (self.bounds.size.height - indicatorSize)/2;
        indicatorView = [[CustomActivityIndicator alloc] initWithFrame:CGRectMake(x, y, indicatorSize, indicatorSize)];
        indicatorView.hidden = YES;
        [self addSubview:indicatorView];
    }
    
    indicatorView.hidden = !loading;
}

- (void)changeButtonMode:(NSUInteger)buttonMode{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        

        if (buttonMode == VoucherButtonModeNormal) {
            [UIView transitionWithView:self
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self setLoading:NO];
                                [self setImage:[UIImage imageNamed:@"Apply" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
                                self.backgroundColor = self.normalModeBackgroundColor;
                                [self layoutIfNeeded];
                            }
                            completion:NULL];
        }else if (buttonMode == VoucherButtonModeDelete){
            [UIView transitionWithView:self
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self setLoading:NO];
                                [self setImage:[UIImage imageNamed:@"Delete" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
                                self.backgroundColor = self.deleteModeBackgroundColor;
                                [self layoutIfNeeded];
                            }
                            completion:NULL];
        }else if(buttonMode == VoucherButtonModeError){
            [UIView transitionWithView:self
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self setLoading:NO];
                                [self setImage:[UIImage imageNamed:@"Error" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
                                self.backgroundColor = self.errorBackgroundColor;
                                [self layoutIfNeeded];
                            }
                            completion:NULL];
        }else{
            [self setImage:nil forState:UIControlStateNormal];
            [UIView transitionWithView:self
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self setLoading:YES];
                                [self layoutIfNeeded];
                            }
                            completion:NULL];
        }
    });
}

@end

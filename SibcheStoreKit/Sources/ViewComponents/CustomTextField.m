//
//  CustomTextField.m
//  SibcheStoreKit
//
//  Created by Mehdi on 3/30/19.
//  Copyright © 2019 Sibche. All rights reserved.
//

#import "CustomTextField.h"
#import "SibcheHelper.h"
#import "Constants.h"

@implementation CustomTextField
-(void)awakeFromNib{
    [super awakeFromNib];
    [super addTarget:self action:@selector(didBegin) forControlEvents:UIControlEventEditingDidBegin];
    [super addTarget:self action:@selector(didEnd) forControlEvents:UIControlEventEditingDidEnd];
    
    [super setBorderStyle:UITextBorderStyleNone];
    [self addBottomLineWithColor:SEPERATOR_COLOR lineWitdh:2.0];
}

-(void)didBegin{
    [self addBottomLineWithColor:BLUE_COLOR lineWitdh:2.0];
}

-(void)didEnd{
    [self addBottomLineWithColor:SEPERATOR_COLOR lineWitdh:2.0];
}


- (void)addBottomLineWithColor:(UIColor *)color lineWitdh:(CGFloat)width{
    UIView *lineView = [[UIView alloc] init];
    lineView.tag = 1000;
    [lineView setBackgroundColor:color];
    [lineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    for (UIView* subview in self.subviews) {
        if (subview.tag == 1000) {
            [subview removeFromSuperview];
        }
    }
    [self addSubview:lineView];
    
    NSDictionary *metrics = @{@"width" : [NSNumber numberWithFloat:width]};
    NSDictionary *views = @{@"lineView" : lineView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lineView]|" options: 0 metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lineView(width)]|" options: 0 metrics:metrics views:views]];
}

@end

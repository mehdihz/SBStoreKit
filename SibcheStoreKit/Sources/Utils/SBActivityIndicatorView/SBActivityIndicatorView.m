//
//  SBActivityIndicatorView.m
//  SBActivityIndicatorExample
//
//  Created by Danil Gontovnik on 5/23/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "SBActivityIndicatorView.h"

#import "SBActivityIndicatorNineDotsAnimation.h"
#import "SBActivityIndicatorTriplePulseAnimation.h"
#import "SBActivityIndicatorFiveDotsAnimation.h"
#import "SBActivityIndicatorRotatingSquaresAnimation.h"
#import "SBActivityIndicatorDoubleBounceAnimation.h"
#import "SBActivityIndicatorTwoDotsAnimation.h"
#import "SBActivityIndicatorThreeDotsAnimation.h"
#import "SBActivityIndicatorBallPulseAnimation.h"
#import "SBActivityIndicatorBallClipRotateAnimation.h"
#import "SBActivityIndicatorBallClipRotatePulseAnimation.h"
#import "SBActivityIndicatorBallClipRotateMultipleAnimation.h"
#import "SBActivityIndicatorBallRotateAnimation.h"
#import "SBActivityIndicatorBallZigZagAnimation.h"
#import "SBActivityIndicatorBallZigZagDeflectAnimation.h"
#import "SBActivityIndicatorBallTrianglePathAnimation.h"
#import "SBActivityIndicatorBallScaleAnimation.h"
#import "SBActivityIndicatorLineScaleAnimation.h"
#import "SBActivityIndicatorLineScalePartyAnimation.h"
#import "SBActivityIndicatorBallScaleMultipleAnimation.h"
#import "SBActivityIndicatorBallPulseSyncAnimation.h"
#import "SBActivityIndicatorBallBeatAnimation.h"
#import "SBActivityIndicatorLineScalePulseOutAnimation.h"
#import "SBActivityIndicatorLineScalePulseOutRapidAnimation.h"
#import "SBActivityIndicatorBallScaleRippleAnimation.h"
#import "SBActivityIndicatorBallScaleRippleMultipleAnimation.h"
#import "SBActivityIndicatorTriangleSkewSpinAnimation.h"
#import "SBActivityIndicatorBallGridBeatAnimation.h"
#import "SBActivityIndicatorBallGridPulseAnimation.h"
#import "SBActivityIndicatorRotatingSandglassAnimation.h"
#import "SBActivityIndicatorRotatingTrigonAnimation.h"
#import "SBActivityIndicatorTripleRingsAnimation.h"
#import "SBActivityIndicatorCookieTerminatorAnimation.h"
#import "SBActivityIndicatorBallSpinFadeLoader.h"

static const CGFloat kSBActivityIndicatorDefaultSize = 40.0f;

@interface SBActivityIndicatorView () {
    CALayer *_animationLayer;
}

@end

@implementation SBActivityIndicatorView

#pragma mark -
#pragma mark Constructors

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tintColor = [UIColor whiteColor];
        _size = kSBActivityIndicatorDefaultSize;
        [self commonInit];
    }
    return self;
}

- (id)initWithType:(SBActivityIndicatorAnimationType)type {
    return [self initWithType:type tintColor:[UIColor whiteColor] size:kSBActivityIndicatorDefaultSize];
}

- (id)initWithType:(SBActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor {
    return [self initWithType:type tintColor:tintColor size:kSBActivityIndicatorDefaultSize];
}

- (id)initWithType:(SBActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor size:(CGFloat)size {
    self = [super init];
    if (self) {
        _type = type;
        _size = size;
        _tintColor = tintColor;
        [self commonInit];
    }
    return self;
}

#pragma mark -
#pragma mark Methods

- (void)commonInit {
    self.userInteractionEnabled = NO;
    self.hidden = YES;
    
    _animationLayer = [[CALayer alloc] init];
    [self.layer addSublayer:_animationLayer];

    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)setupAnimation {
    _animationLayer.sublayers = nil;
    
    id<SBActivityIndicatorAnimationProtocol> animation = [SBActivityIndicatorView activityIndicatorAnimationForAnimationType:_type];
    
    if ([animation respondsToSelector:@selector(setupAnimationInLayer:withSize:tintColor:)]) {
        [animation setupAnimationInLayer:_animationLayer withSize:CGSizeMake(_size, _size) tintColor:_tintColor];
        _animationLayer.speed = 0.0f;
    }
}

- (void)startAnimating {
    if (!_animationLayer.sublayers) {
        [self setupAnimation];
    }
    self.hidden = NO;
    _animationLayer.speed = 1.0f;
    _animating = YES;
}

- (void)stopAnimating {
    _animationLayer.speed = 0.0f;
    _animating = NO;
    self.hidden = YES;
}

#pragma mark -
#pragma mark Setters

- (void)setType:(SBActivityIndicatorAnimationType)type {
    if (_type != type) {
        _type = type;
        
        [self setupAnimation];
    }
}

- (void)setSize:(CGFloat)size {
    if (_size != size) {
        _size = size;
        
        [self setupAnimation];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (![_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        
        CGColorRef tintColorRef = tintColor.CGColor;
        for (CALayer *sublayer in _animationLayer.sublayers) {
            sublayer.backgroundColor = tintColorRef;
            
            if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
                CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                shapeLayer.strokeColor = tintColorRef;
                shapeLayer.fillColor = tintColorRef;
            }
        }
    }
}

#pragma mark -
#pragma mark Getters

+ (id<SBActivityIndicatorAnimationProtocol>)activityIndicatorAnimationForAnimationType:(SBActivityIndicatorAnimationType)type {
    switch (type) {
        case SBActivityIndicatorAnimationTypeNineDots:
            return [[SBActivityIndicatorNineDotsAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeTriplePulse:
            return [[SBActivityIndicatorTriplePulseAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeFiveDots:
            return [[SBActivityIndicatorFiveDotsAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeRotatingSquares:
            return [[SBActivityIndicatorRotatingSquaresAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeDoubleBounce:
            return [[SBActivityIndicatorDoubleBounceAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeTwoDots:
            return [[SBActivityIndicatorTwoDotsAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeThreeDots:
            return [[SBActivityIndicatorThreeDotsAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallPulse:
            return [[SBActivityIndicatorBallPulseAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallClipRotate:
            return [[SBActivityIndicatorBallClipRotateAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallClipRotatePulse:
            return [[SBActivityIndicatorBallClipRotatePulseAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallClipRotateMultiple:
            return [[SBActivityIndicatorBallClipRotateMultipleAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallRotate:
            return [[SBActivityIndicatorBallRotateAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallZigZag:
            return [[SBActivityIndicatorBallZigZagAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallZigZagDeflect:
            return [[SBActivityIndicatorBallZigZagDeflectAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallTrianglePath:
            return [[SBActivityIndicatorBallTrianglePathAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallScale:
            return [[SBActivityIndicatorBallScaleAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeLineScale:
            return [[SBActivityIndicatorLineScaleAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeLineScaleParty:
            return [[SBActivityIndicatorLineScalePartyAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallScaleMultiple:
            return [[SBActivityIndicatorBallScaleMultipleAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallPulseSync:
            return [[SBActivityIndicatorBallPulseSyncAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallBeat:
            return [[SBActivityIndicatorBallBeatAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeLineScalePulseOut:
            return [[SBActivityIndicatorLineScalePulseOutAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeLineScalePulseOutRapid:
            return [[SBActivityIndicatorLineScalePulseOutRapidAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallScaleRipple:
            return [[SBActivityIndicatorBallScaleRippleAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallScaleRippleMultiple:
            return [[SBActivityIndicatorBallScaleRippleMultipleAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeTriangleSkewSpin:
            return [[SBActivityIndicatorTriangleSkewSpinAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallGridBeat:
            return [[SBActivityIndicatorBallGridBeatAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeBallGridPulse:
            return [[SBActivityIndicatorBallGridPulseAnimation alloc] init];
        case SBActivityIndicatorAnimationTypeRotatingSandglass:
            return [[SBActivityIndicatorRotatingSandglassAnimation alloc]init];
        case SBActivityIndicatorAnimationTypeRotatingTrigons:
            return [[SBActivityIndicatorRotatingTrigonAnimation alloc]init];
        case SBActivityIndicatorAnimationTypeTripleRings:
            return [[SBActivityIndicatorTripleRingsAnimation alloc]init];
        case SBActivityIndicatorAnimationTypeCookieTerminator:
            return [[SBActivityIndicatorCookieTerminatorAnimation alloc]init];
        case SBActivityIndicatorAnimationTypeBallSpinFadeLoader:
            return [[SBActivityIndicatorBallSpinFadeLoader alloc] init];
    }
    return nil;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _animationLayer.frame = self.bounds;

    BOOL animating = _animating;

    if (animating)
        [self stopAnimating];

    [self setupAnimation];

    if (animating)
        [self startAnimating];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(_size, _size);
}

@end

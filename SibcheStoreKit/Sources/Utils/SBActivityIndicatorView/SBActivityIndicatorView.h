//
//  SBActivityIndicatorView.h
//  SBActivityIndicatorExample
//
//  Created by Danil Gontovnik on 5/23/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SBActivityIndicatorAnimationType) {
    SBActivityIndicatorAnimationTypeNineDots,
    SBActivityIndicatorAnimationTypeTriplePulse,
    SBActivityIndicatorAnimationTypeFiveDots,
    SBActivityIndicatorAnimationTypeRotatingSquares,
    SBActivityIndicatorAnimationTypeDoubleBounce,
    SBActivityIndicatorAnimationTypeTwoDots,
    SBActivityIndicatorAnimationTypeThreeDots,
    SBActivityIndicatorAnimationTypeBallPulse,
    SBActivityIndicatorAnimationTypeBallClipRotate,
    SBActivityIndicatorAnimationTypeBallClipRotatePulse,
    SBActivityIndicatorAnimationTypeBallClipRotateMultiple,
    SBActivityIndicatorAnimationTypeBallRotate,
    SBActivityIndicatorAnimationTypeBallZigZag,
    SBActivityIndicatorAnimationTypeBallZigZagDeflect,
    SBActivityIndicatorAnimationTypeBallTrianglePath,
    SBActivityIndicatorAnimationTypeBallScale,
    SBActivityIndicatorAnimationTypeLineScale,
    SBActivityIndicatorAnimationTypeLineScaleParty,
    SBActivityIndicatorAnimationTypeBallScaleMultiple,
    SBActivityIndicatorAnimationTypeBallPulseSync,
    SBActivityIndicatorAnimationTypeBallBeat,
    SBActivityIndicatorAnimationTypeLineScalePulseOut,
    SBActivityIndicatorAnimationTypeLineScalePulseOutRapid,
    SBActivityIndicatorAnimationTypeBallScaleRipple,
    SBActivityIndicatorAnimationTypeBallScaleRippleMultiple,
    SBActivityIndicatorAnimationTypeTriangleSkewSpin,
    SBActivityIndicatorAnimationTypeBallGridBeat,
    SBActivityIndicatorAnimationTypeBallGridPulse,
    SBActivityIndicatorAnimationTypeRotatingSandglass,
    SBActivityIndicatorAnimationTypeRotatingTrigons,
    SBActivityIndicatorAnimationTypeTripleRings,
    SBActivityIndicatorAnimationTypeCookieTerminator,
    SBActivityIndicatorAnimationTypeBallSpinFadeLoader
};

@interface SBActivityIndicatorView : UIView

- (id)initWithType:(SBActivityIndicatorAnimationType)type;
- (id)initWithType:(SBActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor;
- (id)initWithType:(SBActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor size:(CGFloat)size;

@property (nonatomic) SBActivityIndicatorAnimationType type;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) CGFloat size;

@property (nonatomic, readonly) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;

@end

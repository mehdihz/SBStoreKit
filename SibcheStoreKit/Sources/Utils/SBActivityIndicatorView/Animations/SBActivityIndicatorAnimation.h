//
//  SBActivityIndicatorAnimation.h
//  SBActivityIndicatorExample
//
//  Created by Danil Gontovnik on 8/10/16.
//  Copyright © 2016 Danil Gontovnik. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBActivityIndicatorAnimationProtocol.h"

@interface SBActivityIndicatorAnimation : NSObject <SBActivityIndicatorAnimationProtocol>

- (CABasicAnimation *)createBasicAnimationWithKeyPath:(NSString *)keyPath;
- (CAKeyframeAnimation *)createKeyframeAnimationWithKeyPath:(NSString *)keyPath;
- (CAAnimationGroup *)createAnimationGroup;

@end

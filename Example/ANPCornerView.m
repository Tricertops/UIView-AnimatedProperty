//
//  ANPCornerView.m
//  UIView+AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "ANPCornerView.h"
#import "AnimatedProperty.h"



@implementation ANPCornerView

@dynamic cornerRadius;

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if ( ! [UIView currentAnimation]) {
        self.layer.cornerRadius = cornerRadius;
    }
    else {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        animation.duration = [[UIView currentAnimation] duration];
        animation.timingFunction = [[UIView currentAnimation] timingFunction];
        animation.toValue = @(cornerRadius);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [self.layer addAnimation:animation forKey:@"setCornerRadius:"];
    }
}

@end

//
//  ANPCornerView.m
//  UIView+AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "ANPCornerView.h"
#import "UIView+AnimatedProperty.h"



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
        // IMPORTANT: In case of delayed animation, the animation block (and thus also this setter) is invoked immediately without the delay. This is normal behavior of UIView block animations. Because of this, your CAAnimation should be properly delayed.
        
        CABasicAnimation *animation = [[UIView currentAnimation] basicAnimationForKeypath:@"cornerRadius" toValue:@(cornerRadius)];
        [self.layer addAnimation:animation forKey:@"setCornerRadius:"];
        
        
        
        // This is how you set up the animation yourself:
        /*
         NSTimeInterval delay = [[UIView currentAnimation] delay];
         NSTimeInterval duration = [[UIView currentAnimation] duration];
         CAMediaTimingFunction *timingFunction = [[UIView currentAnimation] timingFunction];
         
         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
         animation.duration = duration + delay; // This is how CAAnimation timing works.
         animation.beginTime = CACurrentMediaTime() + delay;
         animation.timingFunction = timingFunction;
         animation.toValue = @(cornerRadius);
         animation.fillMode = kCAFillModeForwards;
         animation.removedOnCompletion = NO;
         */
    }
}

@end

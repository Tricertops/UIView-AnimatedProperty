//
//  UIView+AnimatedProperty.m
//  AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "UIView+AnimatedProperty.h"
#import <objc/message.h>



// Issue #1: If the animation block does not contain any built-in UIView animations (e.g. frame, alpha, center, …),
//           the animations are considered completed immediately and the completion bock is invoked.
// Fix   #1: Create fake view and animate its property to ensure the completion block is invoked after the delay.
#define FIX_ISSUE_1     1





@implementation UIView (AnimatedProperty)





#pragma mark - Current Animation

static ANPAnimation *_currentAnimation = nil;

+ (ANPAnimation *)currentAnimation {
    return _currentAnimation;
}

+ (void)setCurrentAnimation:(ANPAnimation *)animation {
    _currentAnimation = animation;
}





#pragma mark - Exchange Methods

+ (void)load {
    // This is special method.
    // It is called on each category and can not be overriden.
    // It is safe to implement it here without modifications to original class.
    
    // We exchange implementation of those 3 methods.
    
    [self anp_exchangeImplementationsOf:@selector(        animateWithDuration:animations:)
                                    and:@selector(anp_new_animateWithDuration:animations:)];
    
    [self anp_exchangeImplementationsOf:@selector(        animateWithDuration:animations:completion:)
                                    and:@selector(anp_new_animateWithDuration:animations:completion:)];
    
    [self anp_exchangeImplementationsOf:@selector(        animateWithDuration:delay:options:animations:completion:)
                                    and:@selector(anp_new_animateWithDuration:delay:options:animations:completion:)];
}

+ (void)anp_exchangeImplementationsOf:(SEL)originalSelector and:(SEL)modifiedSelector {
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method modifiedMethod = class_getClassMethod(self, modifiedSelector);
    method_exchangeImplementations(originalMethod, modifiedMethod);
}





#pragma mark Animation Methods

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations {
    // IMPORTANT: On runtime, this method has selector `+animateWithDuration:animations:` !!!
    // IMPORTANT: Sending the following message runs original implementation of `+animateWithDuration:animations:` !!!
    [self animateWithDuration:duration
                        delay:0
                      options:kNilOptions
                   animations:animations
                   completion:nil];
}

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations
                         completion:(void (^)(BOOL))completion {
    // IMPORTANT: On runtime, this method has selector `+animateWithDuration:animations:completion:` !!!
    // IMPORTANT: Sending the following message runs modified implementation of `+animateWithDuration:animations:completion:` !!!
    [self animateWithDuration:duration
                        delay:0
                      options:kNilOptions
                   animations:animations
                   completion:completion];
}

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay
                            options:(UIViewAnimationOptions)options
                         animations:(void (^)(void))animations
                         completion:(void (^)(BOOL))completion {
    // IMPORTANT: On runtime, this method has selector `+animateWithDuration:delay:options:animations:completion:` !!!
#if FIX_ISSUE_1
    UIView *view = [self anp_createHelperView];
#endif
    // IMPORTANT: Sending the following message runs original implementation of `+animateWithDuration:delay:options:animations:completion:` !!!
    [self anp_new_animateWithDuration:duration
                                delay:delay
                              options:options
                           animations:^{
#if FIX_ISSUE_1
                               [self anp_applyAnimationOnHelperView:view];
#endif
                               [UIView setCurrentAnimation:[[ANPAnimation alloc] initWithDuration:duration delay:delay animationOptions:options]];
                               animations();
                               [UIView setCurrentAnimation:nil];
                           }
                           completion:^(BOOL finished) {
#if FIX_ISSUE_1
                               [self anp_removeHelperView:view];
#endif
                               if (completion) completion(finished);
                           }];
}





#pragma mark - Helper View (Issue #1)

#if FIX_ISSUE_1
+ (UIView *)anp_createHelperView {
    // Create invisible view and insert it to root VC.
    UIView *view = [[UIView alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = [app.delegate window];
    [window.rootViewController.view insertSubview:view belowSubview:0];
    return view;
}

+ (void)anp_applyAnimationOnHelperView:(UIView *)view {
    view.alpha = 0.99; // Any built-in animated property
}

+ (void)anp_removeHelperView:(UIView *)view {
    [view removeFromSuperview];
}
#endif





@end





#pragma mark - Animation Object

@interface ANPAnimation ()

@property (nonatomic, readwrite, assign) NSTimeInterval delay;
@property (nonatomic, readwrite, assign) NSTimeInterval duration;
@property (nonatomic, readwrite, assign) UIViewAnimationOptions options;

@end





@implementation ANPAnimation



- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animationOptions:(UIViewAnimationOptions)options {
    self = [super init];
    if (self) {
        self.duration = duration;
        self.delay = delay;
        self.options = options;
    }
    return self;
}



- (CAMediaTimingFunction *)timingFunction {
    NSString *timingFunctionName = kCAMediaTimingFunctionDefault;
    if (self.options & UIViewAnimationOptionCurveLinear) {
        timingFunctionName = kCAMediaTimingFunctionLinear;
    }
    else if (self.options & UIViewAnimationOptionCurveEaseIn) {
        timingFunctionName = kCAMediaTimingFunctionEaseIn;
    }
    else if (self.options & UIViewAnimationOptionCurveEaseOut) {
        timingFunctionName = kCAMediaTimingFunctionEaseOut;
    }
    else if (self.options & UIViewAnimationOptionCurveEaseInOut) {
        timingFunctionName = kCAMediaTimingFunctionEaseInEaseOut;
    }
    return [CAMediaTimingFunction functionWithName:timingFunctionName];
}



- (CABasicAnimation *)basicAnimationForKeypath:(NSString *)keypath toValue:(id)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keypath];
    animation.duration = self.duration + self.delay; // This is how CAAnimation timing works.
    animation.beginTime = CACurrentMediaTime() + self.delay;
    animation.timingFunction = [self timingFunction];
    animation.toValue = toValue;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}



- (void)addBasicAnimationToLayer:(CALayer *)layer keypath:(NSString *)keypath toValue:(id)toValue {
    CABasicAnimation *animation = [self basicAnimationForKeypath:keypath toValue:toValue];
    [layer addAnimation:animation forKey:keypath]; // Key-path used as key.
}





@end





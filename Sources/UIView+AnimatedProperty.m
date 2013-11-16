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

static NSMutableArray *_currentAnimationStack = nil;

+ (ANPAnimation *)currentAnimation {
    return [_currentAnimationStack lastObject];
}

+ (void)setCurrentAnimation:(ANPAnimation *)animation {
    if ( ! _currentAnimationStack) {
        _currentAnimationStack = [[NSMutableArray alloc] initWithCapacity:2];
    }
    // `nil` animation causes the stack to be popped
    if (animation) {
        [_currentAnimationStack addObject:animation];
    }
    else {
        [_currentAnimationStack removeLastObject];
    }
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
    [window.rootViewController.view addSubview:view];
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
@property (nonatomic, readwrite, strong) CAMediaTimingFunction *timingFunction;

@end





@implementation ANPAnimation



- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animationOptions:(UIViewAnimationOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.delay = delay;
        
        if ([UIView currentAnimation]) {
            // Nested animation
            
            NSTimeInterval parentDuration = [[UIView currentAnimation] duration];
            self.duration = (self.overrideInheritedDuration
                             ? duration
                             : parentDuration);
            
            CAMediaTimingFunction *parentTimingFunction = [[UIView currentAnimation] timingFunction];
            self.timingFunction = (self.overrideInheritedCurve
                                   ? [self timingFunctionFromAnimationOptions:options]
                                   : parentTimingFunction);
        }
        else {
            // Not nested animation
            self.duration = duration;
            self.timingFunction = [self timingFunctionFromAnimationOptions:options];
        }
    }
    return self;
}



- (CAMediaTimingFunction *)timingFunctionFromAnimationOptions:(UIViewAnimationOptions)options {
    //    UIViewAnimationOptions:
    //    UIViewAnimationOptionCurveEaseInOut            = 0 << 16,
    //    UIViewAnimationOptionCurveEaseIn               = 1 << 16,
    //    UIViewAnimationOptionCurveEaseOut              = 2 << 16,
    //    UIViewAnimationOptionCurveLinear               = 3 << 16,
    
    NSString *timingFunctionName = kCAMediaTimingFunctionDefault;
    NSUInteger shiftedOptions = options >> 16;
    switch (shiftedOptions) {
        case 0: timingFunctionName = kCAMediaTimingFunctionEaseInEaseOut;   break;
        case 1: timingFunctionName = kCAMediaTimingFunctionEaseIn;          break;
        case 2: timingFunctionName = kCAMediaTimingFunctionEaseOut;         break;
        case 3: timingFunctionName = kCAMediaTimingFunctionLinear;          break;
        default: break;
    }
    return [CAMediaTimingFunction functionWithName:timingFunctionName];
}



- (BOOL)layoutSubviews              {     return (self.options & UIViewAnimationOptionLayoutSubviews            );     }
- (BOOL)allowUserInteraction        {     return (self.options & UIViewAnimationOptionAllowUserInteraction      );     }
- (BOOL)beginFromCurrentState       {     return (self.options & UIViewAnimationOptionBeginFromCurrentState     );     }
- (BOOL)repeat                      {     return (self.options & UIViewAnimationOptionRepeat                    );     }
- (BOOL)autoreverse                 {     return (self.options & UIViewAnimationOptionAutoreverse               );     }
- (BOOL)overrideInheritedDuration   {     return (self.options & UIViewAnimationOptionOverrideInheritedDuration );     }
- (BOOL)overrideInheritedCurve      {     return (self.options & UIViewAnimationOptionOverrideInheritedCurve    );     }
- (BOOL)allowAnimatedContent        {     return (self.options & UIViewAnimationOptionAllowAnimatedContent      );     }



- (void)animateLayer:(CALayer *)layer keyPath:(NSString *)keyPath toValue:(id)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    
    animation.duration = self.duration;
    animation.beginTime = CACurrentMediaTime() + self.delay;
    animation.timingFunction = self.timingFunction;
    animation.repeatCount = (self.repeat? HUGE_VALF : 0);
    animation.autoreverses = self.autoreverse;
    
    if (self.beginFromCurrentState && layer.presentationLayer) {
        id instantValue = [layer.presentationLayer valueForKeyPath:keyPath];
        [layer setValue:instantValue forKeyPath:keyPath];
    }
    animation.fromValue = [layer valueForKeyPath:keyPath];
    animation.toValue = toValue;
    animation.fillMode = kCAFillModeBoth; // Ensure, that old value is “visible” even when delayed.
    
    if ( ! self.autoreverse) {
        [layer setValue:toValue forKeyPath:keyPath];
    }
    [layer addAnimation:animation forKey:keyPath];
}



- (CABasicAnimation *)basicAnimationForKeypath:(NSString *)keypath toValue:(id)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keypath];
    
    animation.duration = self.duration;
    animation.beginTime = CACurrentMediaTime() + self.delay;
    animation.timingFunction = self.timingFunction;
    animation.repeatCount = (self.repeat? HUGE_VALF : 0);
    animation.autoreverses = self.autoreverse;
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    animation.toValue = toValue;
    return animation;
}



- (void)addBasicAnimationToLayer:(CALayer *)layer keypath:(NSString *)keypath toValue:(id)toValue {
    CABasicAnimation *animation = [self basicAnimationForKeypath:keypath toValue:toValue];
    [layer addAnimation:animation forKey:keypath]; // Key-path used as key.
}



- (NSString *)description {
    return [NSString stringWithFormat:@"<%@; %p: delay=%.2f; duration=%.2f; options=%i>", [self class], self, self->_delay, self->_duration, self->_options];
}





@end





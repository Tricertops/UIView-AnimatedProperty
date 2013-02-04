//
//  UIView+AnimatedProperty.m
//  AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "UIView+AnimatedProperty.h"
#import <objc/message.h>



@implementation UIView (AnimatedProperty)



static ANPAnimation *_currentAnimation = nil;

+ (ANPAnimation *)currentAnimation {
    return _currentAnimation;
}

+ (void)setCurrentAnimation:(ANPAnimation *)animation {
    _currentAnimation = animation;
}



+ (void)load {
    // This is special method.
    // It is called on each category and can not be overriden.
    // It is safe to implement it here without modifications to original class.
    
    // We exchange implementation of those 3 methods.
    
    SEL origSelector1 = @selector(animateWithDuration:animations:);
    SEL newSelector1 = @selector(anp_new_animateWithDuration:animations:);
    Method origMethod1 = class_getClassMethod(self, origSelector1);
    Method newMethod1 = class_getClassMethod(self, newSelector1);
    method_exchangeImplementations(origMethod1, newMethod1);
    
    SEL origSelector2 = @selector(animateWithDuration:animations:completion:);
    SEL newSelector2 = @selector(anp_new_animateWithDuration:animations:completion:);
    Method origMethod2 = class_getClassMethod(self, origSelector2);
    Method newMethod2 = class_getClassMethod(self, newSelector2);
    method_exchangeImplementations(origMethod2, newMethod2);
    
    SEL origSelector3 = @selector(animateWithDuration:delay:options:animations:completion:);
    SEL newSelector3 = @selector(anp_new_animateWithDuration:delay:options:animations:completion:);
    Method origMethod3 = class_getClassMethod(self, origSelector3);
    Method newMethod3 = class_getClassMethod(self, newSelector3);
    method_exchangeImplementations(origMethod3, newMethod3);
}

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations {
    // IMPORTANT: On runtime, this method has selector `+animateWithDuration:animations:` !!!
    // IMPORTANT: Sending the following message runs original implementation of `+animateWithDuration:animations:` !!!
    [self anp_new_animateWithDuration:duration
                           animations:^{
                               [UIView setCurrentAnimation:[[ANPAnimation alloc] initWithDuration:duration animationOptions:0]];
                               animations();
                               [UIView setCurrentAnimation:nil];
                           }];
}

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations
                         completion:(void (^)(BOOL))completion {
    // IMPORTANT: On runtime, this method has selector `+animateWithDuration:animations:completion:` !!!
    // IMPORTANT: Sending the following message runs original implementation of `+animateWithDuration:animations:completion:` !!!
    [self anp_new_animateWithDuration:duration
                           animations:^{
                               [UIView setCurrentAnimation:[[ANPAnimation alloc] initWithDuration:duration animationOptions:0]];
                               animations();
                               [UIView setCurrentAnimation:nil];
                           }
                           completion:completion];
}

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay
                            options:(UIViewAnimationOptions)options
                         animations:(void (^)(void))animations
                         completion:(void (^)(BOOL))completion {
    // IMPORTANT: On runtime, this method has selector `+animateWithDuration:delay:options:animations:completion:` !!!
    // IMPORTANT: Sending the following message runs original implementation of `+animateWithDuration:delay:options:animations:completion:` !!!
    [self anp_new_animateWithDuration:duration
                                delay:delay
                              options:options
                           animations:^{
                               [UIView setCurrentAnimation:[[ANPAnimation alloc] initWithDuration:duration animationOptions:options]];
                               animations();
                               [UIView setCurrentAnimation:nil];
                           }
                           completion:completion];
}



@end






@interface ANPAnimation ()
@property (nonatomic, readwrite, assign) NSTimeInterval duration;
@property (nonatomic, readwrite, assign) UIViewAnimationOptions options;
@end

@implementation ANPAnimation

- (id)initWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options {
    self = [super init];
    if (self) {
        self.duration = duration;
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

@end

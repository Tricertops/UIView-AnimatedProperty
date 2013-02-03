//
//  UIView+AnimatedProperty.h
//  AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ANPAnimation; // Declared below.



@interface UIView (AnimatedProperty)

+ (ANPAnimation *)currentAnimation;

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations;

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                         animations:(void (^)(void))animations
                         completion:(void (^)(BOOL))completion;

+ (void)anp_new_animateWithDuration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay
                            options:(UIViewAnimationOptions)options
                         animations:(void (^)(void))animations
                         completion:(void (^)(BOOL))completion;

@end



@interface ANPAnimation : NSObject

@property (nonatomic, readonly, assign) NSTimeInterval duration;
@property (nonatomic, readonly, assign) UIViewAnimationOptions options;

@property (nonatomic, readonly, strong) CAMediaTimingFunction *timingFunction;

- (id)initWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options;

@end

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

// Atrributes of the animation.
@property (nonatomic, readonly, assign) NSTimeInterval delay;
@property (nonatomic, readonly, assign) NSTimeInterval duration;
@property (nonatomic, readonly, assign) UIViewAnimationOptions options;

// Convenience accessors for animation options
@property (nonatomic, readonly, strong) CAMediaTimingFunction *timingFunction;
@property (nonatomic, readonly, assign) BOOL layoutSubviews;
@property (nonatomic, readonly, assign) BOOL allowUserInteraction;
@property (nonatomic, readonly, assign) BOOL beginFromCurrentState;
@property (nonatomic, readonly, assign) BOOL repeat;
@property (nonatomic, readonly, assign) BOOL autoreverse;
@property (nonatomic, readonly, assign) BOOL overrideInheritedDuration;
@property (nonatomic, readonly, assign) BOOL overrideInheritedCurve;
@property (nonatomic, readonly, assign) BOOL allowAnimatedContent;

/// Used internally to create animation representation.
- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animationOptions:(UIViewAnimationOptions)options;

/// Creates and runs key-path animation on layer aplying all current animation values.
- (void)animateLayer:(CALayer *)layer keyPath:(NSString *)keyPath toValue:(id)toValue;

/// Deprecated: Uses wrong animation fillMode and removedOnCompletion values. Use -animateLayer:keyPath:toValue: or build and add animation yourself.
- (CABasicAnimation *)basicAnimationForKeypath:(NSString *)keypath toValue:(id)toValue __deprecated;

/// Deprecated: Useless after deprecating -basicAnimationForKeypath:toValue: method. Use -animateLayer:keyPath:toValue: or build and add animation yourself.
- (void)addBasicAnimationToLayer:(CALayer *)layer keypath:(NSString *)keypath toValue:(id)toValue __deprecated;

@end

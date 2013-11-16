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

//TODO: +performWithoutAnimations:
//TODO: +animateKeyframesWithDuration:delay:options:animations:completion:
//TODO: +animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:

@end



@interface ANPAnimation : NSObject

/// Animation delay as passed to UIView animation method. Delay is only applied for visual changes and all new values are appiled instantly.
@property (nonatomic, readonly, assign) NSTimeInterval delay;
/// Duration of animated change as passed to UIView animation method.
@property (nonatomic, readonly, assign) NSTimeInterval duration;
/// Options used for this animation as passed to UIView animation method.
@property (nonatomic, readonly, assign) UIViewAnimationOptions options;

/// Media timing function as extracted from animation options. Can be used with CAAnimations.
@property (nonatomic, readonly, strong) CAMediaTimingFunction *timingFunction;
/// Lay out subviews at commit time so that they are animated along with their parent.
@property (nonatomic, readonly, assign) BOOL layoutSubviews;
/// Allow the user to interact with views while they are being animated.
@property (nonatomic, readonly, assign) BOOL allowUserInteraction;
/// Start the animation from the current setting associated with an already in-flight animation. If this key is not present, any in-flight animations are allowed to finish before the new animation is started. If another animation is not in flight, this key has no effect.
@property (nonatomic, readonly, assign) BOOL beginFromCurrentState;
/// Repeat the animation indefinitely. Should be combined with `autoreverse` option.
@property (nonatomic, readonly, assign) BOOL repeat;
/// Run the animation backwards and forwards.
@property (nonatomic, readonly, assign) BOOL autoreverse;
/// Force the animation to use the original duration value specified when the animation was submitted. If this key is not present, the animation inherits the remaining duration of the in-flight animation, if any.
@property (nonatomic, readonly, assign) BOOL overrideInheritedDuration;
/// Force the animation to use the original curve value specified when the animation was submitted. If this key is not present, the animation inherits the curve of the in-flight animation, if any.
@property (nonatomic, readonly, assign) BOOL overrideInheritedCurve;
/// Animate the views by changing the property values dynamically and redrawing the view. If this key is not present, the views are animated using a snapshot image.
@property (nonatomic, readonly, assign) BOOL allowAnimatedContent;

//TODO: Apply UIViewAnimationOptionOverrideInheritedOptions

/// Used internally to create animation representation.
- (id)initWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animationOptions:(UIViewAnimationOptions)options;

/// Creates and runs key-path animation on layer aplying all current animation values.
- (void)animateLayer:(CALayer *)layer keyPath:(NSString *)keyPath toValue:(id)toValue;

/// Deprecated: Uses wrong animation fillMode and removedOnCompletion values. Use -animateLayer:keyPath:toValue: or build and add animation yourself.
- (CABasicAnimation *)basicAnimationForKeypath:(NSString *)keypath toValue:(id)toValue __deprecated;

/// Deprecated: Useless after deprecating -basicAnimationForKeypath:toValue: method. Use -animateLayer:keyPath:toValue: or build and add animation yourself.
- (void)addBasicAnimationToLayer:(CALayer *)layer keypath:(NSString *)keypath toValue:(id)toValue __deprecated;

@end

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
    if ([UIView currentAnimation]) {
        [[UIView currentAnimation] animateLayer:self.layer keyPath:@"cornerRadius" toValue:@(cornerRadius)];
    }
    else {
        self.layer.cornerRadius = cornerRadius;
    }
}

@end

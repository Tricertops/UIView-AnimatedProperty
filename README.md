# UIView+AnimatedProperty

This **extension** to `UIView` block animations allows you to implement **your own animated properties** of `UIView` subclasses.

The main part is category on `UIView` that swizzles animation methods to extend them. Extemded methods store **duration and options** of the current animation to globally accessible variable (via accessor `+currentAnimation`). Then in setter of your animated property you check whether you are called in context of animation block and can alter the behavior (usually by running `CAAnimation`).



## Example

Your `UIView` subclass with **custom animated property**:

```
@implementation ANPCornerView

@dynamic cornerRadius;

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    // Check for existence
    if ( ! [UIView currentAnimation]) {
        self.layer.cornerRadius = cornerRadius;
    }
    else {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        
        // You can access duration and timing function is created for you from options
        animation.duration = [[UIView currentAnimation] duration];
        animation.timingFunction = [[UIView currentAnimation] timingFunction];
        
        animation.toValue = @(cornerRadius);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [self.layer addAnimation:animation forKey:@"setCornerRadius:"];
    }
}
```

This is **how you use** it:

```
[UIView animateWithDuration:5 animations:^{
    myView.cornerRadius = 50;
}];
```

---
_Version 0.1.0_

MIT License, Copyright © 2013 Martin Kiss

`THE SOFTWARE IS PROVIDED "AS IS", and so on...`

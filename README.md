# UIView+AnimatedProperty

This **extension** to `UIView` block animations allows you to implement **your own animated properties** of `UIView` subclasses.

The main part is category on `UIView` that swizzles animation methods to extend them. Extended methods store **duration, delay and options** of the current animation to globally accessible variable (via accessor `+currentAnimation`). Then in setter of your animated property you check whether you are called in context of animation block and can alter the behavior (usually by running `CAAnimation`).

In addition, it supports **nested animations** with proper overriding of inherited duration and curve. Also it provides easy contructor for `CABasicAnimation` and accessors for animation options.



## Example

Your `UIView` subclass with **custom animated property**:

```objective-c
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
```

This is **how you use** it:

```objective-c
[UIView animateWithDuration:5 animations:^{
    myView.cornerRadius = 50;
}];
```

For more detailed example, see the project.

---
_Version 0.4.0_

[MIT License](LICENSE.md), Copyright © 2013 Martin Kiss

`THE SOFTWARE IS PROVIDED "AS IS", and so on...`

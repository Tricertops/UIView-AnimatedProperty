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
        CABasicAnimation *animation = [[UIView currentAnimation] basicAnimationForKeypath:@"cornerRadius" toValue:@(cornerRadius)];
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

For more detailed example, see the project.

---
_Version 0.2.0_

MIT License, Copyright © 2013 Martin Kiss

`THE SOFTWARE IS PROVIDED "AS IS", and so on...`

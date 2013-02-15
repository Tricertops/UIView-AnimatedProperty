//
//  ANPViewController.m
//  UIView+AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "ANPViewController.h"
#import "ANPCornerView.h"



@implementation ANPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    ANPCornerView *cornerView = [[ANPCornerView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    cornerView.backgroundColor = [UIColor blackColor];
    cornerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.view addSubview:cornerView];
    
    [UIView
     animateWithDuration:5
     delay:0
     options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
         NSLog(@"start animation");
         cornerView.cornerRadius = 50;
     }completion:^(BOOL finished){
         NSLog(@"animation completed. (This message shoud appear after 5 sec.)");
         cornerView.backgroundColor = [UIColor redColor];
     }];
}

@end

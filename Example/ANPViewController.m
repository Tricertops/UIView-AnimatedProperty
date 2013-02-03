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
    
    [UIView animateWithDuration:5 animations:^{
        cornerView.cornerRadius = 50;
    }];
}

@end

//
//  ANPAppDelegate.m
//  UIView+AnimatedProperty
//
//  Created by Martin Kiss on 3.2.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "ANPAppDelegate.h"
#import "ANPViewController.h"



@implementation ANPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[ANPViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

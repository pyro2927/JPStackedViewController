//
//  JPAppDelegate.m
//  Stacked
//
//  Created by Joseph Pintozzi on 11/23/12.
//  Copyright (c) 2012 TinyDragon Apps. All rights reserved.
//

#import "JPAppDelegate.h"
#import "JPStackedViewController.h"

@implementation JPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UIViewController *vc = [[UIViewController alloc] init];
    [vc.view setBackgroundColor:[UIColor greenColor]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController *vc2 = [[UIViewController alloc] init];
    [vc2.view setBackgroundColor:[UIColor redColor]];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    [nav2.navigationBar setTintColor:[UIColor blackColor]];
    
    UIViewController *vc3 = [[UIViewController alloc] init];
    [vc3.view setBackgroundColor:[UIColor yellowColor]];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    [nav3.navigationBar setTintColor:[UIColor orangeColor]];

    UIViewController *vc4 = [[UIViewController alloc] init];
    [vc4.view setBackgroundColor:[UIColor blueColor]];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    [nav4.navigationBar setTintColor:[UIColor greenColor]];
    
    //add in toggle button
    [vc.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(toggle)]];
    
    JPStackedViewController *stacky = [[JPStackedViewController alloc] initWithViewControllers:[NSArray arrayWithObjects:nav, nav2, nav3, nav4, nil]];
    [stacky setStyle:JPSTYLE_TOUCH_NAV_ONLY | /* JPSTYLE_COMPRESS_VIEWS | */ JPSTYLE_VIEW_HOP];
    self.window.rootViewController = stacky;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)toggle{
    [(JPStackedViewController*)self.window.rootViewController toggleViewAtIndex:0];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

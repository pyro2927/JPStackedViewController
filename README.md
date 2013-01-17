## JPStackedViewController

Stack multiple view controllers that can be moved around.  Both Swiping and panning gestures work (only left/right).

## Customizing
There are a few things you can do to tweak how JPStackedViewController acts.  If you want each view to "dock" to the left/right, call

	[stacky setSnapsToSides:YES];
	
JPStackedViewController also supports interaction styles.  Currently there are only two `JPSTYLE_TOUCH_VIEW_ANYWHERE` and `JPSTYLE_TOUCH_NAV_ONLY`.  If you call  
	
	[stacky setStyle:JPSTYLE_TOUCH_NAV_ONLY];
	
the views will only be able to be adjusted when you tap and drag on a UINavigationBar. **Note: if you set this style and don't use UINavigationControllers, your users won't be able to reveal the views in the back.**
    

## Example Code

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
    
    JPStackedViewController *stacky = [[JPStackedViewController alloc] initWithViewControllers:[NSArray arrayWithObjects:nav, nav2, nav3, nav4, nil]];
    
    self.window.rootViewController = stacky;

## Picture

![](https://raw.github.com/pyro2927/JPStackedViewController/master/stacked.gif)
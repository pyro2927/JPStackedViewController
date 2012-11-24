## JPStackedViewController

Stack multiple view controllers that can be moved around.  Both Swiping and panning gestures work (only left/right).

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
# JPStackedViewController
Stack multiple view controllers that can be moved around.  Both Swiping and panning gestures work (only left/right).

## Customizing/Styling
JPStackedViewController can have different styles/effects added to it via bitflags.  Below is a (hopefully) up to date listing of what is available.  You can set style flags like

	[stacky setStyle:JPSTYLE_TOUCH_NAV_ONLY | JPSTYLE_COMPRESS_VIEWS | JPSTYLE_VIEW_HOP];

#### JPSTYLE_TOUCH_VIEW_ANYWHERE
This is the default (`0`) style.  Views can be adjusted by tapping and sliding anywhere on them. (shown in the gif below)

#### JPSTYLE_TOUCH_NAV_ONLY
Views will only be able to be adjusted when you tap and drag on a UINavigationBar. **Note: if you set this style and don't use UINavigationControllers, your users won't be able to reveal the views in the back.**

#### JPSTYLE_VIEW_HOP
Views will "hop" when the far left side is tapped, similar to the iOS camera being accessed from the lock screen.

#### JPSTYLE_IGNORE_BUTTONS
Gestures will be ignored when the are performed on top of UIButtons.

#### JPSTYLE_COMPRESS_VIEWS
When views are stacked on the righthand side of the screen, they will be compressed so their their combined visible space will be what one view to the right would be.
    
#### JPSTYLE_SNAPS_TO_SIDES
When a view is released, it (and the others) will nap to the left/right side of the screen, depending on what is closer.

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

## Pictures
In action:

![](https://raw.github.com/pyro2927/JPStackedViewController/master/stacked.gif)

Compressed:

![](https://raw.github.com/pyro2927/JPStackedViewController/master/compressed.png)

Comressed & Snap to Side:

![](https://raw.github.com/pyro2927/JPStackedViewController/master/styles.gif)
//
//  JPStackedViewController.h
//  Stacked
//
//  Created by Joseph Pintozzi on 11/23/12.
//  Copyright (c) 2012 TinyDragon Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JPSTYLE_TOUCH_VIEW_ANYWHERE = 0,
    JPSTYLE_TOUCH_NAV_ONLY = 1 << 1,
    JPSTYLE_VIEW_HOP = 1 << 2,
    JPSTYLE_IGNORE_BUTTONS = 1 << 3,
    JPSTYLE_COMPRESS_VIEWS = 1 << 4
} JPSTYLE_TYPE;

@interface JPStackedViewController : UIViewController<UIGestureRecognizerDelegate>{
    NSMutableArray *stackedViews;
    CGFloat firstX;
    NSDate *swipeGestureEndedTime;
    UISwipeGestureRecognizerDirection swipeDirection;
    int style;
}

@property int style;

- (id)initWithViewControllers:(NSArray*)viewControllers;
- (void)openToIndex:(int)viewIndex;
- (void)toggleViewAtIndex:(int)indexToToggle;

@end

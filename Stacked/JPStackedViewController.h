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
    JPSTYLE_TOUCH_NAV_ONLY,
    JPSTYLE_VIEW_HOP,
    JPSTYLE_IGNORE_BUTTONS,
    JPSTYLE_COMPRESS_VIEWS
} JPSTYLE_TYPE;

@interface JPStackedViewController : UIViewController<UIGestureRecognizerDelegate>{
    NSMutableArray *stackedViews;
    CGFloat firstX;
    NSDate *swipeGestureEndedTime;
    UISwipeGestureRecognizerDirection swipeDirection;
    bool snapsToSides;
    int style;
}

@property bool snapsToSides;
@property int style;

- (id)initWithViewControllers:(NSArray*)viewControllers;
- (void)openToIndex:(int)viewIndex;

@end

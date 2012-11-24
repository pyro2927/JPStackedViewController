//
//  JPStackedViewController.m
//  Stacked
//
//  Created by Joseph Pintozzi on 11/23/12.
//  Copyright (c) 2012 TinyDragon Apps. All rights reserved.
//

#import "JPStackedViewController.h"
#define kMinWidth       50
#define kSwipeMarginTime    0.1f
@interface JPStackedViewController ()

@end

@implementation JPStackedViewController

-(void)shiftViewToTheRight:(UIView*)view xOffset:(CGFloat)x{
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
    for (int i = [stackedViews indexOfObject:view] - 1; i >= 0; i--) {
        UIView *subView = [stackedViews objectAtIndex:i];
        x+= kMinWidth;
        if (subView.frame.origin.x < x) {
            subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
        }
        x = subView.frame.origin.x;
    }
}

-(void)shiftViewToTheLeft:(UIView*)view xOffset:(CGFloat)x{
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
    for (int i = [stackedViews indexOfObject:view] + 1; i < [stackedViews count]; i++) {
        UIView *subView = [stackedViews objectAtIndex:i];
        x = MAX(x - kMinWidth, 0);
        if (subView.frame.origin.x > x) {
            subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
        }
    }
}

-(void)panning:(UIPanGestureRecognizer*)sender{
    CGPoint translatedPoint = [sender translationInView:self.view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        firstX = translatedPoint.x;
        panGestureStarted = YES;
    } else if ([sender state] == UIGestureRecognizerStateCancelled || [sender state] == UIGestureRecognizerStateEnded) {
        panGestureStarted = NO;
//        see if we end this shortly after our swipe gesture
        if (swipeGestureEndedTime && [[NSDate date] timeIntervalSinceDate:swipeGestureEndedTime] <= kSwipeMarginTime) {
            if (swipeDirection == UISwipeGestureRecognizerDirectionRight) {
                int layer = [stackedViews indexOfObject:sender.view] + 1;
                CGFloat xOffset = self.view.frame.size.width - layer * kMinWidth;
                [UIView animateWithDuration:0.2f animations:^{
                    [self shiftViewToTheRight:sender.view xOffset:xOffset];
                }];
            } else {
//                swipe left!
                [UIView animateWithDuration:0.2f animations:^{
                    [self shiftViewToTheLeft:sender.view xOffset:0];
                }];
            }
        }
    } else{
        CGRect origFrame = sender.view.frame;
        int layer = [stackedViews indexOfObject:sender.view] + 1;
        CGFloat xOffset = MAX(0, MIN(origFrame.origin.x + translatedPoint.x - firstX, self.view.frame.size.width - layer * kMinWidth));
//        adjust all other views
        if (translatedPoint.x - firstX > 0) {
//            we are shifting to the right
            [self shiftViewToTheRight:sender.view xOffset:xOffset];
        } else {
//            we are moving to the left
            [self shiftViewToTheLeft:sender.view xOffset:xOffset];
        }
        firstX = translatedPoint.x;
    }
}

-(void)swiping:(UISwipeGestureRecognizer*)sender{
    swipeDirection = sender.direction;
    swipeGestureEndedTime = [NSDate date];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (id)initWithViewControllers:(NSArray*)viewControllers{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blueColor];
        stackedViews = [[NSMutableArray alloc] initWithCapacity:[viewControllers count]];
        for (UIViewController *vc in viewControllers) {
            [self.view addSubview:vc.view];
            [self.view sendSubviewToBack:vc.view];
            vc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//            don't allow our last object to be panned
            if (vc != [viewControllers lastObject]) {
                UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
                [panner setDelegate:self];
                [vc.view addGestureRecognizer:panner];
                UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
                [swiper setDelegate:self];
                [swiper setDirection:UISwipeGestureRecognizerDirectionRight];
                [vc.view addGestureRecognizer:swiper];
//                left swiper
                swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
                [swiper setDelegate:self];
                [swiper setDirection:UISwipeGestureRecognizerDirectionLeft];
                [vc.view addGestureRecognizer:swiper];
            }
            [stackedViews addObject:vc.view];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

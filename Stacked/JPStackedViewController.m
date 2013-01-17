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
@synthesize snapsToSides;
@synthesize style;

-(void)shiftViewToTheRight:(UIView*)view xOffset:(CGFloat)x{
    int layer = view.tag;
    view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
    for (int i = layer - 1; i >= 0; i--) {
        UIViewController *vc = [stackedViews objectAtIndex:i];
        UIView *subView = vc.view;
        x+= kMinWidth;
        if (subView.frame.origin.x < x) {
            subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
        }
        x = subView.frame.origin.x;
    }
}

-(void)shiftViewToTheLeft:(UIView*)view xOffset:(CGFloat)x{
    int layer = view.tag;
    view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
    for (int i = layer + 1; i < [stackedViews count]; i++) {
        UIViewController *vc = [stackedViews objectAtIndex:i];
        UIView *subView = vc.view;
        x = MAX(x - kMinWidth, 0);
        if (subView.frame.origin.x > x) {
            subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
        }
    }
}

-(void)panning:(UIPanGestureRecognizer*)sender{
    CGPoint translatedPoint = [sender translationInView:self.view];
    int layer = sender.view.tag;
    UIView *view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        firstX = translatedPoint.x;
    } else if ([sender state] == UIGestureRecognizerStateCancelled || [sender state] == UIGestureRecognizerStateEnded) {
        CGFloat xOffset = self.view.frame.size.width - (layer + 1) * kMinWidth;
//        see if we end this shortly after our swipe gesture
        if ( (swipeGestureEndedTime && [[NSDate date] timeIntervalSinceDate:swipeGestureEndedTime] <= kSwipeMarginTime) || snapsToSides) {
            bool goRight = NO;
            if (swipeGestureEndedTime && [[NSDate date] timeIntervalSinceDate:swipeGestureEndedTime] <= kSwipeMarginTime) {
                goRight = (swipeDirection == UISwipeGestureRecognizerDirectionRight);
            } else {
                CGFloat currentX = view.frame.origin.x;
                goRight = (currentX > xOffset - currentX);
            }
//            go right or left
            if (goRight) {
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
    } else {
        CGRect origFrame = view.frame;
        CGFloat xOffset = MAX(0, MIN(origFrame.origin.x + translatedPoint.x - firstX, self.view.frame.size.width - ((layer + 1) * kMinWidth) ));
//        adjust all other views
        if (translatedPoint.x - firstX > 0) {
//            we are shifting to the right
            [self shiftViewToTheRight:view xOffset:xOffset];
        } else {
//            we are moving to the left
            [self shiftViewToTheLeft:view xOffset:xOffset];
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
        stackedViews = [[NSMutableArray alloc] initWithArray:viewControllers];
        for (UIViewController *vc in viewControllers) {
            [self.view addSubview:vc.view];
            [self.view sendSubviewToBack:vc.view];
            vc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            vc.view.tag = [viewControllers indexOfObject:vc];
            if ([vc isKindOfClass:[UINavigationController class]]) {
                ((UINavigationController*)vc).navigationBar.tag = vc.view.tag;
            }
        }
        
        self.snapsToSides = NO;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for (UIViewController *vc in stackedViews) {
//        remove existing gesture recognizers
        for (UIGestureRecognizer * g in [vc.view gestureRecognizers]) {
            [vc.view removeGestureRecognizer:g];
        }
        if (vc != [stackedViews lastObject]) {
            //                panner
            UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
            [panner setDelegate:self];
            
            //                right swiper
            UISwipeGestureRecognizer *swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
            [swiper setDelegate:self];
            [swiper setDirection:UISwipeGestureRecognizerDirectionRight];
            
            //                left swiper
            UISwipeGestureRecognizer* leftswiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiping:)];
            [leftswiper setDelegate:self];
            [leftswiper setDirection:UISwipeGestureRecognizerDirectionLeft];
            
            if (style & JPSTYLE_TOUCH_NAV_ONLY){
                if ([vc isKindOfClass:[UINavigationController class]]) {
                    [((UINavigationController*)vc).navigationBar addGestureRecognizer:panner];
                    [((UINavigationController*)vc).navigationBar addGestureRecognizer:swiper];
                    [((UINavigationController*)vc).navigationBar addGestureRecognizer:leftswiper];
                }
            } else {
                [vc.view addGestureRecognizer:panner];
                [vc.view addGestureRecognizer:swiper];
                [vc.view addGestureRecognizer:leftswiper];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

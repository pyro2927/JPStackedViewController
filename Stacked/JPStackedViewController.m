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
#define kAnimationDuration  0.2f
#define kHopWidth           44

@interface JPStackedViewController ()

@end

@implementation JPStackedViewController
@synthesize style;

//slide our views to show the one with the passed index
-(void)openToIndex:(int)viewIndex{
    CGFloat width = self.view.frame.size.width;
    UIView *view = [(UIViewController*)[stackedViews objectAtIndex:viewIndex] view];
    __block int outerIndex = viewIndex;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self shiftViewToTheLeft:view xOffset:0];
        if (viewIndex > 0) {
            CGFloat xOffset = width - outerIndex-- * kMinWidth;
            UIView *view2 = [(UIViewController*)[stackedViews objectAtIndex:outerIndex] view];
            [self shiftViewToTheRight:view2 xOffset:xOffset];
        }
    }];
}

-(void)shiftViewToTheRight:(UIView*)view xOffset:(CGFloat)x{
    int layer = view.tag;
    view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
//    loop over views that are to the right of this one
    /*
    for (int i = layer - 1; i >= 0; i--) {
        UIViewController *vc = [stackedViews objectAtIndex:i];
        UIView *subView = vc.view;
//        calculate how much space is to our right, divide by the number of layers visible, use that as spacing
        x+= (style & JPSTYLE_COMPRESS_VIEWS ? MIN((self.view.frame.size.width - view.frame.origin.x)/(layer + 1), kMinWidth) : kMinWidth);
        if (subView.frame.origin.x < x) {
            subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
        }
    }*/
}

-(void)shiftViewToTheLeft:(UIView*)view xOffset:(CGFloat)x{
    int layer = view.tag;
    view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
    /*
    for (int i = layer + 1; i < [stackedViews count]; i++) {
        UIViewController *vc = [stackedViews objectAtIndex:i];
        UIView *subView = vc.view;
//        adjusting by compressed spacing if we can, otherwise use our min width as a space
        int nextX = x - MIN(kMinWidth, (self.view.frame.size.width - x) / ((float)layer + 1) );
        x = MAX(nextX, 0);
        if (subView.frame.origin.x > x) {
            subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
        }
    }
    
//        check to see if we need to decompress views to our right
    if (style & JPSTYLE_COMPRESS_VIEWS) {
        for (float i = layer - 1; i >= 0; i--) {
            UIViewController *vc = [stackedViews objectAtIndex:i];
            UIView *subView = vc.view;
            //        calculate how much space is to our right, divide by the number of layers visible, use that as spacing
            CGFloat spaceToTheRight = (self.view.frame.size.width - view.frame.origin.x);
            CGFloat decompress = self.view.frame.size.width - ((spaceToTheRight/((float)layer + 1)) * ((float)i + 1));
            CGFloat minWidth = self.view.frame.size.width - ((kMinWidth / (float)layer) * ((float)i + 1));
            x = MAX(decompress, minWidth);
            if (subView.frame.origin.x > x) {
                subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
            }
        }
    }*/
}

-(void)panning:(UIPanGestureRecognizer*)sender{
    CGPoint translatedPoint = [sender translationInView:self.view];
    __block int layer = sender.view.tag;
    UIView *view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        firstX = translatedPoint.x;
    } else if ([sender state] == UIGestureRecognizerStateCancelled || [sender state] == UIGestureRecognizerStateEnded) {
        CGFloat xOffset = self.view.frame.size.width - kMinWidth * (style & JPSTYLE_COMPRESS_VIEWS ? 1 : (layer + 1));
//        see if we end this shortly after our swipe gesture
        if ( (swipeGestureEndedTime && [[NSDate date] timeIntervalSinceDate:swipeGestureEndedTime] <= kSwipeMarginTime) || (style & JPSTYLE_SNAPS_TO_SIDES)) {
            bool goRight = NO;
            if (swipeGestureEndedTime && [[NSDate date] timeIntervalSinceDate:swipeGestureEndedTime] <= kSwipeMarginTime) {
                goRight = (swipeDirection == UISwipeGestureRecognizerDirectionRight);
            } else {
                CGFloat currentX = view.frame.origin.x;
                goRight = (currentX > xOffset - currentX);
            }
//            go right or left
            if (goRight) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    [self shiftViewToTheRight:view xOffset:xOffset];
                    UIView *leftview = [(UIViewController*)[stackedViews objectAtIndex:layer+1] view];
                    [self shiftViewToTheLeft:leftview xOffset:0];
                }];
            } else {
//                swipe left!
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    [self shiftViewToTheLeft:view xOffset:0];
                }];
            }
        }
    } else {
        CGRect origFrame = view.frame;
        CGFloat adjustedX = origFrame.origin.x + translatedPoint.x - firstX;
        CGFloat maxRight = MAX(origFrame.origin.x, self.view.frame.size.width - kMinWidth * (style & JPSTYLE_COMPRESS_VIEWS ? 1 : (layer + 1)));
        CGFloat xOffset = MAX(0, MIN(maxRight, adjustedX));
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
//    store our swiping direction since the UIPanGestureRecognizer seems to override
    swipeDirection = sender.direction;
    swipeGestureEndedTime = [NSDate date];
}

-(void)shiftView:(UIView*)view byDelta:(int)delta{
    int x = delta + view.frame.origin.x;
    if (delta > 0) {
        [self shiftViewToTheRight:view xOffset:x];
    } else {
        [self shiftViewToTheLeft:view xOffset:x];
    }
}

-(void)hop:(UITapGestureRecognizer*)tapper{
    CGPoint translatedPoint = [tapper locationInView:tapper.view];
    if (translatedPoint.x > 50) {
        return;
    }
    int layer = tapper.view.tag;
    __block UIView *view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    __block CGRect frame = view.frame;
    __block int mod = (frame.origin.x == 0 ? 1 : -1 );
//    slide out
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self shiftView:view byDelta:kHopWidth * mod];
    } completion:^(BOOL finished) {
//        now slide back in
        [UIView animateWithDuration:0.15f delay:0.05f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self shiftView:view byDelta:kHopWidth * mod * -1];
        } completion:^(BOOL finished) {
//            now we have a baby hop
            [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self shiftView:view byDelta:kHopWidth/3 * mod];
            } completion:^(BOOL finished) {
                //        now slide back in for the final time
                [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self shiftView:view byDelta:kHopWidth/3 * mod * -1];
                } completion:nil];
            }];
        }];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the button.
    if ([touch.view isKindOfClass:[UIButton class]] && (style & JPSTYLE_IGNORE_BUTTONS)) {
        return NO;
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
    CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
    NSLog(@"View %i's frame changed to x: %f", [object tag], newFrame.origin.x);
    int layer = [object tag];
    int x = newFrame.origin.x;
    
//    if we are moving to the left (negative delta), we are actually going UP our layer arra
    int direction = (newFrame.origin.x - oldFrame.origin.x >= 0 ? 1 : -1 );
    
    for (int i = layer - direction; 0 <= i && i < [stackedViews count] - 1; i -= direction) {
        UIViewController *vc = [stackedViews objectAtIndex:i];
        UIView *subView = vc.view;
        
//        adjusting by compressed spacing if we can, otherwise use our min width as a space
//        direction > 0 means we are moving RIGHT
        if (direction > 0) {
//        calculate how much space is to our right, divide by the number of layers visible, use that as spacing
            x+= (style & JPSTYLE_COMPRESS_VIEWS ? MIN((self.view.frame.size.width - newFrame.origin.x)/(layer + 1), kMinWidth) : kMinWidth);
            if (subView.frame.origin.x < x) {
                subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
            }
//            else we are moving LEFT
        } else {
//        adjusting by compressed spacing if we can, otherwise use our min width as a space
            int nextX = x - MIN(kMinWidth, (self.view.frame.size.width - x) / ((float)layer + 1) );
            x = MAX(nextX, 0);
            if (subView.frame.origin.x > x) {
                subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
            }
        }
    }
    
//    if we are doing compression, we also want to traverse our layer list the other way
    if (style & JPSTYLE_COMPRESS_VIEWS) {
        for (int i = layer + direction; 0 <= i && i < [stackedViews count] - 1; i += direction) {
            UIViewController *vc = [stackedViews objectAtIndex:i];
            UIView *subView = vc.view;
            //        calculate how much space is to our right, divide by the number of layers visible, use that as spacing
            CGFloat spaceToTheRight = (self.view.frame.size.width - newFrame.origin.x);
            CGFloat decompress = self.view.frame.size.width - ((spaceToTheRight/((float)layer + 1)) * ((float)i + 1));
            CGFloat minWidth = self.view.frame.size.width - ((kMinWidth / (float)layer) * ((float)i + 1));
            x = MAX(decompress, minWidth);
            if (subView.frame.origin.x > x) {
                subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
            }
        }
    }
}

- (id)initWithViewControllers:(NSArray*)viewControllers{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blueColor];
        stackedViews = [[NSMutableArray alloc] initWithArray:viewControllers];
        for (UIViewController *vc in viewControllers) {
            [vc.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            [self.view addSubview:vc.view];
            [self.view sendSubviewToBack:vc.view];
            vc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            vc.view.tag = [viewControllers indexOfObject:vc];
            if ([vc isKindOfClass:[UINavigationController class]]) {
                ((UINavigationController*)vc).navigationBar.tag = vc.view.tag;
            }
        }
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
            
//            see if we should only allow them to touch our nav
            if (style & JPSTYLE_TOUCH_NAV_ONLY){
                if ([vc isKindOfClass:[UINavigationController class]]) {
                    [((UINavigationController*)vc).navigationBar addGestureRecognizer:panner];
                    [((UINavigationController*)vc).navigationBar addGestureRecognizer:swiper];
                    [((UINavigationController*)vc).navigationBar addGestureRecognizer:leftswiper];
//                    see if the hop animation should be added
                    if (style & JPSTYLE_VIEW_HOP) {
                        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hop:)];
                        [((UINavigationController*)vc).navigationBar addGestureRecognizer:tapper];
                    }
                }
            } else {
                [vc.view addGestureRecognizer:panner];
                [vc.view addGestureRecognizer:swiper];
                [vc.view addGestureRecognizer:leftswiper];
                if (style & JPSTYLE_VIEW_HOP) {
                    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hop:)];
                    [vc.view addGestureRecognizer:tapper];
                }
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

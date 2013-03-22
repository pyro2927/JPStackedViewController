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
    //calculate maxLeft
    int maxLeft = kMinWidth - kMinWidth * (outerIndex - 1);
    if (outerIndex == 0) {
        maxLeft = 0;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self setView:view xOffset:MAX(maxLeft, 0)];
        if (viewIndex > 0) {
            CGFloat xOffset = width - outerIndex-- * kMinWidth;
            UIView *view2 = [(UIViewController*)[stackedViews objectAtIndex:outerIndex] view];
            [self setView:view2 xOffset:xOffset];
        }
    }];
}

-(void)setView:(UIView *)view xOffset:(CGFloat)x{
    CGRect origFrame = view.frame;
    view.frame = CGRectMake(x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
}

-(void)panning:(UIPanGestureRecognizer*)sender{
    CGPoint translatedPoint = [sender translationInView:self.view];
    __block int layer = sender.view.tag;
    UIView *view = [(UIViewController*)[stackedViews objectAtIndex:layer] view];
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
        firstX = translatedPoint.x;
    } else {
        //check on our min/max limits
        CGRect origFrame = view.frame;
        CGFloat adjustedX = origFrame.origin.x + translatedPoint.x - firstX;
        CGFloat maxRight = self.view.frame.size.width - kMinWidth * (layer + 1);
        CGFloat xOffset = MAX(0, MIN(MAX(origFrame.origin.x, maxRight), adjustedX));
        //see if we're done moving
        if ([sender state] == UIGestureRecognizerStateCancelled || [sender state] == UIGestureRecognizerStateEnded) {
            //done moving, snap to a side
            bool goLeft = origFrame.origin.x <= self.view.frame.size.width / 2;
            [self openToIndex:layer + (goLeft ? 0 : 1 )];
        } else {
            //still moving
            [self setView:view xOffset:xOffset];
            firstX = translatedPoint.x;
        }
    }
}
-(void)swiping:(UISwipeGestureRecognizer*)sender{
//    store our swiping direction since the UIPanGestureRecognizer seems to override
    swipeDirection = sender.direction;
    swipeGestureEndedTime = [NSDate date];
}

-(void)shiftView:(UIView*)view byDelta:(int)delta{
    int x = delta + view.frame.origin.x;
    [self setView:view xOffset:x];
}

//method to hop a view
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
    
    //if we are moving to the left (negative delta), we are actually going UP our layer arra
    bool goingLeft = newFrame.origin.x < oldFrame.origin.x;
    //we only need to move the controllers immediatly to the left/right
    // - 2 so we don't move the very bottom view
    if (layer < [stackedViews count] - 2) {
        //we need to move the layer below us
        UIViewController *belowController = [stackedViews objectAtIndex:layer + 1];
        int belowX = belowController.view.frame.origin.x;
        int currentSpacing = x - belowX;
        if (goingLeft) {
            currentSpacing = MAX(kMinWidth, currentSpacing);
        }
        int spacer = MIN( MAX(0, currentSpacing ), self.view.frame.size.width - kMinWidth  * 2);
        //don't move it if we don't need to
        if (belowX != MAX(x - spacer, 0)) {
            //max with 0 to make sure we can't go past 0 on the left
            [self setView:belowController.view xOffset:MAX(x - spacer, 0)];
        }
    }
    
    if (layer > 0) {
        //we MIGHT need to move the layer above us!
        UIViewController *aboveController = [stackedViews objectAtIndex:layer - 1];
        int aboveX = aboveController.view.frame.origin.x;
        //if we are sliding left, don't enforce a minimum width of kMinWidth
        int spacer = MIN( MAX( (goingLeft ? 0 : kMinWidth) , aboveX - x), self.view.frame.size.width - kMinWidth  * 2);
        //don't move it if we don't need to
        if (aboveX != x + spacer) {
            [self setView:aboveController.view xOffset:x + spacer];
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
            
            if ([vc isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController*)vc).navigationBar addGestureRecognizer:panner];
                [((UINavigationController*)vc).navigationBar addGestureRecognizer:swiper];
                [((UINavigationController*)vc).navigationBar addGestureRecognizer:leftswiper];
            }
        }
        //add our KVOs after view load
        [vc.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  JPStackedViewController.m
//  Stacked
//
//  Created by Joseph Pintozzi on 11/23/12.
//  Copyright (c) 2012 TinyDragon Apps. All rights reserved.
//

#import "JPStackedViewController.h"
#define kMinWidth       50

@interface JPStackedViewController ()

@end

@implementation JPStackedViewController

-(void)panning:(UIPanGestureRecognizer*)sender{
    CGPoint translatedPoint = [sender translationInView:self.view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        firstX = translatedPoint.x;
    } else {
        CGRect origFrame = sender.view.frame;
        int layer = [stackedViews indexOfObject:sender.view] + 1;
        CGFloat xOffset = MAX(0, MIN(origFrame.origin.x + translatedPoint.x - firstX, self.view.frame.size.width - layer * kMinWidth));
        sender.view.frame = CGRectMake(xOffset, origFrame.origin.y, origFrame.size.width, origFrame.size.height);
//        adjust all other views
        if (translatedPoint.x - firstX > 0) {
//            we are shifting to the right
            for (int i = [stackedViews indexOfObject:sender.view] - 1; i >= 0; i--) {
                UIView *subView = [stackedViews objectAtIndex:i];
                xOffset+= kMinWidth;
                if (subView.frame.origin.x < xOffset) {
                    subView.frame = CGRectMake(xOffset, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
                }
                xOffset = subView.frame.origin.x;
            }
        } else {
//            we are moving to the left
            for (int i = [stackedViews indexOfObject:sender.view] + 1; i < [stackedViews count]; i++) {
                UIView *subView = [stackedViews objectAtIndex:i];
                xOffset = MAX(xOffset - kMinWidth, 0);
                if (subView.frame.origin.x > xOffset) {
                    subView.frame = CGRectMake(xOffset, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
                }
            }
        }
        firstX = translatedPoint.x;
    }
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
                [vc.view addGestureRecognizer:panner];
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

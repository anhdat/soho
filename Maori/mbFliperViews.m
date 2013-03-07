//
//  mbFliperViews.m
//  testFlip
//
//  Created by Dat Anh Truong on 3/7/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "mbFliperViews.h"
#import <QuartzCore/QuartzCore.h>
@implementation mbFliperViews

@synthesize origin;
@synthesize prespect;
@synthesize superView;
@synthesize time;

- (id)init
{
    self = [super init];
    if (self) {
        views = [[NSMutableArray alloc] init];
        idxActiveView = -1;
        prespect = -1000;
        CGPoint p = {0,0};
        origin = p;
        time = 1.0;
    }
    return self;
}

// create the layer for view
- (CALayer*) layerForView:(NSView*)view
{
    [view setWantsLayer:NO];
    [view setLayer:nil];
    
    CALayer* newLayer = [CALayer layer];
    NSRect frame = view.bounds;
    //frame.origin.x = frame.origin.y = 0;
    [newLayer setBounds:frame];
    newLayer.masksToBounds = NO;
    [newLayer setContentsGravity:kCAGravityCenter];
    newLayer.doubleSided = NO;
    [view setLayer:newLayer];
    [view setWantsLayer:YES];
    return newLayer;
}

- (void)addView:(NSView*)view
{
    [self layerForView:view];
    [view setFrameOrigin:origin];
    [views addObject:view];
}

- (void)removeViewAtIndex:(NSInteger)idx
{
    [views removeObjectAtIndex:idx];
}

- (NSView*)viewAtIndex:(NSInteger)idx
{
    return [views objectAtIndex:idx];
}

- (void)setActiveViewAtIndex:(NSInteger)idx
{
    if(idx != -1){
        if(idx != idxActiveView){
            if(idxActiveView == -1)
                [superView addSubview:[self viewAtIndex:idx]];
            else
                [superView replaceSubview:[self viewAtIndex:idxActiveView] with:[self viewAtIndex:idx]];
            [[self viewAtIndex:idx] setHidden:NO];
            idxActiveView = idx;
        }
    }
    else if(idxActiveView!=-1) {
        [[self viewAtIndex:idxActiveView] removeFromSuperview];
    }
}

-(void)setOrigin:(CGPoint)orig //setter for froperty origin
{
    origin = orig;
    NSInteger len = views.count;
    for(NSInteger i=0;i<len;i++){
        [[self viewAtIndex:i] setFrameOrigin:origin];
    }
}

- (CAAnimation*) createAnimFrom:(double)frAngl to:(double)toAngl yx:(NSInteger)yxRot
{
    NSString* sRotation;
    if (!yxRot)
        sRotation = @"transform.rotation.y";
    else
        sRotation = @"transform.rotation.x";
    CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:sRotation];
    ba.fromValue = [NSNumber numberWithFloat:frAngl];
    ba.toValue = [NSNumber numberWithFloat:toAngl];
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    shrinkAnimation.toValue = [NSNumber numberWithFloat:0.7f];
    shrinkAnimation.duration =  time*0.5;
    shrinkAnimation.autoreverses = YES;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:ba, shrinkAnimation, nil];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = time;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
    
}

-(void) flip:(NSInteger)direction //0 right, 1 left, 2 up, 3 down
{
    NSInteger lenViews = views.count;
    if(lenViews > 1){
        NSView* currView = [self viewAtIndex:idxActiveView];
        NSInteger nextIdx;
        NSView* nextView;
        if(!(direction & 1)){ //forward rotation
            if(idxActiveView+1 < lenViews){
                nextIdx = idxActiveView+1;
                nextView = [self viewAtIndex:nextIdx];
            }
            else {
                nextIdx = 0;
                nextView = [self viewAtIndex:0];
            }
        }
        else { // rotation backward
            if(idxActiveView > 0){
                nextIdx = idxActiveView-1;
                nextView = [self viewAtIndex:nextIdx];
            }
            else {
                nextIdx = views.count-1;
                nextView = [self viewAtIndex:nextIdx];
            }
        }
        [superView addSubview:nextView];
        
        // direction of rotation
        double to;
        
        to = (direction & 1) ? -M_PI : M_PI;
        
        [CATransaction begin];
        NSInteger xyRot = direction >> 1;
        CAAnimation* anim1 = [self createAnimFrom:0.0 to:to yx:xyRot];
        CAAnimation* anim2 = [self createAnimFrom:-to to:0.0 yx:xyRot];
        [CATransaction commit];
        
        //add perspective
        CATransform3D mt = CATransform3DIdentity;
        mt.m34 = 1.0/(double)prespect;
        
        CALayer* lr = [self layerForView: currView];
        CALayer* nextlr = [self layerForView: nextView];
        lr.transform = mt;
        nextlr.transform = mt;
        
        NSPoint ap = {0.5,0.5}; // Begin from OS X Mountain Lion ancorPoint by default at 0,0;
        lr.anchorPoint = ap;
        nextlr.anchorPoint = ap;
        
        // animation delegate to this class to handle message on its completion
        // implement animationDidStop:finished:
        anim1.delegate = self;
        
        [CATransaction begin];
        [lr addAnimation:anim1 forKey:@"flip"];
        [nextlr addAnimation:anim2 forKey:@"flip"];
        [CATransaction commit];
        idxBefore = idxActiveView;
        idxActiveView = nextIdx;
    }
}

- (IBAction)flipRight:(id)sender
{
    [self flip:0];
}

- (IBAction)flipLeft:(id)sender
{
    [self flip:1];
}

- (IBAction)flipUp:(id)sender
{
    [self flip:2];
}

- (IBAction)flipDown:(id)sender
{
    [self flip:3];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if(flag){
        //event handling end animation, clean prev view from tree superview
        NSView* beforeView = [self viewAtIndex:idxBefore];
        [beforeView removeFromSuperview];
    }
}

@end

//
//  mbFliperViews.h
//  testFlip
//
//  Created by Dat Anh Truong on 3/7/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//
// This file was a work of http://www.macbug.org/macosxsample/canimflipviews#.UTizZdEmlbs
//mbFliperViews* fliper - declared in the .h file
//fliper = [[mbFliperViews alloc] init];
//CGPoint org = {20,20}; // offset from the bottom superview
//fliper.origin = org;
//[fliper addView:view1]; // add views, which can be switched
//[fliper addView:view2];
//[fliper addView:view3];
//[fliper addView:view4];
//fliper.superView = _window.contentView; // as superview for example type of content view of the window
//[fliper setActiveViewAtIndex:0];

#import <Foundation/Foundation.h>
@interface mbFliperViews : NSObject
{
    NSMutableArray* views; //Animated views
    NSView* superView; // Super view
    NSInteger idxActiveView;
    NSInteger idxBefore;
    CGPoint origin; // origin for views
    NSInteger prespect; // перспектива
    double time;
}

- (void)addView:(NSView*)view;
- (void)removeViewAtIndex:(NSInteger)idx;
- (NSView*)viewAtIndex:(NSInteger)idx;
- (void)setActiveViewAtIndex:(NSInteger)idx;// set active view
- (IBAction)flipRight:(id)sender; // flip right
- (IBAction)flipLeft:(id)sender; // flip left
- (IBAction)flipUp:(id)sender; // flip up
- (IBAction)flipDown:(id)sender; // flip down

@property (nonatomic) CGPoint origin; // Starting point coordinates of all species in superview
@property NSInteger prespect; //perspective, the default value -1000
@property (retain) NSView* superView; // superview to insert the added view
@property double time; // time of the animation in seconds, default 1.0
@end

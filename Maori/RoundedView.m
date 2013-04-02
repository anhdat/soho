//
//  RoundedView.m
//  RoundedFloatingPanel
//
//  Created by Matt Gemmell on Thu Jan 08 2004.
//  <http://iratescotsman.com/>
//


#import "RoundedView.h"
#import "DHSwipeIndicator.h"

@implementation RoundedView
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setAcceptsTouchEvents:YES];
    self.swipeIndicator = [[DHSwipeIndicator alloc] initWithWebView:self] ;
   
}

- (void)drawRect:(NSRect)rect
{
    
//    NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.35];
    NSColor *bgColor = [NSColor colorWithCalibratedRed:0.0
                                                 green:0.0
                                                  blue:0.0
                                                 alpha:0.9];

    NSRect bgRect = rect;
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 5.0; // correct value to duplicate Panther's App Switcher
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:0.0];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:0.0];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    [bgColor set];
    [bgPath fill];
}


@end

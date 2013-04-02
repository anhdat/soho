//
//  NotificationView.m
//  Maori
//
//  Created by Dat Anh Truong on 4/2/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
//    NSRect fillRect= [self bounds];
//    [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.2] setFill];
//    NSRectFill(fillRect);
    NSColor *bgColor = [NSColor colorWithCalibratedRed:0.0
                                                 green:0.0
                                                  blue:0.0
                                                 alpha:0.2];
    
    NSRect bgRect = dirtyRect;
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 10.0; // correct value to duplicate Panther's App Switcher
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
                                     toPoint:NSMakePoint(maxX, midY)
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY)
                                     toPoint:NSMakePoint(midX, maxY)
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY)
                                     toPoint:NSMakePoint(minX, midY)
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin
                                     toPoint:NSMakePoint(midX, minY)
                                      radius:radius];
    [bgPath closePath];
    
    [bgColor set];
    [bgPath fill];
}

@end

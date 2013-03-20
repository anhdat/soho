//
//  FontView.m
//  Maori
//
//  Created by Dat Anh Truong on 3/19/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "FrontView.h"
#ifndef NSCOLOR
#define NSCOLOR(r, g, b, a) [NSColor colorWithCalibratedRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#endif
@implementation FrontView

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect fillRect= NSMakeRect([self frame].origin.x, [self frame].origin.y, [self frame].size.width,100);
//    NSRect fillRect = [self frame];
    [NSCOLOR(0, 0, 0, 0.5) setFill];
    NSRectFill(fillRect);
}

- (void)scrollWheel:(NSEvent *)theEvent{
    if ([theEvent deltaY] < 0) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"volumeUp"
         object:nil ];
    }
    if ([theEvent deltaY] > 0) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"volumeDown"
         object:nil ];
    }
}

- (void)mouseDown:(NSEvent *)event{
    
    if ([event clickCount] > 1) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"doubleClick"
         object:nil ];
    } else {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"mouseDown"
         object:nil ];
    }
}
@end

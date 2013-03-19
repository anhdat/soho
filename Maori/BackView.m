//
//  BackView.m
//  Maori
//
//  Created by Dat Anh Truong on 3/20/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "BackView.h"
#ifndef NSCOLOR
#define NSCOLOR(r, g, b, a) [NSColor colorWithCalibratedRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#endif

@implementation BackView

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
    // Drawing code here.
    NSRect fillRect= [self frame];
    [NSCOLOR(0, 0, 0, 1.0) setFill];
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
@end

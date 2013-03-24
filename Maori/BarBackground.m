//
//  BarBackground.m
//  Maori
//
//  Created by Dat Anh Truong on 3/20/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "BarBackground.h"
#ifndef NSCOLOR
#define NSCOLOR(r, g, b, a) [NSColor colorWithCalibratedRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#endif
@implementation BarBackground

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
    NSLog(@"abc");
    NSRect fillRect = [self frame];
    [NSCOLOR(0, 0, 0, 0.5) setFill];
    NSRectFill(fillRect);
}

@end

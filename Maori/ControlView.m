//
//  ControlView.m
//  Maori
//
//  Created by Dat Anh Truong on 3/7/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "ControlView.h"
#define backgroundColor [NSColor colorWithCalibratedRed:32.0/255.0 green:36.0/255.0 blue:41.0/255.0 alpha:1.0]
@implementation ControlView

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
    float red = 65/255.0;
    float green = 105/255.0;
    float blue = 255/255.0;
    float alpha = 0.2f;
    NSColor *myColor = [NSColor colorWithCalibratedRed:red
                                                 green:green
                                                  blue:blue
                                                 alpha:alpha];
    
    NSColor *startingColor = myColor;
    NSColor *endingColor = [NSColor colorWithCalibratedWhite:0.6 alpha:0.0];
    
    NSGradient* aGradient= [[NSGradient alloc] initWithColorsAndLocations:
                            endingColor, 0.0,
                            startingColor, 0.5,
                            endingColor, 1.0,
                            nil];
    [aGradient drawInRect:[self bounds] angle:180];
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

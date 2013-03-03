//
//  StatusView.m
//  Maori
//
//  Created by Dat Anh Truong on 2/28/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

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
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:startingColor
                             endingColor:endingColor];
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

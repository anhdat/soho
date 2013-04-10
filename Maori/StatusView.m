//
//  StatusView.m
//  Maori
//
//  Created by Dat Anh Truong on 2/28/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "StatusView.h"
#import "AppDelegate.h"
#import "STTDHSwipeIndicator.h"
@implementation StatusView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.swipeIndicator = [[STTDHSwipeIndicator alloc] initWithWebView:self] ;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    float red = 65/255.0;
    float green = 105/255.0;
    float blue = 255/255.0;
    float alpha = 0.1f;
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
    if ([theEvent isDirectionInvertedFromDevice]) {
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

    } else {
        if ([theEvent deltaY] > 0) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"volumeUp"
             object:nil ];
        }
        if ([theEvent deltaY] < 0) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"volumeDown"
             object:nil ];
        }
 
    }

}
- (void)mouseDown:(NSEvent *)event{
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate playPause:nil];
}

@end

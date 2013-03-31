//
//  BarBackground.m
//  Maori
//
//  Created by Dat Anh Truong on 3/20/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "BarBackground.h"

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
    NSRect fillRect= [self bounds];
    [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] setFill];
    NSRectFill(fillRect);
}
@end
    
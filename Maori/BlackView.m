//
//  BlackView.m
//  Maori
//
//  Created by Dat Anh Truong on 3/25/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "BlackView.h"
#import "Chick.h"
@implementation BlackView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect fillRect= [self bounds];
    [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.7] setFill];
    NSRectFill(fillRect);
}
@end

//
//  TransperentImageView.m
//  Maori
//
//  Created by Dat Anh Truong on 3/29/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "TransperentImageView.h"

@implementation TransperentImageView

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
    [[NSColor clearColor] setFill];
    NSRectFill(fillRect);
}

@end

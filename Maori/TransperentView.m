//
//  TransperentView.m
//  Maori
//
//  Created by Dat Anh Truong on 3/29/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "TransperentView.h"

@implementation TransperentView

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
   [[NSColor clearColor] setFill];
    NSRectFill(fillRect);

}

@end

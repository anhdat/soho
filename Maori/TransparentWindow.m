//
//  TransparentWindow.m
//  Maori
//
//  Created by Dat Anh Truong on 3/29/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "TransparentWindow.h"

@implementation TransparentWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    if ( self )
    {
        [self setStyleMask:NSBorderlessWindowMask];
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
    }
    
    return self;
}

@end

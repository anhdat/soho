//
//  DragLogo.m
//  Maori
//
//  Created by Dat Anh Truong on 3/28/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "DragLogo.h"

@interface DragLogo ()

@end

@implementation DragLogo

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [[self window] setStyleMask:NSBorderlessWindowMask];
        [[self window] setOpaque:NO];
        [[self window] setBackgroundColor:[NSColor clearColor]];
    }
    
    return self;
}

- (void)windowDidLoad
{

    [super windowDidLoad];
    [[self window] setLevel:NSScreenSaverWindowLevel + 1];
    [[self window] orderFront:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end

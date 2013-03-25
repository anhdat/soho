//
//  RoundedWindow.m
//  Maori
//
//  Created by Dat Anh Truong on 3/24/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "RoundedWindow.h"
#import "Chick.h"
#import "AppDelegate.h"
@implementation RoundedWindow
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


- (void) setContentView:(NSView *)aView
{
    aView.wantsLayer            = YES;
    aView.layer.frame           = aView.frame;
    aView.layer.cornerRadius    = 5.0;
    aView.layer.masksToBounds   = YES;
    
    [super setContentView:aView];
    
}

- (BOOL) canBecomeKeyWindow{
    return NO;
}

/*
 Start tracking a potential drag operation here when the user first clicks the mouse, to establish
 the initial location.
 */
- (void)mouseDown:(NSEvent *)theEvent {
    // Get the mouse location in window coordinates.
    if ([theEvent clickCount] > 1) {
        AppDelegate *appDelegateObject = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [[appDelegateObject niceChick] toggleLyrics:nil];
    }
    self.initialLocation = [theEvent locationInWindow];
}


/*
 Once the user starts dragging the mouse, move the window with it. The window has no title bar for
 the user to drag (so we have to implement dragging ourselves)
 */
- (void)mouseDragged:(NSEvent *)theEvent {
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;
    
    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - _initialLocation.x);
    newOrigin.y += (currentLocation.y - _initialLocation.y);
    
    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    
    // Move the window to the new location
    [self setFrameOrigin:newOrigin];
}
@end

//
//  StartupWindow.m
//  Maori
//
//  Created by Dat Anh Truong on 4/15/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "StartupWindow.h"

@interface StartupWindow ()

@end

@implementation StartupWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    [[self window] setFrameOrigin:NSMakePoint(screenFrame.size.width/2 - [[self window] frame].size.width/2, screenFrame.size.height/3*2)];
     [[self window] orderFront:nil];
}

- (IBAction)cancel:(id)sender {
    [[self window] close];
}

- (IBAction)ok:(id)sender {
   
    
    [[self window] close];
}
@end

//
//  NotificationWindowController.m
//  Maori
//
//  Created by Dat Anh Truong on 4/2/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "NotificationWindowController.h"

@interface NotificationWindowController ()

@end

@implementation NotificationWindowController

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
    [[self window] setLevel:NSScreenSaverWindowLevel + 1];
    [[self window] orderFront:nil];
    
    
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    [[self window] setFrameOrigin:NSMakePoint(screenFrame.size.width/2 - [[self window] frame].size.width/2, screenFrame.size.height/6)];
}


@end

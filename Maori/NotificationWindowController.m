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
        NSRect screenFrame = [[NSScreen mainScreen] frame];
        [[self window] setFrameOrigin:NSMakePoint(screenFrame.size.width/2 - [[self window] frame].size.width/2, screenFrame.size.height/6)];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setLevel:NSScreenSaverWindowLevel + 1];
    [[self window] orderFront:nil];
    
    
    
}

-(IBAction)showNotification:(id)sender withImageNamed:(NSString *) imageName withText:(NSString*) text withTime: (float) time{

		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[[self window] makeKeyAndOrderFront:self];
		[[[self window] animator] setAlphaValue:1.0];
		_isOpen = YES;
	
    NSImage* notiImage = [NSImage imageNamed:imageName];
    NSSize size = NSMakeSize(200.0, 200.0);
    [notiImage setSize:size];
    [[self notiImageView] setImage:notiImage];
    
    [[self notiText] setStringValue:text];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [[[self window] animator] setAlphaValue:0.0];
    });
}

@end

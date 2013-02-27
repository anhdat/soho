//
//  AppDelegate.m
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "AppDelegate.h"



@implementation AppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _controllerItem = [[NSStatusBar systemStatusBar] statusItemWithLength:100];
    
    NSTrackingAreaOptions trackingOptions =
    NSTrackingEnabledDuringMouseDrag
    | NSTrackingMouseEnteredAndExited
    | NSTrackingActiveAlways;
    NSTrackingArea *trackArea = [[NSTrackingArea alloc]
                                 initWithRect:[_mainView bounds]
                                 options:trackingOptions
                                 owner:self
                                 userInfo:nil];
    
    [_controllerItem setView:_mainView];
    [_mainView addTrackingArea:trackArea];
    
    [_mainView addSubview:_view1];
    [_mainView addSubview:_view2];
    [_mainView addSubview:_volumeView];
    
    
    CALayer *layer = [CALayer layer];
    [layer setContents:_mainView];
    [_mainView setWantsLayer:YES];
    
    [_view2 setHidden:YES];
    [_volumeView setHidden:YES];
    
    [self listenForVolumeEvents];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(iTunesTrackDidChange:)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:@"com.apple.iTunes.player"];
    
    iTunesApp = (iTunesApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
}
#pragma mark -
#pragma mark mouse envets handler
- (void)listenForVolumeEvents
{
    //register to listen for VOLUME event
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeUp:)
     name:@"volumeUp"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeDown:)
     name:@"volumeDown"
     object:nil ];
}

- (void)mouseExited:(NSEvent *)theEvent{
    [[_view1 animator] setHidden:NO];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5f];
    [[_view2 animator] setHidden:YES];
    [NSAnimationContext endGrouping];
    [[_volumeView animator] setHidden:YES];

 }

- (void)mouseEntered:(NSEvent *)theEvent{
    [[_view1 animator] setHidden:YES];
    [[_view2 animator] setHidden:NO];
}

-(void)volumeUp: (NSNotification *) notification{
    [[_view2 animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    if (iTunesApp.isRunning) {
        [iTunesApp setSoundVolume:[iTunesApp soundVolume]+10];
    }

    
}

-(void)volumeDown: (NSNotification *) notification{
    [[_view2 animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    if (iTunesApp.isRunning) {
        [iTunesApp setSoundVolume:[iTunesApp soundVolume]-10];
    }

}

#pragma mark -
#pragma mark players handler

- (iTunesTrack *)currentTrack
{
	if (!iTunesApp.isRunning)
		return nil;
	
	return iTunesApp.currentTrack;
}

- (void) iTunesTrackDidChange:(NSNotification *)aNotification{
    iTunesTrack *track = nil;
	
	if (![[aNotification userInfo][@"Player State"] isEqualToString:@"Stopped"])
		track = self.currentTrack;
	
}

@end

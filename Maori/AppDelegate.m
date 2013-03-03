//
//  AppDelegate.m
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate


@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _controllerItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
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
    
    [_mainView addSubview:_titleView];
    [_mainView addSubview:_controlView];
    [_mainView addSubview:_volumeView];
    
    
    CALayer *layer = [CALayer layer];
    [layer setContents:_mainView];
    [_mainView setWantsLayer:YES];
    
    [_controlView setHidden:YES];
    [_volumeView setHidden:YES];
    
    [self listenForVolumeEvents];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(iTunesTrackDidChange:)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:@"com.apple.iTunes.player"];
    
    iTunesApp = (iTunesApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    if (iTunesApp.isRunning) {
        if ([[iTunesApp currentTrack] name]) {
            [_txtTitle setStringValue:[[iTunesApp currentTrack] name]];
        }
    }
    
    [_controlView setFrameOrigin:NSMakePoint(
                                        (NSWidth([_mainView bounds]) - NSWidth([_controlView frame])) / 2,
                                        (NSHeight([_mainView bounds]) - NSHeight([_controlView frame])) / 2
                                        )];
    [_controlView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    
    [_panelController updateInformation:[iTunesApp currentTrack]];
    
}
#pragma mark -
#pragma mark mouse envets handler

- (void)listenForVolumeEvents{
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
    [[_titleView animator] setHidden:NO];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5f];
    [[_controlView animator] setHidden:YES];
    [NSAnimationContext endGrouping];
    [[_volumeView animator] setHidden:YES];

 }

- (void)mouseEntered:(NSEvent *)theEvent{
    [[_titleView animator] setHidden:YES];
    [[_controlView animator] setHidden:NO];
}

- (void)volumeUp: (NSNotification *) notification{
    [[_controlView animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    if (iTunesApp.isRunning) {
        [iTunesApp setSoundVolume:[iTunesApp soundVolume]+10];
        [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [iTunesApp soundVolume]]];
    }

    
}

- (void)volumeDown: (NSNotification *) notification{
    [[_controlView animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    if (iTunesApp.isRunning) {
        [iTunesApp setSoundVolume:[iTunesApp soundVolume]-10];
        [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [iTunesApp soundVolume]]];

    }

}

#pragma mark -
#pragma mark players handler

- (IBAction)nextTrack:(id)sender{
    if (iTunesApp.isRunning) {
        [iTunesApp nextTrack];
    }
}
- (IBAction)previousTrack:(id)sender{
    if (iTunesApp.isRunning) {
        [iTunesApp previousTrack];
    }
}
- (IBAction)playPause:(id)sender{
    if (iTunesApp.isRunning) {
        [iTunesApp playpause];
    }
}

- (iTunesTrack *)currentTrack{
	if (!iTunesApp.isRunning)
		return nil;
	return iTunesApp.currentTrack;
}

- (void) iTunesTrackDidChange:(NSNotification *)aNotification{
    iTunesTrack *track = nil;
    if (iTunesApp.isRunning) {
        if ([[iTunesApp currentTrack] name]) {
            [_txtTitle setStringValue:[[iTunesApp currentTrack] name]];
            [_panelController updateInformation:[iTunesApp currentTrack]];
        }
    }

	if (![[aNotification userInfo][@"Player State"] isEqualToString:@"Stopped"])
		track = self.currentTrack;
	
}

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}



@end

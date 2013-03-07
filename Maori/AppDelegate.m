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
    // Set up controlView
    _controllerItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _trackingOptions =
    NSTrackingEnabledDuringMouseDrag
    | NSTrackingMouseEnteredAndExited
    | NSTrackingActiveAlways;
    
    if (_trackArea != nil) {
        _trackArea = nil;
    }
    _trackArea = [[NSTrackingArea alloc]
                  initWithRect:[_mainView bounds]
                  options:_trackingOptions
                  owner:self
                  userInfo:nil];
    [_mainView addTrackingArea:_trackArea];
    [_controllerItem setView:_mainView];
    
    
    [_mainView addSubview:_titleView];
    [_mainView addSubview:_controlView];
    [_mainView addSubview:_volumeView];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat components[4] = {0.5f, 1.0f, 0.5f, 0.2f};
    CGColorRef whiteColor = CGColorCreate(colorSpace, components);
    
    CALayer *hostlayer = [CALayer layer];
    [_mainView setLayer:hostlayer];
    [_mainView setNeedsDisplay:YES];
    
    _progressLayer = [CALayer layer];
    [_progressLayer setFrame:[_mainView frame]];
    _progressLayer.backgroundColor = whiteColor;    [hostlayer addSublayer:_progressLayer];
    
    CGColorRelease(whiteColor);
    CGColorSpaceRelease(colorSpace);
    
    CALayer *layer = [CALayer layer];
    [layer setContents:_mainView];
    [_mainView setWantsLayer:YES];
    
    [_controlView setHidden:YES];
    [_volumeView setHidden:YES];
    
    [self listenForVolumeEvents];
    [self listenToViewChanging];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(iTunesTrackDidChange:)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:@"com.apple.iTunes.player"];
    iTunesApp = (iTunesApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    
    [_controlView setFrameOrigin:NSMakePoint(
                                             (NSWidth([_mainView bounds]) - NSWidth([_controlView frame])) / 2,
                                             (NSHeight([_mainView bounds]) - NSHeight([_controlView frame])) / 2
                                             )];
    [_controlView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    
    
    self.menubarController = [[MenubarController alloc] init];
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    
    [self iTunesTrackDidChange:nil];
    
    float viewWidth = [_mainView bounds].size.width;
    [[_panelController slideViewSize] setDoubleValue:viewWidth];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    
    
    
    
    
}
#pragma mark -
#pragma mark mouse events handler

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
    [[_titleView animator] setHidden:YES];
    if (iTunesApp.isRunning) {
        [iTunesApp setSoundVolume:[iTunesApp soundVolume]+5];
        [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [iTunesApp soundVolume]]];
    }
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector: @selector(mouseExited:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)volumeDown: (NSNotification *) notification{
    [[_controlView animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    [[_titleView animator] setHidden:YES];
    if (iTunesApp.isRunning) {
        [iTunesApp setSoundVolume:[iTunesApp soundVolume]-5];
        [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [iTunesApp soundVolume]]];
    }
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector: @selector(mouseExited:)
                                   userInfo:nil
                                    repeats:NO];
}


- (void) listenToViewChanging{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(viewSet:)
     name:@"viewSet"
     object:nil ];
}

- (void)viewSet: (NSNotification *) notification{
    NSRect rec = [_mainView bounds] ;
    NSSize size;
    size.height = rec.size.height;
    size.width = [[_panelController slideViewSize] doubleValue];
    [_mainView setFrameSize:size];
    [_titleView setFrame:[_mainView frame]];
    [_fieldTitle setFrame:[_mainView frame]];
    [self updateTitleView];
    if (_trackArea != nil) {
        _trackArea = nil;
    }
    _trackArea = [[NSTrackingArea alloc]
                  initWithRect:[_mainView bounds]
                  options:_trackingOptions
                  owner:self
                  userInfo:nil];
    [_mainView addTrackingArea:_trackArea];
}

- (void)updateProgressBar{
    NSInteger position = [iTunesApp playerPosition];
    float width = _mainView.frame.size.width;
    double duration =[[iTunesApp currentTrack] duration];
    NSRect frame = [_progressLayer frame];
    frame.size.width = position/duration * width;
    [[self progressLayer] setFrame:frame];
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

// Update information on txtTitle and in panelConttoler
// Invoked when start up an when track changes.
- (void) iTunesTrackDidChange:(NSNotification *)aNotification{
    if ([[iTunesApp currentTrack] name]) {
        [self updateTitleView];
        
        // Update panelController information.
        [_panelController updateInformation:[iTunesApp currentTrack]];
    }
}

- (void) updateTitleView{
    // Calculate the right size of font to fit the container.
    NSRect r = [_fieldTitle frame];
    float xMargin = 1.0;
    int minFontSize = 9;
    int maxFontSize = 13;
    NSString *currentFontName = @"Helvetica";
    float targetWidth = r.size.width - xMargin;
    
    // Get title from SB application.
    NSString *title = [[iTunesApp currentTrack] name];
    
    // the strategy is to start with a big font size
    // and go smaller until I'm smaller than one of the target sizes.
    int i;
    for (i=maxFontSize; i>minFontSize; i--) {
        NSDictionary* attrs = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:currentFontName size:i], NSFontAttributeName, nil];
        NSSize strSize = [title sizeWithAttributes:attrs];
        if (strSize.width < targetWidth )
            break;
        
    }
    // Output the title on titleView.
    [_txtTitle setStringValue:title];
    [_fieldTitle setFont:[NSFont fontWithName:currentFontName size:(i)]];
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
    float viewWidth = [_mainView bounds].size.width;
    [[_panelController slideViewSize] setDoubleValue:viewWidth];
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}



@end

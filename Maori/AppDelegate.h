//
//  AppDelegate.h
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "Spotify.h"
#import "Rdio.h"
#import "Radium.h"
#import "MenubarController.h"
#import "PanelController.h"
#import "ADTrack.h"
#import "Chick.h"
@interface AppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate,NSMenuDelegate, ChickDelegate>{
}
@property (nonatomic, strong) NSStatusItem *controllerItem;
//@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *mainView;
@property (weak) IBOutlet NSView *titleView;
@property (weak) IBOutlet NSView *controlView;
@property (weak) IBOutlet NSView *volumeView;

@property (weak) IBOutlet NSTextFieldCell *txtTitle;
@property (weak) IBOutlet NSTextFieldCell *txtVolume;
@property (weak) IBOutlet NSTextField *fieldTitle;

@property (weak) IBOutlet NSMenu *menuPlayer;
@property (weak) IBOutlet NSMenuItem *menuiTunes;
@property (weak) IBOutlet NSMenuItem *menuSpotify;
@property (weak) IBOutlet NSMenuItem *menuRdio;
@property (weak) IBOutlet NSMenuItem *menuRadium;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *loveBtn;

@property (strong, nonatomic) NSStatusItem *statusPlayItem ;
@property  NSTrackingAreaOptions trackingOptions;
@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (strong, nonatomic) NSTrackingArea *trackArea;
@property (strong, nonatomic) CALayer *progressLayer;

@property (nonatomic) Chick *niceChick ;

@property (strong, nonatomic) NSMutableArray *playerArray;
@property (strong, nonatomic) ADTrack *currentTrack;
@property (assign) bool enableChik;

- (IBAction)togglePanel:(id)sender;
- (IBAction)setiTunes:(id)sender;
- (IBAction)setSpotify:(id)sender;
- (IBAction)setRdio:(id)sender;
- (IBAction)setRadium:(id)sender;
- (IBAction)loveTrack:(id)sender;
- (IBAction)compact:(id)sender;

- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;
- (IBAction)playPause:(id)sender;
- (void) TrackDidChange:(NSNotification *)aNotification;
- (void) cleanTrackArea;
- (void) toggleLoveBtn;
@end

//
//  AppDelegate.h
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "MenubarController.h"
#import "PanelController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>{
    iTunesApplication *iTunesApp;
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
@property  NSTrackingAreaOptions trackingOptions;
@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (strong, nonatomic) NSTrackingArea *trackArea;
@property (strong, nonatomic) CALayer *progressLayer;


- (IBAction)togglePanel:(id)sender;

- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;
- (IBAction)playPause:(id)sender;
@end

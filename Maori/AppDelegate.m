//
//  AppDelegate.m
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "AppDelegate.h"
#import "MSDurationFormatter.h"
#import "NotificationWindowController.h"
#import "StartupWindow.h"
#import "NSColor+CGColor.h"

#define kAlreadyBeenLaunched @"AlreadyBeenLaunched"
#define kGreenComponents {0.5f, 1.0f, 0.5f, 0.3f}
#define kGrayComponents {0.0f, 0.0f, 0.0f, 0.05f}

@interface AppDelegate (){
}
@property (nonatomic) iTunesApplication *iTunesApp;
@property (nonatomic) SpotifyApplication *spotifyApp;
@property (nonatomic) RdioApplication *rdioApp;
@property (nonatomic) RadiumApplication *radiumApp;
@property (strong, nonatomic) NSMutableArray *preferedPlayer;
@property (nonatomic) Boolean isInController;

@property (nonatomic) Boolean iTunesState;
@property (nonatomic) Boolean spotifyState;
@property (nonatomic) Boolean rdioState;
@property (nonatomic) Boolean radiumState;

@property (nonatomic) Boolean isChanged;
@property (nonatomic) Boolean currentState;
@property (nonatomic) Boolean isJustRun;
@property (strong, nonatomic) StartupWindow *startup;

@property (nonatomic) NSColor *greenColor;
@property (nonatomic) NSColor *grayColor;


@end
@implementation AppDelegate


@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _isJustRun = YES;
    
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"AppleMomentumScrollSupported"];
    [defaults registerDefaults:appDefaults];
    
    
    //setup Views
    [self setupViews];
    
   
       
    // Set some observer for events triggered from other classes.
    [self listenForVolumeEvents];
    [self listenToViewChanging];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(TrackDidChange:)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:@"com.apple.iTunes.player"];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(TrackDidChange:)
                                                            name:@"com.spotify.client.PlaybackStateChanged"
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(TrackDidChange:)
                                                            name:@"com.rdio.desktop.PlaybackStateChanged"
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(TrackDidChange:)
                                                            name:@"com.catpigstudios.Radium3.stateChange"
                                                          object:nil];
   
    // early creation of menubarController and panelController.
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    
   
    _iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSString* spotifyPath = [ [ NSWorkspace sharedWorkspace ]
                            absolutePathForAppBundleWithIdentifier: @"com.spotify.client" ];
    if( spotifyPath ) {
        _spotifyApp =[SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    } else {
        _spotifyApp = nil;
    }
    
    spotifyPath = [ [ NSWorkspace sharedWorkspace ]
                   absolutePathForAppBundleWithIdentifier: @"com.rdio.desktop" ];
    if( spotifyPath ) {
        _rdioApp =[SBApplication applicationWithBundleIdentifier:@"com.rdio.desktop"];
    } else {
        _rdioApp = nil;
    }

    spotifyPath = [ [ NSWorkspace sharedWorkspace ]
                   absolutePathForAppBundleWithIdentifier: @"com.catpigstudios.Radium3" ];
    if( spotifyPath ) {
        _radiumApp =[SBApplication applicationWithBundleIdentifier:@"com.catpigstudios.Radium3"];
    } else {
        _radiumApp = nil;
    }

    
    
    _preferedPlayer = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"preferedPlayer"]];
    if ([_preferedPlayer count] == 0) {
        _preferedPlayer = [[NSMutableArray alloc] initWithObjects:@"iTunes", @"Spotify", @"Rdio", @"Radium", nil];
    }
    
    _playerArray = [[NSMutableArray alloc] init];
    
    _playerArray = _preferedPlayer ;
    
    
    _currentTrack = [[ADTrack alloc] init];
    
        
    [self setIsInController:NO];
    _iTunesState = YES;
    _spotifyState = YES;
    _rdioState = YES;
    _radiumState = YES;
    
    // update Progressbar under titleView
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateProgressBar)
                                   userInfo:nil
                                    repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector: @selector(updateMenu)
                                   userInfo:nil
                                    repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector: @selector(updateTitleView)
                                   userInfo:nil
                                    repeats:NO];
    [_menuPlayer setAutoenablesItems:NO];
    
   
    // Call to get init information
    [self TrackDidChange:nil];

//    [self updateTitleView];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LastFMConfigured"] != YES) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideLoveBtnState"];
    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNow" object:nil];
    [self toggleLoveBtn];
    
    // check launch for first time
//    long launchCount;
//    launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount" ];
//    
//    if (launchCount != 1){
//        _startup = [[StartupWindow alloc] initWithWindowNibName:@"StartupWindow"];
//        [_startup showWindow:nil];
//
//        
//        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"launchCount"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
}

- (void) toBottom:(NSString *) player{
    NSString *tempString= [_playerArray objectAtIndex:0];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([player isEqual:[_playerArray objectAtIndex:i]]) {
            for (NSInteger j = i; j < ([_playerArray count] -1) ; j++) {
                tempString = [_playerArray objectAtIndex:j+1];
                [_playerArray removeObjectAtIndex:j];
                [_playerArray insertObject:tempString atIndex:j];
            }
        }
    }
    [_playerArray removeLastObject];
    [_playerArray insertObject:player atIndex:3];
}

-(void) updatePlayerArray{
    // First, set isChanged to NO
    [self setIsChanged:NO];
    
    // Check iTunes
    if ([_iTunesApp isRunning]) {
        [self setCurrentState:YES];
    } else {
        [self setCurrentState:NO];
        if (![@"iTunes" isEqual:[_playerArray objectAtIndex:3]]) {
            [self toBottom:@"iTunes"];
        }
    }
    if (_currentState != _iTunesState) {
        [self setIsChanged:YES];
    }
    _iTunesState = _currentState;
    
    // Check Spotify
    if ([_spotifyApp isRunning]) {
        [self setCurrentState:YES];
    } else {
        [self setCurrentState:NO];
        if (![@"Spotify" isEqual:[_playerArray objectAtIndex:3]]) {
            [self toBottom:@"Spotify"];
        }
    }
    if (_currentState != _spotifyState) {
        [self setIsChanged:YES];
    }
    _spotifyState = _currentState;

    // Check Rdio
    if ([_rdioApp isRunning]) {
        [self setCurrentState:YES];
    } else {
        [self setCurrentState:NO];
        if (![@"Rdio" isEqual:[_playerArray objectAtIndex:3]]) {
            [self toBottom:@"Rdio"];
        }
    }
    if (_currentState != _rdioState) {
        [self setIsChanged:YES];
    }
    _rdioState = _currentState;

    // Check Radium
    if ([_radiumApp isRunning]) {
        [self setCurrentState:YES];
    } else {
        [self setCurrentState:NO];
        if (![@"Radium" isEqual:[_playerArray objectAtIndex:3]]) {
            [self toBottom:@"Radium"];
        }
    }
    if (_currentState != _radiumState) {
        [self setIsChanged:YES];
    }
    _radiumState = _currentState;
    
    if (_isChanged) {
        [self TrackDidChange:nil];
    }

}
- (void) updatePlayBtnToPlay{
    // For Play button on the status bar
    [_playButton setImage:[NSImage imageNamed:@"Auckland_Play"]];
    [_playButton setAlternateImage:[NSImage imageNamed:@"Auckland_Play_alt"]];
    
    // Play button on the panenl
    [[_panelController playBtn] setImage:[NSImage imageNamed:@"SoHo_Play"]];
    [[_panelController playBtn] setAlternateImage:[NSImage imageNamed:@"SoHo_Play_alt"]];
    
    // Color of Progress Bar
    _progressLayer.backgroundColor = _grayColor.CGColor;
}

- (void) updatePlayBtnToPause{
    // For play button on the status bar
    [_playButton setImage:[NSImage imageNamed:@"Auckland_Pause"]];
    [_playButton setAlternateImage:[NSImage imageNamed:@"Auckland_Pause_alt"]];
    
    // Play button on the pannel
    [[_panelController playBtn] setImage:[NSImage imageNamed:@"SoHo_Pause"]];
    [[_panelController playBtn] setAlternateImage:[NSImage imageNamed:@"SoHo_Pause_alt"]];
    
    // Color of Progrees Bar
      _progressLayer.backgroundColor = _greenColor.CGColor;
}


- (void) updatePlayButton{
    NSString *topPlayer = [_playerArray objectAtIndex:0];
   
    // Iterate the player array to find running application.
//    for (NSInteger i = 0; i < [_playerArray count]; i++) { 
        // iTunes
        if ([@"iTunes" isEqual:topPlayer]) {
            if ([_iTunesApp isRunning]) {
                switch (_iTunesApp.playerState)
                {
                    case iTunesEPlSPlaying:
                        [self updatePlayBtnToPause];
                        break;
                    default:
                        [self updatePlayBtnToPlay];
                        break;
                }
            } else {
                [self updatePlayBtnToPlay];
            }
            return;
        }
        
        // Spotify
        if ([@"Spotify" isEqual:topPlayer]) {
            if ([_spotifyApp isRunning]) {
                switch (_spotifyApp.playerState)
                {
                    case SpotifyEPlSPlaying:
                        [self updatePlayBtnToPause];
                        break;
                    default:
                        [self updatePlayBtnToPlay];
                        break;
                }
            } else {
                [self updatePlayBtnToPlay];
            }
            return;
        }
        if ([@"Rdio" isEqual:topPlayer]) {
            if ([_rdioApp isRunning]) {
                switch (_rdioApp.playerState)
                {
                    case RdioEPSSPlaying:
                        [self updatePlayBtnToPause];
                        break;
                    default:
                        [self updatePlayBtnToPlay];
                        break;
                }
            } else {
                [self updatePlayBtnToPlay];
            }
            
            return;
        }
        if ([@"Radium" isEqual:topPlayer]) {
            if ([_radiumApp isRunning]) {
//                RadiumRplayer *radiumPlayer;
//                _radiumPlayer = [_radiumApp player];
                if ([_radiumApp playing]) {
                    [self updatePlayBtnToPause];
                }else {
                    [self updatePlayBtnToPlay];
                }
            }else {
                [self updatePlayBtnToPlay];
            }
            return;
        }
//    } // end FOR
}
- (void) updateMenu{
    
    [self updatePlayerArray];
    if ([_iTunesApp isRunning]) {
        [_menuiTunes setEnabled:YES];
        switch (_iTunesApp.playerState)
        {
            case iTunesEPlSPlaying:
                if ([@"iTunes" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuiTunes setTitle:@"iTunes ♬◁"];
                } else {
                    [_menuiTunes setTitle:@"iTunes ♬"];
                }
                break;
            default:
                if ([@"iTunes" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuiTunes setTitle:@"iTunes ◁"];
                } else {
                    [_menuiTunes setTitle:@"iTunes"];
                }
                break;
        }
    } else {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:0]]){
            [_menuiTunes setTitle:@"iTunes ◁"];
        } else {
            [_menuiTunes setTitle:@"iTunes"];
        }
        [_menuiTunes setEnabled:NO];
    }
    
    if ([_spotifyApp isRunning]) {
        [_menuSpotify setEnabled:YES];
        switch (_spotifyApp.playerState)
        {
            case SpotifyEPlSPlaying:
                if ([@"Spotify" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuSpotify setTitle:@"Spotify ♬◁"];
                } else {
                    [_menuSpotify setTitle:@"Spotify ♬"];
                }
                break;
            default:
                if ([@"Spotify" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuSpotify setTitle:@"Spotify ◁"];
                } else {
                    [_menuSpotify setTitle:@"Spotify"];
                }
                break;
        }
    } else {
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:0]]){
            [_menuSpotify setTitle:@"Spotify ◁"];
        } else {
            [_menuSpotify setTitle:@"Spotify"];
        }
        [_menuSpotify setEnabled:NO];
    }
    
    if ([_rdioApp isRunning]) {
        [_menuRdio setEnabled:YES];
        switch (_rdioApp.playerState)
        {
            case RdioEPSSPlaying:
                if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuRdio setTitle:@"Rdio ♬◁"];
                } else {
                    [_menuRdio setTitle:@"Rdio ♬"];
                }
                break;
            default:
                if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuRdio setTitle:@"Rdio ◁"];
                } else {
                    [_menuRdio setTitle:@"Rdio"];
                }
                break;
        }
    } else {
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]){
            [_menuRdio setTitle:@"Rdio ◁"];
        } else {
            [_menuRdio setTitle:@"Rdio"];
        }
        [_menuRdio setEnabled:NO];
    }
    if ([_radiumApp isRunning]) {
        [_menuRadium setEnabled:YES];
        if ([_radiumApp playing]) {
            if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]){
                [_menuRadium setTitle:@"Radium ♬◁"];
            } else {
                [_menuRadium setTitle:@"Radium ♬"];
            }
        } else {
            if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]){
                [_menuRadium setTitle:@"Radium ◁"];
            } else {
                [_menuRadium setTitle:@"Radium"];
            }
        }
    } else {
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]){
            [_menuRadium setTitle:@"Radium ◁"];
        } else {
            [_menuRadium setTitle:@"Radium"];
        }
        [_menuRadium setEnabled:NO];
    }
}

-(void) setupViews{
    
    NSRect mainFrame = [_mainView frame];
    double width = [[NSUserDefaults standardUserDefaults] doubleForKey:@"width"];
    if (!width) {
        width = 1.0;
    }
    mainFrame.size.width = width;
    
    [_mainView setFrame:mainFrame];
    [_titleView setFrame:mainFrame];
    [_controlView setFrame:mainFrame];
    [_volumeView setFrame:mainFrame];
    // Set up controlView
    _controllerItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.menubarController = [[MenubarController alloc] init];

    // Create and add Tracking Area to mainView
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
    
    // Add subviews
    [_mainView addSubview:_titleView];
    [_mainView addSubview:_controlView];
    [_mainView addSubview:_volumeView];
    
    // Color Green then create a layer to make it ProgressBar under titleView
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//    CGFloat components1[4] = kGreenComponents;
//    CGFloat components2[4] = kGrayComponents;
//    _greenColor = CGColorCreate(colorSpace, components1); // not a white color :)
//    _grayColor = CGColorCreate(colorSpace, components2);
    
    _greenColor = [NSColor colorWithSRGBRed:0.5 green:1.0 blue:0.5 alpha:0.3];
    _grayColor = [NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:0.05];
    
    CALayer *hostlayer = [CALayer layer];
    [_mainView setLayer:hostlayer];
    [_mainView setNeedsDisplay:YES];
    
    _progressLayer = [CALayer layer];
    
    NSRect progressRect = NSMakeRect(mainFrame.origin.x, mainFrame.origin.y+2, mainFrame.size.width, 18);
    [_progressLayer setFrame:progressRect];
    _progressLayer.backgroundColor = _grayColor.CGColor;
    [hostlayer addSublayer:_progressLayer];
    
//    CGColorRelease(_greenColor);
//    CGColorSpaceRelease(colorSpace);
    
    CALayer *layer = [CALayer layer];
    [layer setContents:_mainView];
    [_mainView setWantsLayer:YES];
    
    [_controlView setHidden:YES];
    [_volumeView setHidden:YES];
    
    // Centralize volumeView
    [_volumeView setFrameOrigin:NSMakePoint(
                                             (NSWidth([_mainView bounds]) - NSWidth([_volumeView frame])) / 2,
                                             (NSHeight([_mainView bounds]) - NSHeight([_volumeView frame])) / 2
                                             )];
    [_volumeView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    

    [_mainView setMenu:_menuPlayer];
    
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
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(openMenu)
     name:@"mouseDown"
     object:nil ];
}

-(void) openMenu{
//    NSLog(@"Open menu");
    //    [_controllerItem popUpStatusItemMenu:[_controllerItem menu]];
    //    [_menuPlayer setDelegate:self];
    //    [_mainView setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent{
    [self setIsInController:NO];
    if ([[_currentTrack name] length] > 0) {
        [[_titleView animator] setHidden:NO];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.5f];
        [[_controlView animator] setHidden:YES];
        [NSAnimationContext endGrouping];
        [[_volumeView animator] setHidden:YES];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    [self setIsInController:YES];
    if ([[_currentTrack name] length] > 0) {
        [[_titleView animator] setHidden:YES];
        [[_controlView animator] setHidden:NO];
    }
}
- (void) volumeDone{
    [[_controlView animator] setHidden:NO];
    [[_volumeView animator] setHidden:YES];
    [[_titleView animator] setHidden:YES];
    if (![self isInController]) {
        [[_controlView animator] setHidden:YES];
        [[_volumeView animator] setHidden:YES];
        [[_titleView animator] setHidden:NO];
    }
}

- (void)volumeUp: (NSNotification *) notification{
    [[_controlView animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    [[_titleView animator] setHidden:YES];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                [_iTunesApp setSoundVolume:[_iTunesApp soundVolume]+5];
                [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [_iTunesApp soundVolume]]];
            }
            break;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                [_spotifyApp setSoundVolume:[_spotifyApp soundVolume]+5];
                [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [_spotifyApp soundVolume]]];
            }
            break;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                [_rdioApp setSoundVolume:[_rdioApp soundVolume]+5];
                [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [_rdioApp soundVolume]]];
            }
            break;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            break;
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:2.5f
                                     target:self
                                   selector: @selector(volumeDone)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)volumeDown: (NSNotification *) notification{
    [[_controlView animator] setHidden:YES];
    [[_volumeView animator] setHidden:NO];
    [[_titleView animator] setHidden:YES];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                [_iTunesApp setSoundVolume:[_iTunesApp soundVolume]-5];
                [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [_iTunesApp soundVolume]]];
            }
            break;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                [_spotifyApp setSoundVolume:[_spotifyApp soundVolume]-5];
                [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [_spotifyApp soundVolume]]];
            }
            break;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                [_rdioApp setSoundVolume:[_rdioApp soundVolume]-5];
                [_txtVolume setStringValue:[NSString stringWithFormat:@"Volume: %ld", [_rdioApp soundVolume]]];
            }
            break;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            break;
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:2.5f
                                     target:self
                                   selector: @selector(volumeDone)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) listenToViewChanging{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(viewSet:)
     name:@"viewSet"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(setPosition)
     name:@"changePostion"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(doubleClick)
     name:@"doubleClick"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playPause:)
     name:@"playPause"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(nextTrack:)
     name:@"nextSong"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(previousTrack:)
     name:@"prevSong"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(freeChick)
     name:@"freeChick"
     object:nil ];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(toggleLoveBtn)
     name:@"hideNow"
     object:nil ];
}

-(void) doubleClick{
    if ([_panelController frontIsFlipped]) {
        [_panelController flipToFront:nil];
    } else {
        [_panelController flipToBack:nil];
    }
}

- (void) setPosition{
    int pos = [[_panelController playerProgressBar] doubleValue] / 100 * [_currentTrack duration];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                [_iTunesApp setPlayerPosition:pos];
            }
            break;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                [_spotifyApp setPlayerPosition:pos];
            }
            break;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                [_rdioApp setPlayerPosition:pos];
            }
            break;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            break;
        }
    }

}
- (void)viewSet: (NSNotification *) notification{
    NSRect rec = [_mainView bounds] ;
    NSSize size;
    size.height = rec.size.height;
    double width = [[NSUserDefaults standardUserDefaults] doubleForKey:@"width"];
    if (!width) {
        width = 1.0;
    }
    size.width = width;
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    [theContext saveGraphicsState];
    [[_mainView animator] setFrameSize:size];
//    [_mainView setFrameSize:size];
//    [_titleView setFrame:[_mainView frame]];
//    [_fieldTitle setFrame:[_mainView frame]];
    [[_titleView animator] setFrameSize:size];
    [[_controlView animator] setFrameSize:size];
    [_volumeView setFrameSize:size];
//    [[_fieldTitle animator] setFrameSize:size];
     [theContext restoreGraphicsState];
    [self performSelector:@selector(updateTitleView) withObject:self afterDelay:[[NSAnimationContext currentContext] duration]];

    if (_trackArea != nil) {
        _trackArea = nil;
    }
    [self cleanTrackArea];
    _trackArea = [[NSTrackingArea alloc]
                  initWithRect:[_mainView bounds]
                  options:_trackingOptions
                  owner:self
                  userInfo:nil];
    
    [_mainView addTrackingArea:_trackArea];
}
- (void) cleanTrackArea{
    [_mainView removeTrackingArea:_trackArea];
}

- (void)updateProgressBar{
    double position = [self getPosition];
    double duration =[_currentTrack duration];
    
    NSString *elapsedTimeString = [MSDurationFormatter hoursMinutesSecondsFromSeconds:position];
    NSString *remainingTimeString = [MSDurationFormatter hoursMinutesSecondsFromSeconds:duration-position];
    [[_panelController txtEslapsedTime] setStringValue:elapsedTimeString];
    [[_panelController txtRemainingTime] setStringValue:remainingTimeString];
    
    float width = _mainView.frame.size.width;
    
    NSRect frame = [_progressLayer frame];
    frame.size.width = position/duration * width;
    [[self progressLayer] setFrame:frame];
    [_panelController updatePlayerProgressBar:position/duration*100];
}

#pragma mark -
#pragma mark players handler



- (IBAction)nextTrack:(id)sender{
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                [_iTunesApp nextTrack];
            }
            return;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                [_spotifyApp nextTrack];
            }
            return;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                [_rdioApp nextTrack];
            }
            return;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            return;
        }
    }
}
- (IBAction)previousTrack:(id)sender{
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                [_iTunesApp previousTrack];
            }
            return;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                [_spotifyApp previousTrack];
            }
            return;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                [_rdioApp previousTrack];
            }
            return;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            return;
        }
    }
}
- (IBAction)playPause:(id)sender{
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                [_iTunesApp playpause];
            }
            return;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                [_spotifyApp playpause];
            }
            return;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                [_rdioApp playpause];
            }
            return;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_radiumApp isRunning]) {
                if ([_radiumApp playing]) {
                    [_radiumApp pause];
                } else {
                    [_radiumApp play];
                }
            }
            return;
        }
    }
}

-(double) getPosition{
    double position = 1;
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                return [_iTunesApp playerPosition];
            }
            return position;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                return [_spotifyApp playerPosition];
            }
            return position;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                return [_rdioApp playerPosition];
            }
            return position;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            return position;
        }
    }
    
    return position;
}




-(void) updateCurrentTrack{
    
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_iTunesApp isRunning]) {
                iTunesTrack *current = [_iTunesApp currentTrack];
                if (current.duration > 0) {
                    [_currentTrack setAlbum:[current album]];
                    [_currentTrack setArtist:[current artist]];
                    [_currentTrack setName:[current name]];
                    [_currentTrack setDuration:[current duration]];
                    [_currentTrack setRating:[current rating]];
                    [_currentTrack setLyrics:[current lyrics]];
                    switch ([_iTunesApp playerState]) {
                        case iTunesEPlSPlaying:
                            [_currentTrack setPlayerState:@"Play"];
                            break;
                        case iTunesEPlSPaused:
                            [_currentTrack setPlayerState:@"Pause"];
                            break;
                        case iTunesEPlSStopped:
                            [_currentTrack setPlayerState:@"Stop"];
                            break;
                        default:
                            [_currentTrack setPlayerState:@"Pause"];
                            break;
                    }
                    [_currentTrack setTrackID:[current persistentID]];
                    NSImage *songArtwork;
                    
                    iTunesArtwork *artwork = (iTunesArtwork *)[[[current artworks] get] lastObject];
                    if(artwork != nil)
                        songArtwork = [[NSImage alloc] initWithData:[artwork rawData]];
                    else
                        songArtwork = [NSImage imageNamed:@"Sample"];
                    [_currentTrack setArtwork:songArtwork];
                } else {
                    [_currentTrack setName:@""];
                    [_currentTrack setAlbum:@""];
                    [_currentTrack setArtist:@""];
                }
            } else {
                [_currentTrack setName:@""];
                [_currentTrack setAlbum:@""];
                [_currentTrack setArtist:@""];
            }
            return;
        }
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_spotifyApp isRunning]) {
                SpotifyTrack *current = [_spotifyApp currentTrack];
                if ([current duration] > 0) {
                    NSString *album = [current album];
                    [_currentTrack setAlbum:album];
                    [_currentTrack setArtist:[current artist]];
                    [_currentTrack setName:[current name]];
                    [_currentTrack setDuration:[current duration]];
                    [_currentTrack setArtwork:[current artwork]];
                    if ([_currentTrack artwork] == nil) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                            [self TrackDidChange:nil];
                        });
                    }
                    [_currentTrack setIsAdvertisement:NO];
                    [_currentTrack setIsAdvertisement:[album hasPrefix:@"spotify:user"]||
                     [album hasPrefix:@"http:"]||
                     [album hasPrefix:@"spotify:ad"]];
                    [_currentTrack setUrl:[current spotifyUrl]];
                    [_currentTrack setTrackID:[current spotifyUrl]];
                    [_currentTrack setStarred:[current starred]];
                    switch ([_spotifyApp playerState]) {
                        case SpotifyEPlSPlaying:
                            [_currentTrack setPlayerState:@"Play"];
                            break;
                        case SpotifyEPlSPaused:
                            [_currentTrack setPlayerState:@"Pause"];
                            break;
                        case SpotifyEPlSStopped:
                            [_currentTrack setPlayerState:@"Stop"];
                            break;
                        default:
                            [_currentTrack setPlayerState:@"Pause"];
                            break;
                    }
                }else {
                    [_currentTrack setName:@""];
                    [_currentTrack setAlbum:@""];
                    [_currentTrack setArtist:@""];
                }
            }else {
                [_currentTrack setName:@""];
                [_currentTrack setAlbum:@""];
                [_currentTrack setArtist:@""];
            }
            return;
        }
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_rdioApp isRunning]) {
                RdioTrack *current = [_rdioApp currentTrack];
                if ([current duration] > 0) {
                    [_currentTrack setAlbum:[current album]];
                    [_currentTrack setArtist:[current artist]];
                    [_currentTrack setName:[current name]];
                    [_currentTrack setDuration:[current duration]];
//                    [_currentTrack setArtwork:[[NSImage alloc] initWithData:[current artwork]]];
                    switch ([_rdioApp playerState]) {
                        case RdioEPSSPlaying:
                            [_currentTrack setPlayerState:@"Play"];
                            break;
                        case RdioEPSSPaused:
                            [_currentTrack setPlayerState:@"Pause"];
                            break;
                        case RdioEPSSStopped:
                            [_currentTrack setPlayerState:@"Stop"];
                            break;
                        default:
                            [_currentTrack setPlayerState:@"Pause"];
                            break;
                    }
                    [_currentTrack setTrackID:[current rdioUrl]];
                }else {
                    [_currentTrack setName:@""];
                    [_currentTrack setAlbum:@""];
                    [_currentTrack setArtist:@""];
                }
            }else {
                [_currentTrack setName:@""];
                [_currentTrack setAlbum:@""];
                [_currentTrack setArtist:@""];
            }
            return;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_radiumApp isRunning]) {
                if ([_radiumApp playing]) {
                    NSString *fullName = [_radiumApp trackName];
                    [_currentTrack setDuration:180.0];
                    NSArray *tokens = [fullName componentsSeparatedByString:@"-"];
                    [_currentTrack setName:[tokens objectAtIndex:1]];
                    [_currentTrack setAlbum:@""];
                    [_currentTrack setArtist:[tokens objectAtIndex:0]];
                    if ([_radiumApp trackArtwork]) {
                        [_currentTrack setArtwork:[_radiumApp trackArtwork]];
                    }
                [_currentTrack setPlayerState:@"Play"];
            }else {
                    [_currentTrack setName:@""];
                    [_currentTrack setAlbum:@""];
                    [_currentTrack setArtist:@""];
                    [_currentTrack setPlayerState:@"Pause"];
                }
            }else {
                [_currentTrack setName:@""];
                [_currentTrack setAlbum:@""];
                [_currentTrack setArtist:@""];
            }
            return;
        }
    }
    
}

- (void) updateTitleView{
    // Calculate the right size of font to fit the container.
    NSRect r = [_fieldTitle frame];
    float xMargin = 4.0;
    int minFontSize = 9;
    int maxFontSize = 13;
    NSString *currentFontName = @"Helvetica Neue";
    float targetWidth = r.size.width - xMargin;
    
    // Get title from SB application.
    NSString *title = [_currentTrack name];
//    NSLog(@"Current song name: %@", title);
    // the strategy is to start with a big font size
    // and go smaller until I'm smaller than one of the target sizes.
    int i;
    for (i=maxFontSize; i>minFontSize; i--) {
        NSDictionary* attrs = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:currentFontName size:i], NSFontAttributeName, nil];
        NSSize strSize = [title sizeWithAttributes:attrs];
        if (strSize.width < targetWidth)
            break;
    }
    
    // Output the title on titleView.
    [_txtTitle setStringValue:title];
    [_fieldTitle setFont:[NSFont fontWithName:currentFontName size:(i)]];
}

- (void) TrackDidChange:(NSNotification *)aNotification{
    [self updateCurrentTrack];
    if ([[_currentTrack name] length] >= 1) {
        [self updateTitleView];
        // Update panelController information.
        [_panelController updateInformation:_currentTrack];
        [_niceChick updateInformation:_currentTrack];
        if ([_titleView isHidden] && [self isInController] == NO) {
            [self volumeDone];
        }
    } else {
        [[_titleView animator] setHidden:YES];
        [[_controlView animator] setHidden:NO];
    }
    [self updatePlayButton];
    
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


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;

    if (_isJustRun) {
       [self TrackDidChange:nil]; 
    }
    [self setIsJustRun:NO];
     
}

- (IBAction)setiTunes:(id)sender {
    if ([@"iTunes" isEqual:[_playerArray objectAtIndex:0]]) {
        return;
    }
    NSString *tempString= [_playerArray objectAtIndex:0];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"iTunes" isEqual:[_playerArray objectAtIndex:i]]) {
            [_playerArray removeObjectAtIndex:i];
            [_playerArray insertObject:tempString atIndex:i];
            break;
        }
    }
    [_playerArray removeObjectAtIndex:0];
    [_playerArray insertObject:@"iTunes" atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_preferedPlayer forKey:@"preferedPlayer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self TrackDidChange:nil];
}

- (IBAction)setSpotify:(id)sender {
    if ([@"Spotify" isEqual:[_playerArray objectAtIndex:0]]) {
        return;
    }
    NSString *tempString= [_playerArray objectAtIndex:0];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"Spotify" isEqual:[_playerArray objectAtIndex:i]]) {
            [_playerArray removeObjectAtIndex:i];
            [_playerArray insertObject:tempString atIndex:i];
            break;
        }
    }
    [_playerArray removeObjectAtIndex:0];
    [_playerArray insertObject:@"Spotify" atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_preferedPlayer forKey:@"preferedPlayer"];
     [[NSUserDefaults standardUserDefaults] synchronize];
    [self TrackDidChange:nil];
}

- (IBAction)setRdio:(id)sender {
    if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]) {
        return;
    }
    NSString *tempString= [_playerArray objectAtIndex:0];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"Rdio" isEqual:[_playerArray objectAtIndex:i]]) {
            [_playerArray removeObjectAtIndex:i];
            [_playerArray insertObject:tempString atIndex:i];
            break;
        }
    }
    [_playerArray removeObjectAtIndex:0];
    [_playerArray insertObject:@"Rdio" atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_preferedPlayer forKey:@"preferedPlayer"];
     [[NSUserDefaults standardUserDefaults] synchronize];
    [self TrackDidChange:nil];
}

- (IBAction)setRadium:(id)sender {
    if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]) {
        return;
    }
    NSString *tempString= [_playerArray objectAtIndex:0];
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            [_playerArray removeObjectAtIndex:i];
            [_playerArray insertObject:tempString atIndex:i];
            break;
        }
    }
    [_playerArray removeObjectAtIndex:0];
    [_playerArray insertObject:@"Radium" atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_preferedPlayer forKey:@"preferedPlayer"];
     [[NSUserDefaults standardUserDefaults] synchronize];
    [self TrackDidChange:nil];
    
}

- (void)toggleLoveBtn{
    bool hide = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideLoveBtnState"];
    if (hide) {
        [_loveBtn setHidden:YES];
    } else {
        [_loveBtn setHidden:NO];
    }
}

- (IBAction)loveTrack:(id)sender {
    [_panelController loveTrack];
}

- (IBAction)compact:(id)sender {
    [[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"width"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewSet" object:nil];
}

- (IBAction)quitMenu:(id)sender {
    [NSApp terminate:self];
}


- (void) freeChick{
    if (!_niceChick) {
        _niceChick = [[Chick alloc] initWithWindowNibName:@"Chick"];
    }
//
    [_niceChick showWindow:nil];
//    [[_niceChick window] setMovableByWindowBackground:YES];
    [self togglePanel:nil];
}
#pragma mark - Public accessors

- (PanelController *)panelController{
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller{
    return self.menubarController.statusItemView;
}


- (void)scrollWheel:(NSEvent *)theEvent{
    if ([theEvent deltaY] < 0) {
        [self volumeUp:nil];
    }
    if ([theEvent deltaY] > 0) {
        [self volumeDown:nil];    }
    
}

-(void)saveToUserDefaults:(NSString*)myString forKey:(NSString*) key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myString forKey:key];
        [standardUserDefaults synchronize];
    }
}


@end

//
//  AppDelegate.m
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic) iTunesApplication *iTunesApp;
@property (nonatomic) SpotifyApplication *spotifyApp;
@property (nonatomic) RdioApplication *rdioApp;
@property (nonatomic) RadiumApplication *radiumApp;
@end
@implementation AppDelegate


@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Start up as an agent app (without dock icon and menu)
    //hide icon on Dock
    //    ProcessSerialNumber psn = { 0, kCurrentProcess };
    //    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    //    [NSApp setActivationPolicy: NSApplicationActivationPolicyProhibited];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"AppleMomentumScrollSupported"];
    [defaults registerDefaults:appDefaults];
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
    
    
    
    // early creation of menubarController and panelController. REALLY NEED TO CHECK THE INIT PROCESS.
    // DUE TO PROBLEM WITH ALBUM ART
    self.menubarController = [[MenubarController alloc] init];
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    
    
    
    // set double value to slider at the back of panelController
    float viewWidth = [_mainView bounds].size.width;
    [[_panelController slideViewSize] setDoubleValue:viewWidth];
    
    // update Progressbar under titleView
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    
   
    _iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    _spotifyApp =[SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    _rdioApp = [SBApplication applicationWithBundleIdentifier:@"com.rdio.desktop"];
    _radiumApp = [SBApplication applicationWithBundleIdentifier:@"com.catpigstudios.Radium"];

    
    
    
    _playerArray = [[NSMutableArray alloc] init];
    [_playerArray addObject:@"iTunes"];
    [_playerArray addObject:@"Spotify"];
    [_playerArray addObject:@"Rdio"];
    [_playerArray addObject:@"Radium"];
    _currentTrack = [[ADTrack alloc] init];
    NSLog(@"%ld", [_playerArray count]);
    for (NSInteger i = 0; i < [_playerArray count]; i++) {
        NSLog(@"%@", [_playerArray objectAtIndex:i]);
    }
    // Call to get init information
    [self TrackDidChange:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector: @selector(updateMenu)
                                   userInfo:nil
                                    repeats:YES];
    [_menuPlayer setAutoenablesItems:NO];
    
}
-(void) getPlayer{
    }
- (void) updateMenu{
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
            [_menuRdio setTitle:@"RdioYES"];
            [_menuRdio setEnabled:YES];
            switch (_rdioApp.playerState)
            {
                case RdioEPSSPlaying:
                    if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]){
                        [_menuRdio setTitle:@"Rdio◀ ♬"];
                    } else {
                        [_menuRdio setTitle:@"Rdio ♬"];
                    }
                    break;
                default:
                    if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]){
                        [_menuRdio setTitle:@"Rdio◀"];
                    } else {
                        [_menuRdio setTitle:@"Rdio"];
                    }
                    break;
            }
        } else {
            if ([@"Rdio" isEqual:[_playerArray objectAtIndex:0]]){
                [_menuRdio setTitle:@"Rdio◀"];
            } else {
                [_menuRdio setTitle:@"Rdio"];
            }
            [_menuRdio setEnabled:NO];
        }
        if ([_radiumApp isRunning]) {
            [_menuRadium setEnabled:YES];
            RadiumRplayer *radiumPlayer;
            if ([radiumPlayer playing]) {
                if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuRadium setTitle:@"Radium◀ ♬"];
                } else {
                    [_menuRadium setTitle:@"Radium ♬"];
                }
            } else {
                if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]){
                    [_menuRadium setTitle:@"Radium◀"];
                } else {
                    [_menuRadium setTitle:@"Radium"];
                }
            }
        } else {
            if ([@"Radium" isEqual:[_playerArray objectAtIndex:0]]){
                [_menuRadium setTitle:@"Radium◀"];
            } else {
                [_menuRadium setTitle:@"Radium"];
            }
            [_menuRadium setEnabled:NO];
        }
}

-(void) setupViews{
    // Set up controlView
    _controllerItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
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
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat components[4] = {0.5f, 1.0f, 0.5f, 0.2f};
    CGColorRef whiteColor = CGColorCreate(colorSpace, components); // not a white color :)
    
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
    
    // Centralize controlView
    [_controlView setFrameOrigin:NSMakePoint(
                                             (NSWidth([_mainView bounds]) - NSWidth([_controlView frame])) / 2,
                                             (NSHeight([_mainView bounds]) - NSHeight([_controlView frame])) / 2
                                             )];
    [_controlView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    
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
    NSLog(@"Open menu");
    //    [_controllerItem popUpStatusItemMenu:[_controllerItem menu]];
    //    [_menuPlayer setDelegate:self];
    //    [_mainView setNeedsDisplay:YES];
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
                                   selector: @selector(mouseExited:)
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
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(setPostion:)
     name:@"changePostion"
     object:nil ];
}


- (void)setPostion: (NSNotification *) notification{
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
    NSInteger position = [self getPosition];
    double duration =[_currentTrack duration];
    
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
                [[_radiumApp player] playPause];
            }
            return;
        }
    }
}

-(NSInteger) getPosition{
    NSInteger position = 1;
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
                    NSImage *songArtwork;
                    
                    iTunesArtwork *artwork = (iTunesArtwork *)[[[current artworks] get] lastObject];
                    if(artwork != nil)
                        songArtwork = [[NSImage alloc] initWithData:[artwork rawData]];
                    else
                        songArtwork = [NSImage imageNamed:@"Sample.tiff"];
                    [_currentTrack setArtwork:songArtwork];

                }
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
                    [_currentTrack setIsAdvertisement:NO];
                    [_currentTrack setIsAdvertisement:[album hasPrefix:@"spotify:user"]||
                     [album hasPrefix:@"http:"]||
                     [album hasPrefix:@"spotify:ad"]];
                    [_currentTrack setUrl:[current spotifyUrl]];
                    [_currentTrack setStarred:[current starred]];

                }
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
                    [_currentTrack setArtwork:[[NSImage alloc] initWithData:[current artwork]]];
                }
            }
            return;
        }
        if ([@"Radium" isEqual:[_playerArray objectAtIndex:i]]) {
            if ([_radiumApp isRunning]) {
                RadiumRplayer *radiumPlayer;
                if ([radiumPlayer playing]) {
                    [_currentTrack setName:[radiumPlayer songTitle]];
                    [_currentTrack setArtwork:[radiumPlayer songArtwork]];

                }
            }
            return;
        }
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
    NSString *title = [_currentTrack name];
    NSLog(@"Current song name: %@", title);
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

- (void) TrackDidChange:(NSNotification *)aNotification{
    [self updateCurrentTrack];
    if ([_currentTrack name]) {
        [self updateTitleView];
        // Update panelController information.
        [_panelController updateInformation:_currentTrack];
    }
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
    [self TrackDidChange:nil];
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
    [self TrackDidChange:nil];

}

#pragma mark - Public accessors

- (PanelController *)panelController{
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller{
    return self.menubarController.statusItemView;
}



@end

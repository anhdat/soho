#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "ADTrack.h"
#import "FrontView.h"
#import "BackView.h"
#import "NotificationWindowController.h"

#import <Scribbler/Scribbler.h>
#import "EMKeychainProxy.h"
#import "EMKeychainItem.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 400
#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize searchField = _searchField;
@synthesize textField = _textField;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
        
        //lastfm
        NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"LastFMConfigured", @"", @"LastFMUsername", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        
        
        // We'll use this variable for when we need to switch back and
        // forth between the web browser
        authorizationPending = NO;
        
        // First, let's setup the web service object
        // You can obtain the API key and shared secret on your API info page
        //  - http://www.last.fm/api/account
        
        LFWebService *lastfm = [LFWebService sharedWebService];
        [lastfm setDelegate:self];
        [lastfm setAPIKey:@"99876210ed01e4c2e7247b255828e58d"];
        [lastfm setSharedSecret:@"d4ed5f693627141c4e3cddd4f2b019e5"];
        
        // We'll also set our client ID for scrobbling
        // You can obtain one of these by contacting Last.fm
        //  - http://www.last.fm/api/submissions#1.1
        // For now, we'll use the testing ID 'tst'
        [lastfm setClientID:@"tst"];
        [lastfm setClientVersion:@"1.0"];
        
        // We're also going to turn off autoscrobble, which
        // scrobbles the last playing track automatically
        // whenever a new track starts playing
        [lastfm setAutoScrobble:NO];
        
        // In order to run, we need a valid session key
        // First, we'll check to see if we have one. If we do,
        // we'll set it, then test it. Otherwise, we'll wait for
        // someone to click the "Connect" button.
        [self connectWithStoredCredentials];
        
        
        _wasPlaying = NO;
        [self showAuthConnectPane];
//        [_authStatus setHidden:NO];
//        [_authSpinner setHidden:YES];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    // Resize panel
    NSRect panelRect = [[self window] frame];
    panelRect.size.height = POPUP_HEIGHT;
    [[self window] setFrame:panelRect display:NO];
    
    fliper = [[mbFliperViews alloc] init];
    CGPoint org = {0,0}; // offset from the bottom superview
    fliper.origin = org;
    [fliper addView:_frontView]; // add views, which can be switched
    [fliper addView:_backView];
    fliper.superView = _hostView; // as superview for example type of content view of the window
    [fliper setActiveViewAtIndex:0];
    _frontIsFlipped = NO;

}

#pragma mark - Public accessors

- (void)completeAuthorization {
    // If we have a pending authorization, this is our
    // cue to start trying to validate it, since the user likely
    // just switched back from the browser window
    
    if (authorizationPending)
    {
        
        authorizationPending = NO;
        [self completeAuthorization:nil];
        NSLog(@"trying to authorization");
        [NSTimer scheduledTimerWithTimeInterval:5.0f
                                         target:self
                                       selector:@selector(completeAuthorization)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (IBAction)flipToBack:(id)sender {
    [self connectWithStoredCredentials];
    if (_frontIsFlipped) {
        [fliper flipRight:nil];
        _frontIsFlipped = NO;
    } else {
        [fliper flipLeft:nil];
        _frontIsFlipped = YES;
    }

}

- (IBAction)quitApp:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)flipToFront:(id)sender {
    [fliper flipRight:nil];
    _frontIsFlipped = NO;
}

- (IBAction)freeChick:(id)sender {
   [[NSNotificationCenter defaultCenter] postNotificationName:@"freeChick" object:nil];
}

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    
    NSRect searchRect = [_albumart frame];
    searchRect.size.width = NSWidth([self.backgroundView bounds]);
    searchRect.origin.x = 2;
    searchRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - 2 - NSHeight(searchRect);
    [self.hostView setFrame:searchRect];
//    
//    if (NSIsEmptyRect(searchRect))
//    {
//        [self.hostView setHidden:YES];
//    }
//    else
//    {
//        [self.hostView setFrame:searchRect];
//        [self.hostView setHidden:NO];
//    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}


#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
//    NSEvent *currentEvent = [NSApp currentEvent];
//    if ([currentEvent type] == NSLeftMouseDown)
//    {
//        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
//        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
//        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
//        if (shiftPressed || shiftOptionPressed)
//        {
//            openDuration *= 10;
//            
//            if (shiftOptionPressed)
//                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
//                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
//        }
//    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
    NSString *theUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastFMUsername"];
    if ([theUser length] > 0) {
        [self showAuthConnectedPaneWithUser:theUser];
    }
}

- (void)closePanel
{
    if (_frontIsFlipped) {
        [self flipToFront:nil];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}


- (void)updateInformation:(ADTrack*) currentTrack{
    NSString *name = [currentTrack name];
    NSString *artist = [currentTrack artist];
    NSString *album = [currentTrack album];
    NSString *state = [currentTrack playerState];
    
    NSSize artSize = [_albumart frame].size;
    NSImage *artwork = [currentTrack artwork];
    if(artwork == nil){
         artwork = [NSImage imageNamed:@"Sample.tiff"];
    }
    [artwork setScalesWhenResized:NSScaleProportionally];
    [artwork setSize:artSize];
    [_albumart setImage:artwork];
    
    if ([name length] > 0) {
        [_txtSongTitle setStringValue:name];
    } else {
        [_txtSongTitle setStringValue:@""];
    }
    
    if ([album length] > 0) {
        [_txtAlbum setStringValue:album];
    } else {
        [_txtAlbum setStringValue:@""];
    }
    if ([artist length] > 0) {
        [_txtArtist setStringValue:artist];
    } else {
        [_txtArtist setStringValue:@""];
    }
    
    if ([state isEqualToString:@"Stop"])
	{
		// Scrobble if it's necessary
		if (_curentLFTrack)
		{
			[_curentLFTrack stop];
			currentTrack = nil;
			_wasPlaying = NO;
		}
		return;
	}
	
	// check persistentID
	NSString *theID = [currentTrack trackID];
	if (![_currentTrackID isEqualToString:theID])
	{
		// Scrobble if it's necessary
		if (_curentLFTrack)
		{
			[_curentLFTrack stop];
			_curentLFTrack = nil;
			_wasPlaying = NO;
		}
		
		// the track changed
		if (!(name || artist))
		{
			return;
		}
		
		LFTrack *theTrack = [LFTrack trackWithTitle:name artist:artist duration:[currentTrack duration]];
				
		_curentLFTrack = theTrack;
		_currentTrackID = theID;
	}
	
	if ([state isEqualToString:@"Play"] && !_wasPlaying)
	{
		[_curentLFTrack play];
		_wasPlaying = YES;
	}
	if ([state isEqualToString:@"Pause"] && _wasPlaying)
	{
		[_curentLFTrack pause];
		_wasPlaying = NO;
	}

}


- (void)updatePlayerProgressBar:(double) position{
    [_playerProgressBar setDoubleValue:position];
}


- (IBAction)playerBarDidChange:(id)sender {
   [[NSNotificationCenter defaultCenter] postNotificationName:@"changePostion" object:nil];
}

- (IBAction)playPause:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPause" object:nil];
}

- (IBAction)prevSong:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"prevSong" object:nil];
}

- (IBAction)nextSong:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextSong" object:nil];
}

- (IBAction)toggleLaunchAtLogin:(id)sender {
    LaunchAtLoginController *launch = [[LaunchAtLoginController alloc] init];
    [launch setLaunchAtLogin:![launch launchAtLogin]];
}

- (void)showAuthConnectPane
{
	[_authStatus setStringValue:@"You are not login."];
    [_authSpinner setHidden:YES];
	[_authSpinner stopAnimation:self];
	
	[_authConnectButton setTitle:@"Connect"];
	
	[_authConnectButton setAction:@selector(connectWithLastFM:)];
	[_authConnectButton setHidden:NO];
}
- (void)showAuthPreAuthPane
{
	[_authConnectButton setHidden:YES];
    [_authSpinner setHidden:NO];
	[_authStatus setStringValue:@"Making Authorization Request…"];
	[_authSpinner startAnimation:self];
}
- (void)showAuthWaitingPane
{
	[_authConnectButton setHidden:YES];
	[_authStatus setStringValue:@"Awaiting Authorization…"];
	
    [_authSpinner setHidden:NO];
	[_authSpinner startAnimation:self];
}
- (void)showAuthValidatingPane
{
	[_authConnectButton setHidden:YES];
	[_authStatus setStringValue:@"Checking Authorization…"];
	[_authSpinner startAnimation:self];
}
- (void)showAuthConnectedPaneWithUser:(NSString *)username
{
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hi, %@!", username]];
	[_authStatus setAttributedStringValue:str];
	
    [_authConnectButton setTitle:@"Disconnect"];
	
    [_authSpinner stopAnimation:self];
    [_authSpinner setHidden:YES];
    
	[_authConnectButton setAction:@selector(disconnectFromLastFM:)];
	[_authConnectButton setHidden:NO];
}


#pragma mark Authorization methods
- (void)connectWithStoredCredentials
{
	// we have stored credentials, so we'll grab the user from the defaults,
	// then grab the session key from the keychain...
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LastFMConfigured"])
	{
		NSString *theUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastFMUsername"];
		
		NSString *keychainService = [NSString stringWithFormat:@"Last.fm (%@)", [[NSBundle mainBundle] bundleIdentifier]];
		EMGenericKeychainItem *keyItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:keychainService withUsername:theUser];
		if (keyItem)
		{
			// we'll set both the user and session key in the web service
			LFWebService *lastfm = [LFWebService sharedWebService];
			[lastfm setSessionUser:theUser];
			[lastfm setSessionKey:[keyItem password]];
			
			// and then attempt to validate the credentials
			[lastfm validateSessionCredentials];
			
			// Adjust the UI
			[self showAuthValidatingPane];
		}
	}
}
- (IBAction)connectWithLastFM:(id)sender
{
	// This means we're going to force establish a new Last.fm session
	[[LFWebService sharedWebService] establishNewSession];
	
	// Adjust the UI to show status
	[self showAuthPreAuthPane];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0f
                                     target:self
                                   selector: @selector(completeAuthorization)
                                   userInfo:nil
                                    repeats:NO];
}
- (IBAction)disconnectFromLastFM:(id)sender
{
	// We need to get the username
	NSString *theUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastFMUsername"];
	
	// We need to delete the user default information
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LastFMConfigured"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastFMUsername"];
	
	// And clear the Keychain info
	NSString *keychainService = [NSString stringWithFormat:@"Last.fm (%@)", [[NSBundle mainBundle] bundleIdentifier]];
	EMGenericKeychainItem *keyItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:keychainService withUsername:theUser];
	if (keyItem)
		[keyItem setPassword:@""];
	
	// Finally, clear out the web service...
	LFWebService *lastfm = [LFWebService sharedWebService];
	[lastfm setSessionUser:nil];
	[lastfm setSessionKey:nil];
	
	// ... and update the UI
	[self showAuthConnectPane];
}
- (IBAction)completeAuthorization:(id)sender
{
	// And now we finish authorization
	[[LFWebService sharedWebService] finishSessionAuthorization];
}
- (IBAction)openManagementPage:(id)sender
{
	// Manage third-party application access on Last.fm
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.last.fm/settings/applications"]];
}

#pragma mark Track methods
//- (IBAction)startPlayingTrack:(id)sender
//{
//	LFTrack *track = [LFTrack trackWithTitle:@"trackName"  artist:@"trackArtist" duration:345.0];
//	[track play];
//}
//- (IBAction)scrobbleTrack:(id)sender
//{
//	LFTrack *track = [LFTrack trackWithTitle:@"trackName"  artist:@"trackArtist" duration:345.0];
//	[track setPlayingTime:100.0];
//	[track stop]; // forces a scrobble
//}
//- (IBAction)loveTrack:(id)sender
//{
//	LFTrack *track = [LFTrack trackWithTitle:@"trackName"  artist:@"trackArtist" duration:345.0];
//	[track setPlayingTime:100.0];
//	[track love];
//	[track stop]; // forces a scrobble
//}
//- (IBAction)banTrack:(id)sender
//{
//	LFTrack *track = [LFTrack trackWithTitle:@"trackName"  artist:@"trackArtist" duration:345.0];
//	[track setPlayingTime:200.0];
//	[track ban];
//	[track stop]; // forces a scrobble
//}

- (void) loveTrack{
    [_curentLFTrack love];
    [_curentLFTrack stop];
}

#pragma mark Web service delegate methods
- (void)sessionNeedsAuthorizationViaURL:(NSURL *)theURL
{
	// OK, so the first stage is done; we'll update the
	// UI to match the current status,
	// then open up the web browser to have the user allow our demo app
	// access
	[self showAuthWaitingPane];
	
	[[NSWorkspace sharedWorkspace] openURL:theURL];
	authorizationPending = YES;
}
- (void)sessionAuthorizationStillPending
{
	// We tried to authorize the session, but the user
	// isn't done in the web browser yet. Wait 5 seconds,
	// then try again.
	
	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(completeAuthorization:) userInfo:nil repeats:NO];
}
- (void)sessionAuthorizationFailed
{
	// We failed. Epically.
	[self showAuthConnectPane];
}
- (void)sessionCreatedWithKey:(NSString *)theKey user:(NSString *)theUser
{
	// The session key will be valid for future uses -- it never
	// expires unless explicitly revoked by the Last.fm user.
	// Therefore, we can store the user as a default, and then store
	// the key in the Keychain for future use.
	
	[[NSUserDefaults standardUserDefaults] setObject:theUser forKey:@"LastFMUsername"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LastFMConfigured"];
	
	NSString *keychainService = [NSString stringWithFormat:@"Last.fm (%@)", [[NSBundle mainBundle] bundleIdentifier]];
	EMGenericKeychainItem *keyItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:keychainService withUsername:theUser];
	if (keyItem)
		[keyItem setPassword:theKey];
	else
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:keychainService withUsername:theUser password:theKey];
	
	// Hooray! we're up and running
	[self showAuthConnectedPaneWithUser:theUser];
}

- (void)sessionValidatedForUser:(NSString *)theUser
{
	// Hooray! we're up and running
	[self showAuthConnectedPaneWithUser:theUser];
}
- (void)sessionInvalidForUser:(NSString *)theUser
{
	// We failed. Epically.
	[self showAuthConnectPane];
}
- (void)sessionKeyRevoked:(NSString *)theKey forUser:(NSString *)theUser
{
	// The key was revoked, so we disconnect from Last.fm permanently
	[self disconnectFromLastFM:self];
}

- (void)scrobblerHandshakeSucceeded
{
	[self log:@"Handshake succeeded"];
}
- (void)scrobblerHandshakeFailed:(NSError *)theError willRetry:(BOOL)willRetry
{
	[self log:@"Handshake failed (retry=%d): %@", willRetry, [theError localizedDescription]];
}
- (void)scrobblerClient:(NSString *)theClientID bannedForVersion:(NSString *)theClientVersion
{
	[self log:@"Client banned"];
}
- (void)scrobblerRejectedSystemTime
{
	[self log:@"Time rejected"];
}

- (void)nowPlayingSucceededForTrack:(LFTrack *)theTrack
{
	[self log:@"Now playing succeeded: %@ (%@)", [theTrack title], [theTrack artist]];
}
- (void)scrobbleSucceededForTrack:(LFTrack *)theTrack
{
	[self log:@"Scrobble succeeded: %@ (%@)", [theTrack title], [theTrack artist]];
}
- (void)loveSucceededForTrack:(LFTrack *)theTrack
{
	[self log:@"Love succeeded: %@ (%@)", [theTrack title], [theTrack artist]];
   
    NotificationWindowController *loveNotification;
    if (!loveNotification) {
        loveNotification = [[NotificationWindowController alloc] initWithWindowNibName:@"NotificationWindowController"];
    }
    [loveNotification showWindow:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [loveNotification close];
    });
    
}
- (void)banSucceededForTrack:(LFTrack *)theTrack
{
	[self log:@"Ban succeeded: %@ (%@)", [theTrack title], [theTrack artist]];
}

- (void)nowPlayingFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry
{
	[self log:@"Now playing failed (retry=%d): %@ (%@) - %@", willRetry, [theTrack title], [theTrack artist], [theError localizedDescription]];
}
- (void)scrobbleFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry
{
	[self log:@"Scrobble failed (retry=%d): %@ (%@) - %@", willRetry, [theTrack title], [theTrack artist], [theError localizedDescription]];
}
- (void)loveFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry
{
	[self log:@"Love failed (retry=%d): %@ (%@) - %@", willRetry, [theTrack title], [theTrack artist], [theError localizedDescription]];
}
- (void)banFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry
{
	[self log:@"Ban failed (retry=%d): %@ (%@) - %@", willRetry, [theTrack title], [theTrack artist], [theError localizedDescription]];
}
#pragma mark Log methods
- (void)log:(NSString *)format, ...
{
	// log out to the activity display
	va_list argList;
	va_start(argList, format);
	NSString *output = [[NSString alloc] initWithFormat:format arguments:argList];
	va_end(argList);
	
	NSLog(@"%@", output);
}

- (IBAction)toggleLoveBtn:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:([_toggleLoveBtnChk state]==NSOnState) forKey:@"hideLoveBtnState"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNow" object:nil];
}
@end

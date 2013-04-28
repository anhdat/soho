#import "BackgroundView.h"
#import "StatusItemView.h"
#import "mbFliperViews.h"
#import "Chick.h"
#import <Scribbler/Scribbler.h>

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, LFWebServiceDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
    mbFliperViews* fliper;
//    AppDelegate *appDelegate;
    BOOL authorizationPending;
}

@property Boolean frontIsFlipped;
@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSImageView *albumart;

@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSTextField *txtAlbum;
@property (weak) IBOutlet NSTextField *txtArtist;
@property (weak) IBOutlet NSButtonCell *playBtn;

@property (weak) IBOutlet NSTextField *txtSongTitle;
@property (weak) IBOutlet NSView *hostView;
@property (strong) IBOutlet NSView *frontView;
@property (strong) IBOutlet NSView *backView;
@property (weak) IBOutlet NSSlider *playerProgressBar;
- (IBAction)flipToBack:(id)sender;
@property (weak) IBOutlet NSButton *quitApp;
- (IBAction)flipToFront:(id)sender;
@property (weak) IBOutlet NSTextFieldCell *txtEslapsedTime;
@property (weak) IBOutlet NSTextFieldCell *txtRemainingTime;
- (IBAction)freeChick:(id)sender;
@property (weak) IBOutlet NSPopUpButton *preferedPlayerBtn;
@property (weak) IBOutlet NSButton *flipBtn;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (void)updateInformation:(ADTrack*) currentTrack;
- (void)updatePlayerProgressBar:(double) position;
- (IBAction)playerBarDidChange:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)prevSong:(id)sender;
- (IBAction)nextSong:(id)sender;
- (IBAction)toggleLaunchAtLogin:(id)sender;
@property (weak) IBOutlet NSButton *launchAtLoginBtn;

@property (weak) IBOutlet NSButton *seeHowBtn;


@property (weak) IBOutlet NSButton *chikBtn;


@property (weak) IBOutlet NSTextField *authStatus;
@property (weak) IBOutlet NSProgressIndicator *authSpinner;
@property (weak) IBOutlet NSButton *authConnectButton;

@property (strong, nonatomic)NSString *currentTrackID;
@property (nonatomic) BOOL wasPlaying;
@property (strong, nonatomic) LFTrack *curentLFTrack;
// UI methods
- (void)showAuthConnectPane;
- (void)showAuthPreAuthPane;
- (void)showAuthWaitingPane;
- (void)showAuthValidatingPane;
- (void)showAuthConnectedPaneWithUser:(NSString *)username;


// Log methods
- (void)log:(NSString *)format, ...;

@property (weak) IBOutlet NSButton *toggleLoveBtnChk;
- (IBAction)toggleLoveBtn:(id)sender;

// Authorization methods
- (void)connectWithStoredCredentials;
- (IBAction)connectWithLastFM:(id)sender;
- (IBAction)disconnectFromLastFM:(id)sender;
- (IBAction)completeAuthorization:(id)sender;
- (IBAction)openManagementPage:(id)sender;

// Track methods
//- (IBAction)startPlayingTrack:(id)sender;
//- (IBAction)scrobbleTrack:(id)sender;
//- (IBAction)loveTrack:(id)sender;
//- (IBAction)banTrack:(id)sender;
- (void) loveTrack;


// Web service delegate methods
- (void)sessionNeedsAuthorizationViaURL:(NSURL *)theURL;
- (void)sessionAuthorizationStillPending;
- (void)sessionAuthorizationFailed;
- (void)sessionCreatedWithKey:(NSString *)theKey user:(NSString *)theUser;

- (void)sessionValidatedForUser:(NSString *)theUser;
- (void)sessionInvalidForUser:(NSString *)theUser;
- (void)sessionKeyRevoked:(NSString *)theKey forUser:(NSString *)theUser;

- (void)scrobblerHandshakeSucceeded;
- (void)scrobblerHandshakeFailed:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)scrobblerClient:(NSString *)theClientID bannedForVersion:(NSString *)theClientVersion;
- (void)scrobblerRejectedSystemTime;

- (void)nowPlayingSucceededForTrack:(LFTrack *)theTrack;
- (void)scrobbleSucceededForTrack:(LFTrack *)theTrack;
- (void)loveSucceededForTrack:(LFTrack *)theTrack;
- (void)banSucceededForTrack:(LFTrack *)theTrack;

- (void)nowPlayingFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)scrobbleFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)loveFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)banFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;

- (IBAction)goToFacebook:(id)sender;
- (IBAction)goToTwitter:(id)sender;
- (IBAction)goToHomePage:(id)sender;

@property (assign) bool enableChik;
- (void) unhideChik;
-(void) toggleFlipBtnWith: (BOOL) value;
@end

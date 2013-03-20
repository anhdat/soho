#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "ADTrack.h"
#import "FrontView.h"
#import "BackView.h"

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

- (IBAction)flipToBack:(id)sender {
    if (_frontIsFlipped) {
        [fliper flipRight:nil];
        _frontIsFlipped = NO;
    } else {
        [fliper flipLeft:nil];
        _frontIsFlipped
        = YES;
    }
}

- (IBAction)flipToFront:(id)sender {
    [fliper flipRight:nil];
    _frontIsFlipped = NO;
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
    
    if (NSIsEmptyRect(searchRect))
    {
        [self.hostView setHidden:YES];
    }
    else
    {
        [self.hostView setFrame:searchRect];
        [self.hostView setHidden:NO];
    }
    
    NSRect textRect = [self.textField frame];
    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    textRect.origin.x = SEARCH_INSET;
    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - NSHeight(searchRect);
    textRect.origin.y = SEARCH_INSET;
    
    if (NSIsEmptyRect(textRect))
    {
        [self.textField setHidden:YES];
    }
    else
    {
        [self.textField setFrame:textRect];
        [self.textField setHidden:NO];
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

- (void)runSearch
{
    NSString *searchFormat = @"";
    NSString *searchString = [self.searchField stringValue];
    if ([searchString length] > 0)
    {
        searchFormat = NSLocalizedString(@"Search for ‘%@’…", @"Format for search request");
    }
    NSString *searchRequest = [NSString stringWithFormat:searchFormat, searchString];
    [self.textField setStringValue:searchRequest];
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
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
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
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
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
//    NSImage *songArtwork;
    NSImage *artwork = [currentTrack artwork];
    if(artwork == nil){
         artwork = [NSImage imageNamed:@"Sample.tiff"];
    }
    [_albumart setImage:artwork];
    if ([[currentTrack album] length] > 0) {
        [_txtSongTitle setStringValue:[currentTrack name]];
    }
    
    if ([[currentTrack album] length] > 0) {
        [_txtAlbum setStringValue:[currentTrack album]];
    }
    if ([[currentTrack album] length] > 0) {
        [_txtArtist setStringValue:[currentTrack artist]];
    }

}


- (void)updatePlayerProgressBar:(double) position{
    [_playerProgressBar setDoubleValue:position];
}
- (IBAction)slideDidChangeValue:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewSet" object:nil];
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

@end

#import "BackgroundView.h"
#import "StatusItemView.h"
#import "iTunes.h"
#import "mbFliperViews.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
    mbFliperViews* fliper;
    Boolean frontIsFlipped;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSImageView *albumart;

@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSTextField *txtArtistAlbum;
@property (weak) IBOutlet NSTextField *txtSongTitle;
@property (weak) IBOutlet NSSlider *slideViewSize;
@property (weak) IBOutlet NSView *hostView;
@property (strong) IBOutlet NSView *frontView;
@property (strong) IBOutlet NSView *backView;
@property (weak) IBOutlet NSSlider *playerProgressBar;
- (IBAction)flipToBack:(id)sender;
- (IBAction)flipToFront:(id)sender;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (void)updateInformation:(iTunesTrack*) currentTrack;
- (void)updatePlayerProgressBar:(double) position;
- (IBAction)slideDidChangeValue:(id)sender;
- (IBAction)playerBarDidChange:(id)sender;

@end

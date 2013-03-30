//
//  Chick.h
//  Maori
//
//  Created by Dat Anh Truong on 3/21/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ADTrack.h"
@class Chick;
@protocol ChickDelegate <NSObject>

- (void)scrollWheel:(NSEvent *)theEvent;

@end
@interface Chick : NSWindowController
@property (weak) IBOutlet NSView *chickView;
@property (weak) IBOutlet NSView *controlView;

@property (weak) IBOutlet NSImageView *albumArt;
@property (weak) IBOutlet NSTextField *txtArtist;
@property (weak) IBOutlet NSTextField *txtSongTitle;
@property (weak) IBOutlet NSButton *playBtn;
@property (nonatomic) BOOL isSticked;
@property (nonatomic) bool hasLyrics;
- (IBAction)playPause:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)prevTrack:(id)sender;
- (IBAction)toggleStick:(id)sender;


@property (weak) IBOutlet NSButton *stickBtn;

@property (unsafe_unretained) IBOutlet NSTextView *lyricsTextView;
@property (weak) IBOutlet NSView *lyricsView;
@property (weak) IBOutlet NSView *titleView;
@property (weak) IBOutlet NSButton *lyricsBtn;
@property (weak) IBOutlet NSTextField *letterL;
- (IBAction)loveTrack:(id)sender;

- (void)updateInformation:(ADTrack*) currentTrack;

- (IBAction)returnToMom:(id)sender;
- (IBAction) toggleLyrics:(id)sender;
@property(assign) id <ChickDelegate> chickProtocolDelegate;
@end

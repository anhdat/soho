//
//  Chick.m
//  Maori
//
//  Created by Dat Anh Truong on 3/21/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "Chick.h"
#import "AppDelegate.h"
#define WINDOW_DOCKING_DISTANCE 	12

@interface Chick (){
}

@end

@implementation Chick
- (IBAction)playPause:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPause" object:nil];
}

- (IBAction)nextTrack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextSong" object:nil];
}

- (IBAction)prevTrack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"prevSong" object:nil];
}

- (IBAction)toggleStick:(id)sender {
    if (!_hasLyrics) {
        if (_isSticked) {
            [_stickBtn setImage:[NSImage imageNamed:@"SoHo_chick_stick_alt"]];
        } else {
            [_stickBtn setImage:[NSImage imageNamed:@"SoHo_chick_stick"]];
        }
    }
    if (_isSticked) {
        [self setIsSticked:NO];
    } else {
        [self setIsSticked:YES];
    }
}

- (IBAction)loveTrack:(id)sender {
    AppDelegate *appDelegateObject = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegateObject loveTrack:nil];
}

- (void)updateInformation:(ADTrack*) currentTrack{
    NSSize artSize = [_albumArt frame].size;
    NSImage *artwork = [[currentTrack artwork] copy];
    
    if(artwork == nil){
        artwork = [NSImage imageNamed:@"Sample.tiff"];
    }
    [artwork setSize:artSize];
    [_albumArt setImage:artwork];
    if ([[currentTrack name] length] > 0) {
        [_txtSongTitle setStringValue:[currentTrack name]];
    } else {
        [_txtSongTitle setStringValue:@""];
    }
    if ([[currentTrack artist] length] > 0) {
        [_txtArtist setStringValue:[currentTrack artist]];
    } else {
        [_txtArtist setStringValue:@""];
    }
    if ([[currentTrack lyrics] length] > 0) {
        [_lyricsTextView setString:[currentTrack lyrics]];
        [self setHasLyrics:YES];
    } else {
        [_lyricsTextView setString:@""];
        [self setHasLyrics:NO];
    }
    NSImage *playButtonImage = [NSImage imageNamed:[[currentTrack playerState] isEqualToString:@"Play"]? @"SoHo_chick_pause" : @"SoHo_chick_play"];
    [_playBtn setImage:playButtonImage];
    if (_hasLyrics) {
        [_stickBtn setImage:[NSImage imageNamed:@"SoHo_chick_lyrics"]];
        [_letterL setHidden:NO];
    } else {
        [[_lyricsView animator] setHidden:YES];
        [_letterL setHidden:YES];
        if (_isSticked) {
            [_stickBtn setImage:[NSImage imageNamed:@"SoHo_chick_stick_alt"]];
        } else {
            [_stickBtn setImage:[NSImage imageNamed:@"SoHo_chick_stick"]];
        }
    }
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [window setMovableByWindowBackground:YES];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setLevel:NSScreenSaverWindowLevel + 1];
    [[self window] orderFront:nil];
    
    [_lyricsTextView setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.9]];
    AppDelegate *appDelegateObject = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegateObject TrackDidChange:nil];
    CALayer *layer = [CALayer layer];
    [layer setContents:_titleView];
    [_titleView setWantsLayer:YES];
    CALayer *lyricsLayer = [CALayer layer];
    [lyricsLayer setContents:_lyricsView];
    [_lyricsView setWantsLayer:YES];
    
    NSTrackingAreaOptions trackingOptions;
    NSTrackingArea *trackArea;
    trackingOptions =
    NSTrackingEnabledDuringMouseDrag
    | NSTrackingMouseEnteredAndExited
    | NSTrackingActiveAlways;
    
    if (trackArea != nil) {
        trackArea = nil;
    }
    trackArea = [[NSTrackingArea alloc]
                 initWithRect:[_controlView bounds]
                 options:trackingOptions
                 owner:self
                 userInfo:nil];
    [_controlView addTrackingArea:trackArea];
    
    [_titleView setHidden:YES];
    [_lyricsView setHidden:YES];
    [self setIsSticked:NO];
    [self setHasLyrics:NO];
}

- (IBAction)returnToMom:(id)sender {
    [[self window] close];
}

- (IBAction) toggleLyrics:(id)sender{
    if (_hasLyrics) {
        if ([_lyricsView isHidden]) {
            [[_lyricsView animator] setHidden:NO];
            [[_titleView animator] setHidden:NO];
        } else {
            [[_lyricsView animator] setHidden:YES];
            if (!_isSticked) {
                [[_titleView animator] setHidden:YES];
            }
        }
    }
}

- (void)scrollWheel:(NSEvent *)theEvent{
    if ([theEvent deltaY] < 0) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"volumeUp"
         object:nil ];
    }
    if ([theEvent deltaY] > 0) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"volumeDown"
         object:nil ];
    }
}


- (void)mouseEntered:(NSEvent *)theEvent{
    [[_titleView animator] setHidden:NO];
}


- (void)mouseExited:(NSEvent *)theEvent{
    if ([_lyricsView isHidden]) {
        if (!_isSticked) {
            [[_titleView animator] setHidden:YES];
        }
    } else {
        [[_titleView animator] setHidden:NO];
    }
}



@end

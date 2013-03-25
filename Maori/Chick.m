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

- (void)updateInformation:(ADTrack*) currentTrack{
    NSImage *artwork = [currentTrack artwork];
    if(artwork == nil){
        artwork = [NSImage imageNamed:@"Sample.tiff"];
    }
    [_albumArt setImage:artwork];
    if ([[currentTrack name] length] > 0) {
        [_txtSongTitle setStringValue:[currentTrack name]];
    }
    if ([[currentTrack artist] length] > 0) {
        [_txtArtist setStringValue:[currentTrack artist]];
    }
    if ([[currentTrack lyrics] length] > 0) {
        [_lyricsTextView setString:[currentTrack lyrics]];
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
}

- (IBAction)returnToMom:(id)sender {
//    [[self window] setIsVisible:NO];
    [[self window] close];
}

- (void) toggleLyrics{
    if ([_lyricsView isHidden]) {
        [[_lyricsView animator] setHidden:NO];
        [[_titleView animator] setHidden:NO];
    } else {
        [[_lyricsView animator] setHidden:YES];
        [[_titleView animator] setHidden:YES];
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



@end

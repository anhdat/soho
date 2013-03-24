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
}

- (IBAction)nextTrack:(id)sender {
}

- (IBAction)prevTrack:(id)sender {
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
        // Initialization code here.
        [window setMovableByWindowBackground:YES];
        NSLog(@"init");
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
}

- (IBAction)returnToMom:(id)sender {
//    [[self window] setIsVisible:NO];
    [[self window] close];
}

- (void) toggleLyrics{
    NSLog(@"toggle");
    if ([_lyricsView isHidden]) {
        [_lyricsView setHidden:NO];
    } else {
        [_lyricsView setHidden:YES];
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

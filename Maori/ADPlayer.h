//
//  ADPlayer.h
//  Maori
//
//  Created by Dat Anh Truong on 3/14/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "Spotify.h"
enum PlayerType {
	PlayerTypeITunes = 'i',
	PlayerTypeSpotify = 's'
};
typedef enum PlayerType PlayerType;
@interface ADPlayer : NSObject

@property (nonatomic) NSInteger playerID;
@property (strong, nonatomic) iTunesApplication *iTunesApp;
@property (strong, nonatomic) SpotifyApplication *spotifyApp;

@property (assign) PlayerType type;
@property (assign) SBApplication *nativeApp;
-(void) nextTrack;
-(void) prevTrack;
-(void) playPause;
-(NSString*) getName;

@end

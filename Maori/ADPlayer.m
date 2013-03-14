//
//  ADPlayer.m
//  Maori
//
//  Created by Dat Anh Truong on 3/14/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "ADPlayer.h"

@implementation ADPlayer

-(id)init{
    _playerID = 1;
    _iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	_spotifyApp = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    return self;
}

-(void) nextTrack{
    switch (_playerID) {
        case 1:
            [_iTunesApp nextTrack];
            break;
        case 2:
            [_spotifyApp nextTrack];
            break;
        default:
            break;
    }
}

-(void) prevTrack{
    switch (_playerID) {
        case 1:
            [_iTunesApp previousTrack];
            break;
        case 2:
            [_spotifyApp previousTrack];
            break;
        default:
            break;
    }
}


-(void) playPause{
    switch (_playerID) {
        case 1:
            [_iTunesApp playpause];
            break;
        case 2:
            [_spotifyApp playpause];
            break;
        default:
            break;
    }
}

-(NSString*) getName{
    _iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	_spotifyApp = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    switch (_playerID) {
        case 1:
            return [[_iTunesApp currentTrack] name];
            break;
        case 2:
            NSLog(@"Name is%@", [[_spotifyApp currentTrack] name]);
            return [[_spotifyApp currentTrack] name];
            break;
        default:
            break;
    }
    return nil;
}

- (ADPlayer *)initWithPlayerType:(PlayerType)playerType {
//	[super init];
	self.type = playerType;
	if (self.type == PlayerTypeITunes) {
		self.nativeApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	} else if (self.type == PlayerTypeSpotify) {
		self.nativeApp = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	}
	return self;
}

- (BOOL)isRunning {
	return [self.nativeApp isRunning];
}

//- (BOOL)isPlaying {
//	if (self.type == PlayerTypeITunes) {
//		return [self.nativeApp playerState] == iTunesEPlSPlaying;
//	} else if (self.type == PlayerTypeSpotify) {
//		return [self.nativeApp playerState] == SpotifyEPlSPlaying;
//	}
//	return NO;
//}

//- (PlayerTrack *)currentTrack {
//	return [[[PlayerTrack alloc] init:[self.nativeApp currentTrack]
//								 withPlayerType:self.type] autorelease];
//}

- (NSString *)name {
	if (self.type == PlayerTypeITunes) {
		return @"iTunes";
	} else if (self.type == PlayerTypeSpotify) {
		return @"Spotify";
	}
	return @"";
}

+ (ADPlayer *)getActivePlayer {
	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if ( [iTunes isRunning] || [spotify isRunning] ) {
		if ( [spotify isRunning] && [spotify playerState] == SpotifyEPlSPlaying ) {
			return [[ADPlayer alloc] initWithPlayerType:PlayerTypeSpotify];
		} else if ( [iTunes isRunning] ) {
			return [[ADPlayer alloc] initWithPlayerType:PlayerTypeITunes];
		} else {
			return [[ADPlayer alloc] initWithPlayerType:PlayerTypeSpotify];
		}
	}
	return nil;
}


@end

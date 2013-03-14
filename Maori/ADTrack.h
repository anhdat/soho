//
//  ADTrack.h
//  Maori
//
//  Created by Dat Anh Truong on 3/14/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTrack : NSObject

// General attributes
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *album;
@property (strong, nonatomic) NSImage *artwork;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) double duration;

// iTunes attributes
@property (nonatomic)  NSInteger rating;

// Spotify attributes
@property (nonatomic) BOOL starred;
@property (strong, nonatomic) NSString *url;
@property (nonatomic) BOOL isAdvertisement;

@end

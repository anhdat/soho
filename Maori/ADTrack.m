//
//  ADTrack.m
//  Maori
//
//  Created by Dat Anh Truong on 3/14/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "ADTrack.h"

@implementation ADTrack

-(id)init{
    self = [super init];
    if (self){
        _album = NULL;
        _artist = NULL;
        _name = NULL;
        _duration = 1;
        _rating = 0;
        _starred = NO;
        _isAdvertisement = NO;
    }
    return self;
}

@end

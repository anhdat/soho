//
//  StatusView.m
//  Maori
//
//  Created by Dat Anh Truong on 2/28/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
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

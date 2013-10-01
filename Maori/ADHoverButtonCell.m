//
//  ADHoverButtonCell.m
//  SoHo
//
//  Created by Dat Anh Truong on 9/30/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "ADHoverButtonCell.h"

@interface ADHoverButtonCell(){
}

@property (strong, nonatomic) NSImage *oldImage;

@end

@implementation ADHoverButtonCell

@synthesize hoverImage = _hoverImage;


//- (NSImage *) hoverImage {
//    if (_hoverImage == nil) {
//        _hoverImage = [NSImage imageNamed:@"bt_donate_2.tiff"];
//    }
//    return _hoverImage;
//}


- (void)mouseEntered:(NSEvent *)event {
    if (_hoverImage != nil && [_hoverImage isValid]) {
        _oldImage = [(NSButton *)[self controlView] image] ;
        [(NSButton *)[self controlView] setImage:_hoverImage];
    }
}

- (void)mouseExited:(NSEvent *)event {
    if (_oldImage != nil && [_oldImage isValid]) {
        [(NSButton *)[self controlView] setImage:_oldImage];
        _oldImage = nil;
    }
}

- (void)_updateMouseTracking {
    if ([self controlView] != nil && [[self controlView] respondsToSelector:@selector(_setMouseTrackingForCell:)]) {
        [[self controlView] performSelector:@selector(_setMouseTrackingForCell:) withObject:self];
    }
}

- (void)setHoverImage:(NSImage *)newImage {
    _hoverImage = newImage;
    [[self controlView] setNeedsDisplay:YES];
}


@end

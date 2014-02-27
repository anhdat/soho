//
//  TourButtonCell.m
//  SoHo
//
//  Created by Dat Truong on 2/28/14.
//  Copyright (c) 2014 Dat Anh Truong. All rights reserved.
//

#import "TourButtonCell.h"
#import "HexColor.h"
@implementation TourButtonCell

- (void) setColorWithhexString:(NSString *) hexString alpha:(float) alpha
{
    NSColor *color = [NSColor colorWithHexString:hexString alpha:alpha];
    
    NSMutableAttributedString *colorTitle =
    
    [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    
    [self setAttributedTitle:colorTitle];
}

- (void)mouseEntered:(NSEvent *)event {
//    1E90FF
    [self setColorWithhexString:@"1E90FF" alpha:1.0];
}

- (void)mouseExited:(NSEvent *)event {
    [self setColorWithhexString:@"C6E2FF" alpha:1.0];
}

- (void)_updateMouseTracking {
    if ([self controlView] != nil && [[self controlView] respondsToSelector:@selector(_setMouseTrackingForCell:)]) {
        [[self controlView] performSelector:@selector(_setMouseTrackingForCell:) withObject:self];
    }
}

- (void)setHoverImage:(NSImage *)newImage {
    
    [[self controlView] setNeedsDisplay:YES];
}

@end

//
//  JKSMoviePlayerSliderCell.m
//  Maori
//
//  Created by Dat Anh Truong on 3/13/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "JKSMoviePlayerSliderCell.h"
#ifndef NSCOLOR
#define NSCOLOR(r, g, b, a) [NSColor colorWithCalibratedRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#endif

@implementation JKSMoviePlayerSliderCell

- (NSRect)knobRectFlipped:(BOOL)flipped
{
    NSRect knobRect = [super knobRectFlipped:flipped];
    knobRect.origin.x += 6;
    knobRect.origin.y += 7.5;
    knobRect.size.height = 8;
    knobRect.size.width = 8;
    return knobRect;
}


- (void)drawKnob:(NSRect)knobRect
{
    NSBezierPath *outerPath = [NSBezierPath bezierPathWithOvalInRect:knobRect];
    NSGradient *outerGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(193, 193, 193, 1), NSCOLOR(120, 120, 120, 1)]];
    [outerGradient drawInBezierPath:outerPath angle:90];
    NSBezierPath *innerPath = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(knobRect, 2, 2)];
    NSGradient *innerGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(154, 154, 154, 1), NSCOLOR(127, 127, 127, 1)]];
    [innerGradient drawInBezierPath:innerPath angle:90];
}


- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    NSRect sliderRect = aRect;
    sliderRect.origin.y += (NSMaxY(sliderRect) / 2) - 4;
    sliderRect.origin.x += 2;
    sliderRect.size.width -= 4;
    sliderRect.size.height = 11;
    
    NSBezierPath *barPath = [NSBezierPath bezierPathWithRoundedRect:sliderRect xRadius:4 yRadius:4];
    NSGradient *borderGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(3, 3, 3, 1), NSCOLOR(23, 23, 23, 1)]];
    [borderGradient drawInBezierPath:barPath angle:90];
    NSBezierPath *innerPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(sliderRect, 1, 1) xRadius:4 yRadius:4];
    [NSCOLOR(13, 13, 13, 1) setFill];
    [innerPath fill];
}


@end

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
//-(void)setNeedsDisplayInRect:(NSRect)invalidRect{
//    [super setNeedsDisplayInRect:[self bounds]];
//}

- (NSRect)knobRectFlipped:(BOOL)flipped
{
    NSRect knobRect = [super knobRectFlipped:flipped];
    knobRect.origin.x += 6;
    knobRect.origin.y += 7.5;
    knobRect.size.height = 8;
    knobRect.size.width = 8;
    return knobRect;
}


- (void) drawKnob:(NSRect)knobRect{
    
}

//
//- (void)drawKnob:(NSRect)knobRect
//{
//    NSBezierPath *outerPath = [NSBezierPath bezierPathWithOvalInRect:knobRect];
//    NSGradient *outerGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(193, 193, 193, 1), NSCOLOR(120, 120, 120, 1)]];
//    [outerGradient drawInBezierPath:outerPath angle:90];
//    NSBezierPath *innerPath = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(knobRect, 2, 2)];
//    NSGradient *innerGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(154, 154, 154, 1), NSCOLOR(127, 127, 127, 1)]];
//    [innerGradient drawInBezierPath:innerPath angle:90];
//}


- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    NSRect sliderRect = aRect;
    sliderRect.origin.y += (NSMaxY(sliderRect) / 2) - 4;
    sliderRect.origin.x += 2;
    sliderRect.size.width -= 4;
    sliderRect.size.height = 8;
   
    NSBezierPath *barPath = [NSBezierPath bezierPathWithRoundedRect:sliderRect xRadius:4 yRadius:4];
    NSGradient *borderGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(13, 13, 13, 0.3), NSCOLOR(26, 26, 26, 0.3)]];
    [borderGradient drawInBezierPath:barPath angle:30];
    
    NSBezierPath *innerPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(sliderRect, 1, 1) xRadius:4 yRadius:4];
    [NSCOLOR(250, 250, 250, 0.7) setFill];
    
    [innerPath fill];
    
    
    NSRect knobRect = [self knobRectFlipped:flipped];
    CGFloat fillWidth = (NSMaxX(knobRect));
    NSRect fillRect= NSMakeRect(sliderRect.origin.x, sliderRect.origin.y, fillWidth, sliderRect.size.height);
//    fillRect.origin.x = sliderRect.origin.x;
//    fillRect.origin.y = sliderRect.origin.y;
    
//    NSBezierPath *fillBarPath = [NSBezierPath bezierPathWithRoundedRect:fillRect xRadius:4 yRadius:4];
//    NSGradient *fillBorderGradient = [[NSGradient alloc] initWithColors:@[NSCOLOR(3, 3, 3, 1), NSCOLOR(23, 23, 23, 1)]];
//    [fillBorderGradient drawInBezierPath:fillBarPath angle:90];
//
    NSBezierPath *fillInnerPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(fillRect, 1, 1) xRadius:4 yRadius:4];
    [NSCOLOR(255, 165, 0, 1) setFill];
    [fillInnerPath fill];
    
    
    
//    [[NSColor whiteColor] setFill];
//    NSRectFill(fillRect);
}


@end

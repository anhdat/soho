//
//  NSColor+CGColor.h
//  Maori
//
//  Created by Dat Anh Truong on 6/30/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//  Based on code of Michael Sanders
//  at https://gist.github.com/msanders/707921
//

#import <Cocoa/Cocoa.h>

@interface NSColor (CGColor)

//
// The Quartz color reference that corresponds to the receiver's color.
//
@property (nonatomic, readonly) CGColorRef CGColor;

//
// Converts a Quartz color reference to its NSColor equivalent.
//
+ (NSColor *)colorWithCGColor:(CGColorRef)color;



@end

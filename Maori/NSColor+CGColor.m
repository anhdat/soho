//
//  NSColor+CGColor.m
//  Maori
//
//  Created by Dat Anh Truong on 6/30/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "NSColor+CGColor.h"

@implementation NSColor (CGColor)

- (CGColorRef)CGColor
{
    const NSInteger numberOfComponents = [self numberOfComponents];
    CGFloat components[numberOfComponents];
    CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
    
    [self getComponents:(CGFloat *)&components];
    
    return (CGColorRef) CGColorCreate(colorSpace, components);
}

+ (NSColor *)colorWithCGColor:(CGColorRef)CGColor
{
    if (CGColor == NULL) return nil;
    return [NSColor colorWithCIColor:[CIColor colorWithCGColor:CGColor]];
}

@end

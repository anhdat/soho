//
//  BackTabView.m
//  Maori
//
//  Created by Dat Anh Truong on 4/1/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import "BackTabView.h"

@implementation BackTabView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)event{
    
    if ([event clickCount] > 1) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"doubleClick"
         object:nil ];
    }}
@end

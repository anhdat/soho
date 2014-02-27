//
//  TourWindowController.m
//  SoHo
//
//  Created by Dat Truong on 2/27/14.
//  Copyright (c) 2014 Dat Anh Truong. All rights reserved.
//

#import "TourWindowController.h"

@interface TourWindowController ()

@end

@implementation TourWindowController
@synthesize imageView;
@synthesize laterBtnCell;
@synthesize knowBtnCell;
@synthesize tourNextBtn;
@synthesize tourPrevBtn;
@synthesize tourTextFieldCell;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setLevel:NSScreenSaverWindowLevel + 1];
    [[self window] orderFront:nil];
    [self.window setBackgroundColor:[NSColor whiteColor]];
    
    [self.laterBtnCell setColorWithhexString:@"C6E2FF" alpha:1.0];
    [self.knowBtnCell setColorWithhexString:@"C6E2FF" alpha:1.0];
    
    [self.tourNextBtn setHoverImage:[NSImage imageNamed:@"tour_right_hover"]];
    [self.tourPrevBtn setHoverImage:[NSImage imageNamed:@"tour_left_hover"]];
}

@end

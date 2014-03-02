//
//  TourWindowController.m
//  SoHo
//
//  Created by Dat Truong on 2/27/14.
//  Copyright (c) 2014 Dat Anh Truong. All rights reserved.
//

#import "TourWindowController.h"

@interface TourWindowController ()

@property (strong, nonatomic) NSArray *imageNames;
@property (strong, nonatomic) NSArray *guideStrings;

@property NSUInteger currentStep;

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
    
    [self.laterBtnCell setColorWithhexString:@"DEDEDE" alpha:1.0];
    [self.knowBtnCell setColorWithhexString:@"DEDEDE" alpha:1.0];
    
    [self.tourNextBtn setHoverImage:[NSImage imageNamed:@"tour_right_hover"]];
    [self.tourPrevBtn setHoverImage:[NSImage imageNamed:@"tour_left_hover"]];
    
    self.imageNames = @[@"drag.gif", @"play.gif", @"volume.gif", @"control.gif", @"contextMenu.gif"];
    self.guideStrings = @[@"Start by dragging\nSoHo menu icon to the left.",
                          @"Get something to play on iTunes\nor Spotify, Rdio, Radium.",
                          @"Change Volume\nby scrolling up or down.",
                          @"Go the next or previous track\nby scrolling left of right.",
                          @"Use two fingers tap or right mouse click two open SoHo Quick Menu"
                          ];
    [self updateCurrentStep];
}

- (void) updateCurrentStep
{
    if (self.currentStep == 0) {
        [self.tourPrevBtn setEnabled:NO];
    } else {
        [self.tourPrevBtn setEnabled:YES];
    }
    if (self.currentStep == self.imageNames.count - 1) {
        [self.tourNextBtn setEnabled:NO];
    } else {
        [self.tourNextBtn setEnabled:YES];
    }
    
    [self.imageView setImage:[NSImage imageNamed:self.imageNames[self.currentStep]]];
    [self.tourTextFieldCell setStringValue:self.guideStrings[self.currentStep]];
}



- (IBAction)nextGuide:(id)sender {
    self.currentStep++;
    [self updateCurrentStep];
}

- (IBAction)prevGuide:(id)sender {
    self.currentStep--;
    [self updateCurrentStep];
}
@end

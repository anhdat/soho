//
//  TourWindowController.h
//  SoHo
//
//  Created by Dat Truong on 2/27/14.
//  Copyright (c) 2014 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TourButtonCell.h"
#import "ADHoverButtonCell.h"
#import "TourTextFieldCell.h"

@interface TourWindowController : NSWindowController {
    __weak NSImageView *imageView;
    __weak TourButtonCell *laterBtnCell;
    __weak TourButtonCell *knowBtnCell;
    __weak ADHoverButtonCell *tourNextBtn;
    __weak ADHoverButtonCell *tourPrevBtn;
    __weak TourTextFieldCell *tourTextFieldCell;
}

@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet TourButtonCell *laterBtnCell;
@property (weak) IBOutlet TourButtonCell *knowBtnCell;
@property (weak) IBOutlet ADHoverButtonCell *tourNextBtn;
@property (weak) IBOutlet ADHoverButtonCell *tourPrevBtn;
@property (weak) IBOutlet TourTextFieldCell *tourTextFieldCell;

@end

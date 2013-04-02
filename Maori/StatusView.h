//
//  StatusView.h
//  Maori
//
//  Created by Dat Anh Truong on 2/28/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class STTDHSwipeIndicator;
@interface StatusView : NSView
@property (weak) IBOutlet NSImageView *nextArrow;
@property (retain) STTDHSwipeIndicator *swipeIndicator;
@end

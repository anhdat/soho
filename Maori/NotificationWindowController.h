//
//  NotificationWindowController.h
//  Maori
//
//  Created by Dat Anh Truong on 4/2/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NotificationWindowController : NSWindowController
@property (assign) bool isOpen;
@property (weak) IBOutlet NSImageView *notiImageView;

@property (weak) IBOutlet NSTextField *notiText;
-(IBAction)showNotification:(id)sender withImageNamed:(NSString *) imageName withText:(NSString*) text withTime: (float) time;
@end

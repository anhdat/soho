//
//  AppDelegate.h
//  Maori
//
//  Created by Dat Anh Truong on 2/27/13.
//  Copyright (c) 2013 Dat Anh Truong. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>{
    iTunesApplication *iTunesApp;
}
@property (nonatomic, strong) NSStatusItem *controllerItem;
//@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *mainView;
@property (weak) IBOutlet NSView *view1;
@property (weak) IBOutlet NSView *view2;
@property (weak) IBOutlet NSView *volumeView;

@end

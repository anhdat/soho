#import <Cocoa/Cocoa.h>
#import "StatusView.h"
#import "STTDHSwipeClipView.h"

@interface STTDHSwipeIndicator : NSView {
    StatusView *webView;
    STTDHSwipeClipView *clipView;
}

@property (retain) StatusView *webView;
@property (retain) STTDHSwipeClipView *clipView;

- (id)initWithWebView:(StatusView *)aWebView;

@end

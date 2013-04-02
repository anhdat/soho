#import <Cocoa/Cocoa.h>
#import "FrontView.h"
#import "FrontDHSwipeClipView.h"

@interface FrontDHSwipeIndicator : NSView {
    FrontView *webView;
    FrontDHSwipeClipView *clipView;
}

@property (retain) FrontView *webView;
@property (retain) FrontDHSwipeClipView *clipView;

- (id)initWithWebView:(FrontView *)aWebView;

@end

#import <Cocoa/Cocoa.h>
#import "RoundedView.h"
#import "DHSwipeClipView.h"

@interface DHSwipeIndicator : NSView {
//    RoundedView *webView;
//    DHSwipeClipView *clipView;
}

@property (retain) RoundedView *webView;
@property (retain) DHSwipeClipView *clipView;

- (id)initWithWebView:(RoundedView *)aWebView;

@end

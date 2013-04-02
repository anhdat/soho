#import <Cocoa/Cocoa.h>
#import "RoundedView.h"

@interface DHSwipeClipView : NSClipView {
    CGFloat currentSum;
    NSTimer *drawTimer;
    BOOL canGoLeft;
    BOOL canGoRight;
    RoundedView *webView;
    BOOL isHandlingEvent;
    BOOL _haveAdditionalClip;
    NSRect _additionalClip;
    CGFloat scrollDeltaX;
    CGFloat scrollDeltaY;
}

@property (retain) NSTimer *drawTimer;
@property (assign) CGFloat currentSum;
@property (retain) RoundedView *webView;
@property (assign) BOOL isHandlingEvent;

- (id)initWithFrame:(NSRect)frame webView:(RoundedView *)aWebView;

@end

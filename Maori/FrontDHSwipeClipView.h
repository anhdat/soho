#import <Cocoa/Cocoa.h>
#import "FrontView.h"

@interface FrontDHSwipeClipView : NSClipView {
    CGFloat currentSum;
    NSTimer *drawTimer;
    BOOL canGoLeft;
    BOOL canGoRight;
    FrontView *webView;
    BOOL isHandlingEvent;
    BOOL _haveAdditionalClip;
    NSRect _additionalClip;
    CGFloat scrollDeltaX;
    CGFloat scrollDeltaY;
}

@property (retain) NSTimer *drawTimer;
@property (assign) CGFloat currentSum;
@property (retain) FrontView *webView;
@property (assign) BOOL isHandlingEvent;

- (id)initWithFrame:(NSRect)frame webView:(FrontView *)aWebView;

@end

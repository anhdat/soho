#import "STTDHSwipeIndicator.h"

@implementation STTDHSwipeIndicator

@synthesize webView;
@synthesize clipView;

#define kSwipeMinimumLength 0.3

- (id)initWithWebView:(StatusView *)aWebView
{
    self = [self initWithFrame:NSMakeRect(0, 0, aWebView.frame.size.width, aWebView.frame.size.height/5)];
    if(self)
    {
        self.webView = aWebView;
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self setWantsLayer:YES];
        [aWebView addSubview:self];
        self.clipView = [[STTDHSwipeClipView alloc] initWithFrame:[webView frame] webView:webView];
        [self.webView addSubview:clipView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(clipView.currentSum != 0 && clipView.isHandlingEvent)
    {
        CGFloat sum = clipView.currentSum;
        NSRect drawRect = NSZeroRect;
        CGFloat absoluteSum = fabsf(sum);
        CGFloat percent = (absoluteSum) / kSwipeMinimumLength;
        percent = (percent > 1.0) ? 1.0 : percent;
        
        CGFloat alphaPercent = (percent == 1.0) ? 1.0 : (percent <= 0.7) ? percent : 0.7f;
        if(sum < 0)
        {
            drawRect = NSMakeRect(0-(49-49*percent), 1, 49*percent, 1);
            NSRect frame = NSIntegralRect(drawRect);
            [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alphaPercent] setFill];
            NSRectFill(frame);
            
        }
        else
        {
            drawRect = NSMakeRect(self.frame.size.width-(49*percent), 1, 49*percent, 1);
            NSRect frame = drawRect;
            [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alphaPercent] setFill];
            NSRectFill(frame);
        }
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    return nil;
}

@end

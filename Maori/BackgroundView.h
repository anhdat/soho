#define ARROW_WIDTH 12
#define ARROW_HEIGHT 8
@class FrontDHSwipeIndicator;
@interface BackgroundView : NSView
{
    NSInteger _arrowX;
}

@property (nonatomic, assign) NSInteger arrowX;
@property (nonatomic) double tintLevel;
//@property (retain) FrontDHSwipeIndicator *swipeIndicator;
@end

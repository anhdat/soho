#import "StatusItemView.h"
#import "AppDelegate.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
        _isDragging = NO;
    }
    return self;
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);

	[icon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

- (void)mouseDragged:(NSEvent *)theEvent{
   
    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    
    if (abs(currentLocation.x) > 10) {
        AppDelegate *appDelegateObject = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [[appDelegateObject panelController] closePanel];
        
        // Begin a dragging session.
         _isDragging = YES;
        
        if (!_logoToDrag) {
            _logoToDrag = [[DragLogo alloc] initWithWindowNibName:@"DragLogo"];
        }
        //
        NSRect screenVisibleFrame = [[NSScreen mainScreen] frame];
        
        
        
        // get mouse location
        NSPoint mouseLoc;
        mouseLoc = [NSEvent mouseLocation];
        
        // show window
        [_logoToDrag showWindow:nil];
        [[_logoToDrag window] setFrameOrigin:NSMakePoint(mouseLoc.x, screenVisibleFrame.size.height-22)];
        
        // calculate new width
        _width = [[NSUserDefaults standardUserDefaults] doubleForKey:@"width"];
        _width += - currentLocation.x;
        if (_width<1) {
            _width = 1;
        }
        if (_width > 300) {
            _width = 300;
        }

    }
    
    
}
- (void) mouseUp:(NSEvent *)theEvent{
    if (_isDragging) {
        // Call appdelegate to update new width.
        [[NSUserDefaults standardUserDefaults] setDouble:_width forKey:@"width"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewSet" object:nil];
        [_logoToDrag close];
        
        // Mark icon to be unactive.
        AppDelegate *appDelegateObject = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        appDelegateObject.menubarController.hasActiveIcon = !appDelegateObject.menubarController.hasActiveIcon;
        appDelegateObject.panelController.hasActivePanel = appDelegateObject.menubarController.hasActiveIcon;
        
        // End a dragging session.
        _isDragging = NO;
    }
    
}

- (void)scrollWheel:(NSEvent *)theEvent{
    if ([theEvent isDirectionInvertedFromDevice]) {
        if ([theEvent deltaY] < 0) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"volumeUp"
             object:nil ];
        }
        if ([theEvent deltaY] > 0) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"volumeDown"
             object:nil ];
        }
        
    } else {
        if ([theEvent deltaY] > 0) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"volumeUp"
             object:nil ];
        }
        if ([theEvent deltaY] < 0) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"volumeDown"
             object:nil ];
        }
        
    }
    
}


#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end

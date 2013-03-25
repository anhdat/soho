#import "MenubarController.h"
#import "StatusItemView.h"

@implementation MenubarController

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
        
        
        NSImage *statusIcon = [NSImage imageNamed:@"SoHo_statusBar_icon_normal"];
        NSSize imageSize = {[statusIcon size].width*(18.0/[statusIcon size].width), [statusIcon size].height*(18.0/[statusIcon size].height) };
        [statusIcon setSize:imageSize];
        _statusItemView.image = statusIcon;
        
        
        NSImage *statusIconAlt = [NSImage imageNamed:@"SoHo_statusBar_icon_hightlighted"];
        NSSize imageSizeAlt = {[statusIconAlt size].width*(18.0/[statusIconAlt size].width), [statusIconAlt size].height*(18.0/[statusIconAlt size].height) };
        [statusIconAlt setSize:imageSizeAlt];
        _statusItemView.alternateImage = statusIconAlt;
        _statusItemView.action = @selector(togglePanel:);
    }
    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}

@end

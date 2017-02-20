/*
 *  File           UN9AppDelegate
 *  Author         AutoMessage
 *  Created Time   2016-04-06
 *  Description    AutoMessage应用的AppDeleagte
 *
 *  Copyright (C) 2016 AutoMessage. All Rights Reserved.
 */

#import "UN9AppDelegate.h"

#import "UN9LaunchViewController.h"

/**
 *  AutoMessage主窗口
 */
@interface UN9KeyWindow : NSWindow

@end

@implementation UN9KeyWindow

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end

@interface UN9AppDelegate ()

@property (nonatomic, strong) NSWindow *window;

/*
@property (strong) NSURL *plistURL;

@property (strong) NSMutableArray *plistArray;

@property (strong) NSMutableArray *appleScriptDeliverArray;

@property (strong) NSMutableArray *appleScriptChangeAccoutArray;
*/
 
@end

@implementation UN9AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window = [[UN9KeyWindow alloc] initWithContentRect:NSZeroRect
                                                  styleMask:NSWindowStyleMaskBorderless
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    
    self.window.opaque                    = NO;
    self.window.movable                   = YES;
    self.window.movableByWindowBackground = YES;
    self.window.releasedWhenClosed        = NO;
    self.window.backgroundColor           = [NSColor clearColor];
    self.window.contentViewController     = [[UN9LaunchViewController alloc] init];
    
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (flag) {
        UN9LaunchViewController *lauchViewController = (UN9LaunchViewController *)self.window.contentViewController;
        
        [lauchViewController handleWindowReopen];
        
        return YES;
    }

    return NO;
}

@end

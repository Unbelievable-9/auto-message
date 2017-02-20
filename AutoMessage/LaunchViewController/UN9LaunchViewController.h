/*
 *  File           UN9LaunchViewController
 *  Author         AutoMessage
 *  Created Time   2016-05-01
 *  Description    AutoMessage项目，启动界面
 *
 *  Copyright (C) 2016 AutoMessage. All Rights Reserved.
 */

#import <Cocoa/Cocoa.h>

@interface UN9LaunchViewController : NSViewController

@property (strong) IBOutlet NSVisualEffectView *activationView;
@property (strong) IBOutlet NSVisualEffectView *appleIDSetupView;
@property (strong) IBOutlet NSVisualEffectView *iMessageSetupView;

- (void)handleWindowReopen;

@end

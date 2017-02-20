/*
 *  File           UN9LaunchViewController
 *  Author         AutoMessage
 *  Created Time   2016-05-01
 *  Description    AutoMessage项目，启动界面
 *
 *  Copyright (C) 2016 AutoMessage. All Rights Reserved.
 */

#import "UN9LaunchViewController.h"

#import "UN9MainViewController.h"

@interface UN9LaunchViewController ()

@property (weak) IBOutlet NSTextField *activationCodeTextField;

@property (weak) IBOutlet NSTextField *appleIDInfoTipsLabel;
@property (weak) IBOutlet NSButton *selectAppleIDInfoPlistButton;
@property (weak) IBOutlet NSButton *goToiMessageSetupButton;

@property (weak) IBOutlet NSTextField *iMessageInfoTipsLabel;
@property (weak) IBOutlet NSButton *selectiMessageInfoPlistButton;
@property (weak) IBOutlet NSButton *goToMainViewButton;

@end

@implementation UN9LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSRect bounds = self.view.bounds;
    
    self.activationView.maskImage = [NSImage imageWithSize:bounds.size
                                                   flipped:YES
                                            drawingHandler:^BOOL(NSRect dstRect) {
                                                NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds
                                                                                                     xRadius:5
                                                                                                     yRadius:5];
                                                [path fill];
                                                return YES;
                                            }];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Activate_App_Before"]) {
        self.appleIDSetupView.maskImage = [NSImage imageWithSize:bounds.size
                                                         flipped:YES
                                                  drawingHandler:^BOOL(NSRect dstRect) {
                                                      NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds
                                                                                                           xRadius:5
                                                                                                           yRadius:5];
                                                      [path fill];
                                                      return YES;
                                                  }];
        
        self.appleIDSetupView.alphaValue = 0;
        
        self.iMessageSetupView.maskImage = [NSImage imageWithSize:bounds.size
                                                          flipped:YES
                                                   drawingHandler:^BOOL(NSRect dstRect) {
                                                       NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds
                                                                                                            xRadius:5
                                                                                                            yRadius:5];
                                                       [path fill];
                                                       return YES;
                                                   }];
        
        self.iMessageSetupView.alphaValue = 0;
    } else {
        for (NSView *subview in self.activationView.subviews) {
            if (subview.tag > 100) {
                subview.alphaValue = 0;
            }
        }
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Activate_App_Before"]) {
        if ([self.view isEqual:self.activationView]) {
            self.activationView.alphaValue = 1.0;
            
            [NSThread sleepForTimeInterval:1.0];
            
            self.activationView.alphaValue = 0;
            
            UN9MainViewController *controller = [[UN9MainViewController alloc] init];
            
            [self presentViewControllerAsModalWindow:controller];
        }
    }
}

- (void)handleWindowReopen {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Activate_App_Before"]) {
        self.activationView.alphaValue = 1.0;
        
        [NSThread sleepForTimeInterval:1.0];
        
        self.activationView.alphaValue = 0;
        
        UN9MainViewController *controller = [[UN9MainViewController alloc] init];
        
        [self presentViewControllerAsModalWindow:controller];
    }
}

- (IBAction)tapToActivateWith:(id)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Serial_Number"
                                                         ofType:@"txt"];
    
    NSString *serialNumerString = [NSString stringWithContentsOfFile:filePath
                                                            encoding:NSUTF8StringEncoding
                                                               error:nil];
    
    NSArray *serialNumberArray = [serialNumerString componentsSeparatedByString:@"\n"];
    
    BOOL isValidSerailNumber = NO;
    
    for (int i = 0; i < serialNumberArray.count; i++) {
        NSString *serailItemString = serialNumberArray[i];
        
        if ([serailItemString isEqualToString:self.activationCodeTextField.stringValue]) {
            isValidSerailNumber = YES;
        }
    }
    
    if (isValidSerailNumber) {
        self.view            = self.appleIDSetupView;
        self.view.alphaValue = 1.0;
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Activate_App_Before"];
    } else {
        NSAlert *wrongActivationCodeAlert = [[NSAlert alloc] init];
        
        [wrongActivationCodeAlert setMessageText:@"提示"];
        [wrongActivationCodeAlert setInformativeText:@"输入的激活码无效，请重新输入"];
        [wrongActivationCodeAlert addButtonWithTitle:@"确定"];
        [wrongActivationCodeAlert runModal];
    }
}

- (IBAction)tapToSelectAppleIDInfoPlistWith:(id)sender {
    NSOpenPanel *openPanel         = [NSOpenPanel openPanel];
    openPanel.canChooseFiles       = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowedFileTypes     = @[@"plist"];
    openPanel.directoryURL         = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory
                                                                            inDomain:NSUserDomainMask
                                                                   appropriateForURL:nil
                                                                              create:YES
                                                                               error:nil];
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *fileURL = [openPanel URLs];
            
            if (fileURL.count > 0) {
                NSURL *firtFileURL = fileURL[0];
                
                if ([[firtFileURL lastPathComponent] isEqualToString:@"AppleID_Info.plist"]) {
                    NSArray *appleIDInfArray = [[NSArray alloc] initWithContentsOfURL:fileURL[0]];
                    
                    if (appleIDInfArray.count > 0) {
                        [[NSUserDefaults standardUserDefaults] setObject:appleIDInfArray forKey:@"Apple_ID_Info_Array"];
                        [[NSUserDefaults standardUserDefaults] setObject:@(-1) forKey:@"Used_AppleID_Index"];
                        
                        self.appleIDInfoTipsLabel.stringValue = [NSString stringWithFormat:@"已添加了 %lu 个Apple ID", (unsigned long)appleIDInfArray.count];
                        self.appleIDInfoTipsLabel.hidden      = NO;
                        
                        self.selectAppleIDInfoPlistButton.hidden  = YES;
                        self.selectAppleIDInfoPlistButton.enabled = NO;
                        
                        self.goToiMessageSetupButton.hidden  = NO;
                        self.goToiMessageSetupButton.enabled = YES;
                    }
                } else {
                    NSAlert *wrongAppleIDPlistAlert = [[NSAlert alloc] init];
                    
                    [wrongAppleIDPlistAlert setMessageText:@"提示"];
                    [wrongAppleIDPlistAlert setInformativeText:@"选择的Plist文件错误"];
                    [wrongAppleIDPlistAlert addButtonWithTitle:@"确定"];
                    [wrongAppleIDPlistAlert runModal];
                }
            }
        }
    }];
}

- (IBAction)tapToShowMessageSetupViewWith:(id)sender {
    self.view            = self.iMessageSetupView;
    self.view.alphaValue = 1.0;
}

- (IBAction)tapToSelectContactInfoTXTWith:(id)sender {
    NSOpenPanel *openPanel         = [NSOpenPanel openPanel];
    openPanel.canChooseFiles       = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowedFileTypes     = @[@"txt"];
    openPanel.directoryURL         = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory
                                                                            inDomain:NSUserDomainMask
                                                                   appropriateForURL:nil
                                                                              create:YES
                                                                               error:nil];
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *fileURL = [openPanel URLs];
            
            if (fileURL.count > 0) {
                NSURL *firtFileURL = fileURL[0];
                
                if ([[firtFileURL lastPathComponent] isEqualToString:@"iMessage_Contact.txt"]) {
                    NSString *contantNumberString = [NSString stringWithContentsOfURL:firtFileURL
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
                    
                    NSArray *contactnfoArray = [contantNumberString componentsSeparatedByString:@"\n"];
                    
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:contactnfoArray];
                    
                    for (int i = 0; i < contactnfoArray.count; i++) {
                        NSString *itemString = contactnfoArray[i];
                        
                        if ([itemString isEqualToString:@""]) {
                            [tempArray removeObject:itemString];
                        }
                    }
                    
                    contactnfoArray = tempArray;
                    
                    if (contactnfoArray.count > 0) {
                        [[NSUserDefaults standardUserDefaults] setObject:contactnfoArray forKey:@"iMessage_Info_Array"];
                        
                        self.iMessageInfoTipsLabel.stringValue = [NSString stringWithFormat:@"已添加了 %lu 个iMessage联系人", (unsigned long)contactnfoArray.count];
                        self.iMessageInfoTipsLabel.hidden      = NO;
                        
                        self.selectiMessageInfoPlistButton.hidden  = YES;
                        self.selectiMessageInfoPlistButton.enabled = NO;
                        
                        self.goToMainViewButton.hidden  = NO;
                        self.goToMainViewButton.enabled = YES;
                    }
                } else {
                    NSAlert *wrongContantTxtFileAlert = [[NSAlert alloc] init];
                    
                    [wrongContantTxtFileAlert setMessageText:@"提示"];
                    [wrongContantTxtFileAlert setInformativeText:@"选择的Plist文件错误"];
                    [wrongContantTxtFileAlert addButtonWithTitle:@"确定"];
                    [wrongContantTxtFileAlert runModal];
                }
            }
        }
    }];
}

- (IBAction)tapToGoToMainViewWith:(id)sender {
    self.view.alphaValue = 0;
    
    UN9MainViewController *controller = [[UN9MainViewController alloc] init];
    
    [self presentViewControllerAsModalWindow:controller];
}

@end

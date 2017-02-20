/*
 *  File           UN9MainViewController
 *  Author         AutoMessage
 *  Created Time   2016-05-20
 *  Description    AutoMessage主视图，主要进行发送和切换ID的工作
 *
 *  Copyright (C) 2016 AutoMessage. All Rights Reserved.
 */

#import "UN9MainViewController.h"

#import "UN9IntegerNumberFormatter.h"

@interface UN9MainViewController () <NSAlertDelegate>

@property (strong) IBOutlet NSVisualEffectView *mainView;

@property (weak) IBOutlet NSTextField *inputMessageContentTextField;

@property (weak) IBOutlet NSButton *sendButton;

@property (weak) IBOutlet NSTextField *regionNumberTextfield;
@property (weak) IBOutlet NSTextField *startNumberTextField;
@property (weak) IBOutlet NSTextField *endNumberTextfield;

@property (weak) IBOutlet NSTextField *messageChangeLimitTextField;

@property (weak) IBOutlet NSTextField *sendingTimeTextField;
@property (weak) IBOutlet NSSlider    *sendingTimeSlider;


@property (strong) NSArray *appleIDInfoArray;
@property (strong) NSArray *iMessageInfoArray;

@property (strong) NSMutableArray *customeNumberArray;

@property (strong) NSMutableArray *appleScriptDeliverArray;
@property (strong) NSMutableArray *appleScriptChangeAccoutArray;

@end

@implementation UN9MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSRect bounds = self.view.bounds;
    
    self.mainView.maskImage = [NSImage imageWithSize:bounds.size
                                                   flipped:YES
                                            drawingHandler:^BOOL(NSRect dstRect) {
                                                NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds
                                                                                                     xRadius:5
                                                                                                     yRadius:5];
                                                [path fill];
                                                return YES;
                                            }];
    
    
    self.inputMessageContentTextField.textColor = [NSColor blueColor];
    
    self.customeNumberArray = [[NSMutableArray alloc] init];
    
    self.appleScriptDeliverArray      = [[NSMutableArray alloc] init];
    self.appleScriptChangeAccoutArray = [[NSMutableArray alloc] init];
    
    UN9IntegerNumberFormatter *formatter = [[UN9IntegerNumberFormatter alloc] init];
    
    self.startNumberTextField.formatter = formatter;
    self.endNumberTextfield.formatter   = formatter;
    
    self.messageChangeLimitTextField.formatter = formatter;
    
    [self.sendingTimeSlider setTarget:self];
    [self.sendingTimeSlider setAction:@selector(swipeToChangeValueForSlider:)];
    
    self.sendingTimeTextField.formatter = formatter;
    
    [self.sendingTimeTextField setTarget:self];
    [self.sendingTimeTextField setAction:@selector(sendTimeChangeWithTextField:)];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    self.mainView.window.title                     = @"AutoMessage";
    self.mainView.window.opaque                    = NO;
    self.mainView.window.movable                   = YES;
    self.mainView.window.movableByWindowBackground = YES;
    self.mainView.window.releasedWhenClosed        = NO;
}

#pragma mark - Selectors
- (IBAction)tapToReselectAppleIDInfoWith:(id)sender {
    NSOpenPanel *openPanel         = [NSOpenPanel openPanel];
    openPanel.canChooseFiles       = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowedFileTypes     = @[@"plist"];
    openPanel.directoryURL         = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory
                                                                            inDomain:NSUserDomainMask
                                                                   appropriateForURL:nil
                                                                              create:YES
                                                                               error:nil];
    
    self.mainView.window.alphaValue = 0;
    
    [openPanel beginSheetModalForWindow:self.mainView.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *fileURL = [openPanel URLs];
            
            if (fileURL.count > 0) {
                NSURL *firtFileURL = fileURL[0];
                
                if ([[firtFileURL lastPathComponent] isEqualToString:@"AppleID_Info.plist"]) {
                    NSArray *appleIDInfArray = [[NSArray alloc] initWithContentsOfURL:fileURL[0]];
                    
                    if (appleIDInfArray.count > 0) {
                        [[NSUserDefaults standardUserDefaults] setObject:appleIDInfArray forKey:@"Apple_ID_Info_Array"];
                        [[NSUserDefaults standardUserDefaults] setObject:@(-1) forKey:@"Used_AppleID_Index"];
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
        
        self.mainView.window.alphaValue = 1.0;
    }];
}

- (IBAction)tapToReselectContantInfoWith:(id)sender {
    if (self.inputMessageContentTextField.stringValue == nil ||
        [self.inputMessageContentTextField.stringValue isEqualToString:@""]) {
        NSAlert *noInputContentAlert = [[NSAlert alloc] init];
        
        [noInputContentAlert setMessageText:@"提示"];
        [noInputContentAlert setInformativeText:@"在重新选择联系人之前, 请输入需要发送的内容！"];
        [noInputContentAlert addButtonWithTitle:@"确定"];
        [noInputContentAlert runModal];
        
        return;
    }
    
    NSOpenPanel *openPanel         = [NSOpenPanel openPanel];
    openPanel.canChooseFiles       = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowedFileTypes     = @[@"txt"];
    openPanel.directoryURL         = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory
                                                                            inDomain:NSUserDomainMask
                                                                   appropriateForURL:nil
                                                                              create:YES
                                                                               error:nil];
    self.mainView.window.alphaValue = 0;
    
    [openPanel beginSheetModalForWindow:self.mainView.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *fileURL = [openPanel URLs];
            
            if (fileURL.count > 0) {
                NSURL *firtFileURL = fileURL[0];
                
                if ([[firtFileURL lastPathComponent] isEqualToString:@"iMessage_Contact.txt"]) {
                    self.sendButton.enabled = NO;
                    
                    __weak __typeof(self) weakSelf = self;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
                            
                            self.iMessageInfoArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"iMessage_Info_Array"];
                            
                            [self.appleScriptDeliverArray removeAllObjects];
                            
                            for (int i = 0; i < weakSelf.iMessageInfoArray.count; i++) {
                                NSString *contantString = weakSelf.iMessageInfoArray[i];
                                
                                NSString *appleScriptSource = [weakSelf generateAppleScriptSourceWithPhoneNumber:contantString
                                                                                                     WithContent:weakSelf.inputMessageContentTextField.stringValue
                                                                                                WithSeparateTime:weakSelf.sendingTimeTextField.stringValue
                                                                                           WithHomeDirectoryPath:NSHomeDirectory()];
                                
                                NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:appleScriptSource];
                                
                                NSDictionary *complieErrorInfo = [NSDictionary dictionary];
                                
                                if ([appleScript compileAndReturnError:&complieErrorInfo]) {
                                    [weakSelf.appleScriptDeliverArray addObject:appleScript];
                                } else {
                                    NSLog(@"\nError:%@\n", complieErrorInfo);
                                }
                            }
                        }
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            weakSelf.sendButton.enabled = YES;
                        });
                    });
                } else {
                    NSAlert *wrongContactTxtFileAlert = [[NSAlert alloc] init];
                    
                    [wrongContactTxtFileAlert setMessageText:@"提示"];
                    [wrongContactTxtFileAlert setInformativeText:@"选择的Plist文件错误"];
                    [wrongContactTxtFileAlert addButtonWithTitle:@"确定"];
                    [wrongContactTxtFileAlert runModal];
                }
            }
        }
        
        self.mainView.window.alphaValue = 1.0;
    }];
}

- (IBAction)tapToConfirmNumberSettingWith:(id)sender {
    if (self.inputMessageContentTextField.stringValue == nil ||
        [self.inputMessageContentTextField.stringValue isEqualToString:@""]) {
        NSAlert *noInputContentAlert = [[NSAlert alloc] init];
        
        [noInputContentAlert setMessageText:@"提示"];
        [noInputContentAlert setInformativeText:@"请输入需要发送的内容！"];
        [noInputContentAlert addButtonWithTitle:@"确定"];
        [noInputContentAlert runModal];
        
        return;
    }
    
    if (self.regionNumberTextfield.stringValue == nil ||
        [self.regionNumberTextfield.stringValue isEqualToString:@""]) {
        NSAlert *noRegionNumberAlert = [[NSAlert alloc] init];
        
        [noRegionNumberAlert setMessageText:@"提示"];
        [noRegionNumberAlert setInformativeText:@"请输入国际区号！"];
        [noRegionNumberAlert addButtonWithTitle:@"确定"];
        [noRegionNumberAlert runModal];
        
        return;
    }
    
    if (self.startNumberTextField.stringValue == nil ||
        [self.startNumberTextField.stringValue isEqualToString:@""]) {
        NSAlert *noStartNumberAlert = [[NSAlert alloc] init];
        
        [noStartNumberAlert setMessageText:@"提示"];
        [noStartNumberAlert setInformativeText:@"请输入号码段起始号码！"];
        [noStartNumberAlert addButtonWithTitle:@"确定"];
        [noStartNumberAlert runModal];
        
        return;
    }
    
    if (self.endNumberTextfield.stringValue == nil ||
        [self.endNumberTextfield.stringValue isEqualToString:@""]) {
        NSAlert *noEndNumberAlert = [[NSAlert alloc] init];
        
        [noEndNumberAlert setMessageText:@"提示"];
        [noEndNumberAlert setInformativeText:@"请输入号码段终止号码！"];
        [noEndNumberAlert addButtonWithTitle:@"确定"];
        [noEndNumberAlert runModal];
        
        return;
    }
    
    NSInteger startTelNumber = self.startNumberTextField.stringValue.integerValue;
    NSInteger endTelNumber   = self.endNumberTextfield.stringValue.integerValue;
    
    if (endTelNumber < startTelNumber) {
        NSAlert *endNumberErrorAlert = [[NSAlert alloc] init];
        
        [endNumberErrorAlert setMessageText:@"提示"];
        [endNumberErrorAlert setInformativeText:@"输入的终止号码小于起始号码！"];
        [endNumberErrorAlert addButtonWithTitle:@"确定"];
        [endNumberErrorAlert runModal];
        
        return;
    } else {
        if (endTelNumber - startTelNumber >= 500) {
            NSString *tipsString = [NSString stringWithFormat:@"确定要发送%ld条信息吗?!",endTelNumber - startTelNumber];
            
            NSAlert *tooManyNumbersTipAlert = [[NSAlert alloc] init];
            
            [tooManyNumbersTipAlert setMessageText:@"提示"];
            [tooManyNumbersTipAlert setInformativeText:tipsString];
            [tooManyNumbersTipAlert addButtonWithTitle:@"确定"];
            [tooManyNumbersTipAlert addButtonWithTitle:@"重新选择号码段"];
            
            [tooManyNumbersTipAlert beginSheetModalForWindow:self.view.window
                                           completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertFirstButtonReturn) {
                    [self compileSendingAcitonAppleScript];
                } else if (returnCode == NSAlertSecondButtonReturn) {
                    self.startNumberTextField.stringValue = @"";
                    self.endNumberTextfield.stringValue   = @"";
                }
            }];
            
            return;
        }
    }
    
    [self compileSendingAcitonAppleScript];
}

- (IBAction)tapToSendiMessage:(id)sender {
    if (self.inputMessageContentTextField.stringValue != nil &&
        ![self.inputMessageContentTextField.stringValue isEqualToString:@""]) {
        __weak __typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            int changeAppleIDLimit = 500;
            
            if (weakSelf.messageChangeLimitTextField.stringValue != nil &&
                ![weakSelf.messageChangeLimitTextField.stringValue isEqualToString:@""]) {
                changeAppleIDLimit = weakSelf.messageChangeLimitTextField.stringValue.intValue;
            }
            
            if (weakSelf.appleScriptDeliverArray.count <= changeAppleIDLimit) {
                for (int i = 0; i < weakSelf.appleScriptDeliverArray.count; i++) {
                    NSAppleScript *appleScript = weakSelf.appleScriptDeliverArray[i];
                    
                    NSDictionary *executeErrorInfo = [NSDictionary dictionary];
                    
                    [appleScript executeAndReturnError:&executeErrorInfo];
                    
                    if (executeErrorInfo.allKeys.count != 0) {
                        NSLog(@"\nError:%@\n", executeErrorInfo);
                    } else {
                        
                    }
                }
            } else {                
                [weakSelf controlSendingProcessByLimitWithProcessCount:0];
            }
        });
    } else {
        NSAlert *noInputContentAlert = [[NSAlert alloc] init];
        
        [noInputContentAlert setMessageText:@"提示"];
        [noInputContentAlert setInformativeText:@"请输入需要发送的内容！"];
        [noInputContentAlert addButtonWithTitle:@"确定"];
        [noInputContentAlert runModal];
    }
}

- (IBAction)tapToChangeAppleID:(id)sender {
    self.appleIDInfoArray  = [[NSUserDefaults standardUserDefaults] objectForKey:@"Apple_ID_Info_Array"];
    
    NSNumber *currentUsedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"Used_AppleID_Index"];
    
    NSDictionary *appleIDInfoDict = nil;
    
    if (currentUsedIndex.integerValue != -1) {
        if (currentUsedIndex.integerValue + 1 < self.appleIDInfoArray.count) {
            appleIDInfoDict = self.appleIDInfoArray[currentUsedIndex.integerValue + 1];
            
            [[NSUserDefaults standardUserDefaults] setObject:@(currentUsedIndex.integerValue + 1) forKey:@"Used_AppleID_Index"];
        } else {
            appleIDInfoDict = self.appleIDInfoArray[0];
            
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"Used_AppleID_Index"];
        }
    } else {
        appleIDInfoDict = self.appleIDInfoArray[0];
        
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"Used_AppleID_Index"];
    }
    
    if (appleIDInfoDict) {
        [self compileAndRunChangingAppleIDAppleScriptWithAppleIDInfoDict:appleIDInfoDict];
    }
}

- (void)swipeToChangeValueForSlider:(NSSlider *)slider {
    self.sendingTimeTextField.stringValue = [NSString stringWithFormat:@"%.0f", slider.stringValue.floatValue];
}

- (void)sendTimeChangeWithTextField:(NSTextField *)textField {
    self.sendingTimeSlider.stringValue = textField.stringValue;
}

#pragma mark - AppleScript Generator
- (NSString *)generateAppleScriptSourceWithPhoneNumber:(NSString *)phoneNumber
                                           WithContent:(NSString *)content
                                      WithSeparateTime:(NSString *)separateTimeString
                                 WithHomeDirectoryPath:(NSString *)path {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AppleScript-Source-Template"
                                                         ofType:@"txt"];
    
    NSString *sourceTemplate = [NSString stringWithContentsOfFile:filePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    
    NSString *fixedPhoneNumber = [NSString stringWithFormat:@"\"%@\"", phoneNumber];
    NSString *fixedContent     = [NSString stringWithFormat:@"\"%@\"", content];
    
    NSInteger randomTimeNumber = arc4random() % separateTimeString.integerValue;
    
    if (randomTimeNumber == 0) {
        randomTimeNumber = 5;
    }
    
    NSString *resultString = [NSString stringWithFormat:sourceTemplate,
                              fixedPhoneNumber,
                              fixedContent,
                              @(randomTimeNumber).stringValue,
                              path];
    
    return resultString;
}

- (NSString *)generateChangeAppleIDScriptWithAppleID:(NSString *)appleID
                                        WithPassword:(NSString *)password {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AppleScript-Change-AppleID"
                                                         ofType:@"txt"];
    
    NSString *changeAppleIDTemplate = [NSString stringWithContentsOfFile:filePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:nil];
    
    NSString *fixedAppleID = [NSString stringWithFormat:@"\"%@\"", appleID];
    NSString *fixedPassword     = [NSString stringWithFormat:@"\"%@\"", password];
    
    NSString *resultString = [NSString stringWithFormat:changeAppleIDTemplate,
                              fixedAppleID,
                              fixedPassword];
    
    return resultString;
}

#pragma mark - AppleScript Compile And Run Wrapper
- (void)compileSendingAcitonAppleScript {
    NSInteger startTelNumber = self.startNumberTextField.stringValue.integerValue;
    NSInteger endTelNumber   = self.endNumberTextfield.stringValue.integerValue;
    
    [self.customeNumberArray removeAllObjects];
    
    for (NSInteger i = startTelNumber; i <= endTelNumber; i++) {
        NSString *telNumberString = [NSString stringWithFormat:@"%@%ld", self.regionNumberTextfield.stringValue, (long)i];
        
        [self.customeNumberArray addObject:telNumberString];
        
        startTelNumber++;
    }
    
    
    [self.appleScriptDeliverArray removeAllObjects];
    
    self.sendButton.enabled = NO;
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < weakSelf.customeNumberArray.count; i++) {
            NSString *contantString = weakSelf.customeNumberArray[i];
            
            NSString *appleScriptSource = [weakSelf generateAppleScriptSourceWithPhoneNumber:contantString
                                                                                 WithContent:weakSelf.inputMessageContentTextField.stringValue
                                                                            WithSeparateTime:weakSelf.sendingTimeTextField.stringValue
                                                                       WithHomeDirectoryPath:NSHomeDirectory()];
            
            NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:appleScriptSource];
            
            NSDictionary *complieErrorInfo = [NSDictionary dictionary];
            
            if ([appleScript compileAndReturnError:&complieErrorInfo]) {
                [weakSelf.appleScriptDeliverArray addObject:appleScript];
            } else {
                NSLog(@"\nError:%@\n", complieErrorInfo);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sendButton.enabled = YES;
        });
    });
}

- (void)compileAndRunChangingAppleIDAppleScriptWithAppleIDInfoDict:(NSDictionary *)appleIDInfoDict {
    NSString *appleID         = [appleIDInfoDict objectForKey:@"ID"];
    NSString *appleIDPassword = [appleIDInfoDict objectForKey:@"Password"];
    
    NSString *appleScriptSource = [self generateChangeAppleIDScriptWithAppleID:appleID
                                                                  WithPassword:appleIDPassword];
    
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:appleScriptSource];
    
    __block NSDictionary *executeErrorInfo = [NSDictionary dictionary];
    
    __weak UN9MainViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *complieErrorInfo = [NSDictionary dictionary];
        
        if ([appleScript compileAndReturnError:&complieErrorInfo]) {
            [weakSelf.appleScriptChangeAccoutArray addObject:appleScript];
        } else {
            NSLog(@"\nError:%@\n", complieErrorInfo);
        }
        
        [appleScript executeAndReturnError:&executeErrorInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (executeErrorInfo.allKeys.count != 0) {
                NSLog(@"\nError:%@\n", executeErrorInfo);
            } else {
                
            }
        });
    });
}

- (void)interactSendingProcessByChangingAppleIDWithCompleteBlock:(void(^)(void))complete {
    self.appleIDInfoArray  = [[NSUserDefaults standardUserDefaults] objectForKey:@"Apple_ID_Info_Array"];
    
    NSNumber *currentUsedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"Used_AppleID_Index"];
    
    NSDictionary *appleIDInfoDict = nil;
    
    if (currentUsedIndex.integerValue != -1) {
        if (currentUsedIndex.integerValue + 1 < self.appleIDInfoArray.count) {
            appleIDInfoDict = self.appleIDInfoArray[currentUsedIndex.integerValue + 1];
            
            [[NSUserDefaults standardUserDefaults] setObject:@(currentUsedIndex.integerValue + 1) forKey:@"Used_AppleID_Index"];
        } else {
            appleIDInfoDict = self.appleIDInfoArray[0];
            
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"Used_AppleID_Index"];
        }
    } else {
        appleIDInfoDict = self.appleIDInfoArray[0];
        
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"Used_AppleID_Index"];
    }
    
    if (appleIDInfoDict) {
        NSString *appleID         = [appleIDInfoDict objectForKey:@"ID"];
        NSString *appleIDPassword = [appleIDInfoDict objectForKey:@"Password"];
        
        NSString *appleScriptSource = [self generateChangeAppleIDScriptWithAppleID:appleID
                                                                      WithPassword:appleIDPassword];
        
        NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:appleScriptSource];
        
        __block NSDictionary *executeErrorInfo = [NSDictionary dictionary];
        
        NSDictionary *complieErrorInfo = [NSDictionary dictionary];
        
        if ([appleScript compileAndReturnError:&complieErrorInfo]) {
            [self.appleScriptChangeAccoutArray addObject:appleScript];
        } else {
            NSLog(@"\nError:%@\n", complieErrorInfo);
        }
        
        [appleScript executeAndReturnError:&executeErrorInfo];
        
        if (executeErrorInfo.allKeys.count != 0) {
            NSLog(@"\nError:%@\n", executeErrorInfo);
        } else {
            complete();
        }
    }
}

- (void)controlSendingProcessByLimitWithProcessCount:(NSInteger)processCount {
    int changeAppleIDLimit = 500;
    
    if (self.messageChangeLimitTextField.stringValue != nil &&
        ![self.messageChangeLimitTextField.stringValue isEqualToString:@""]) {
        changeAppleIDLimit = self.messageChangeLimitTextField.stringValue.intValue;
    }
    
    NSInteger countOfSendingProcess = self.appleScriptDeliverArray.count / changeAppleIDLimit + 1;
    
    if (processCount == countOfSendingProcess) {
        return;
    } else {
        if (processCount != countOfSendingProcess - 1) {
            for (NSInteger i = processCount * changeAppleIDLimit; i < (processCount + 1) * changeAppleIDLimit; i++) {
                NSAppleScript *appleScript = self.appleScriptDeliverArray[i];
                
                NSDictionary *executeErrorInfo = [NSDictionary dictionary];
                
                [appleScript executeAndReturnError:&executeErrorInfo];
                
                if (executeErrorInfo.allKeys.count != 0) {
                    NSLog(@"\nError:%@\n", executeErrorInfo);
                } else {
                    
                }
            }
        } else {
            for (NSInteger i = processCount * changeAppleIDLimit; i < self.appleScriptDeliverArray.count; i++) {
                NSAppleScript *appleScript = self.appleScriptDeliverArray[i];
                
                NSDictionary *executeErrorInfo = [NSDictionary dictionary];
                
                [appleScript executeAndReturnError:&executeErrorInfo];
                
                if (executeErrorInfo.allKeys.count != 0) {
                    NSLog(@"\nError:%@\n", executeErrorInfo);
                } else {
                    
                }
            }
        }
        
        __weak __typeof(self) weakSelf = self;
        
        [self interactSendingProcessByChangingAppleIDWithCompleteBlock:^{
            [weakSelf controlSendingProcessByLimitWithProcessCount:processCount + 1];
        }];
    }
}

@end
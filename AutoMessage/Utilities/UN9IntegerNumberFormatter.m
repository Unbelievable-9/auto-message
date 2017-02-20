/*
 *  File           UN9IntegerNumberFormatter
 *  Author         AutoMessage
 *  Created Time   2016-06-02
 *  Description    整数类型NumberFormatter
 *
 *  Copyright (C) 2016 AutoMessage. All Rights Reserved.
 */

#import "UN9IntegerNumberFormatter.h"

#import <AppKit/AppKit.h>

@implementation UN9IntegerNumberFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString *__autoreleasing *)newString
            errorDescription:(NSString *__autoreleasing *)error {
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end

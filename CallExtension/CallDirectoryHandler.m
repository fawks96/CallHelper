//
//  CallDirectoryHandler.m
//  CallExtension
//
//  Created by  on 16/11/12.
//  Copyright © 2016年 fawks96. All rights reserved.
//

#import "CallDirectoryHandler.h"

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;
    
    if (![self addBlockingPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add blocking phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:1 userInfo:@{@"reason" : @"Unable to add blocking phone numbers"}];
        [context cancelRequestWithError:error];
        return;
    }
    
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add identification phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:@{@"reason" : @"Unable to add identification phone numbers"}];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

- (BOOL)addBlockingPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    // Retrieve phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
//    CXCallDirectoryPhoneNumber phoneNumbers[] = { 14085555555, 18005555555 };
//    NSUInteger count = (sizeof(phoneNumbers) / sizeof(CXCallDirectoryPhoneNumber));
//
//    for (NSUInteger index = 0; index < count; index += 1) {
//        CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[index];
//        [context addBlockingEntryWithNextSequentialPhoneNumber:phoneNumber];
//    }
    NSMutableArray <NSNumber *> *blackArr = [USER_DEFAULTS objectForKey:kBlackPhoneNumberStoreKey];
    for (NSNumber *numObj in blackArr) {
        [self createNewPhoneNumberFromPhoneNumber:[numObj unsignedLongLongValue] callBack:^(CXCallDirectoryPhoneNumber newPhoneNumber) {
            [context addBlockingEntryWithNextSequentialPhoneNumber:newPhoneNumber];
        }];
    }

    return YES;
}

- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
    
    NSData *data = [USER_DEFAULTS objectForKey:kLablePhoneNumberStoreKey];
    NSMutableArray <LablePhoneNumber *> *lableArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    for (LablePhoneNumber *lpn in lableArr) {
        [self createNewPhoneNumberFromPhoneNumber:lpn.phoneNumber callBack:^(CXCallDirectoryPhoneNumber newPhoneNumber) {
            [context addIdentificationEntryWithNextSequentialPhoneNumber:newPhoneNumber label:lpn.lable];
        }];
    }
    
    return YES;
}

- (NSString *)randTailNumber
{
    NSMutableString *randStr = [NSMutableString string];
    for (NSInteger i = 0; i < 7; i++) {
        [randStr appendFormat:@"%d",arc4random()%10];
    }
    
    return randStr;
}

- (void)createNewPhoneNumberFromPhoneNumber:(CXCallDirectoryPhoneNumber)aPhoneNumber callBack:(void (^)(CXCallDirectoryPhoneNumber newPhoneNumber))aCallBack
{
    NSString *phoneStr = [NSString stringWithFormat:@"86%lld",aPhoneNumber];
    if (aPhoneNumber < 10000) {
        for (NSInteger i=0; i<20000; i++) {
            NSString *newStr = [phoneStr stringByAppendingString:[self randTailNumber]];
            if (aCallBack) {
                CXCallDirectoryPhoneNumber newNum = [newStr longLongValue];
                aCallBack(newNum);
            }
        }
    }else{
        if (aCallBack) {
            CXCallDirectoryPhoneNumber newNum = [phoneStr longLongValue];
            aCallBack(newNum);
        }
    }
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occured while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
    
    NSLog(@"%@",error);
}

@end

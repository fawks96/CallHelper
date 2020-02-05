//
//  LablePhoneNumber.m
//  CallHelper
//
//  Created by  on 16/11/12.
//  Copyright © 2016年 fawks96. All rights reserved.
//

#import "LablePhoneNumber.h"

@implementation LablePhoneNumber


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *propertyArr = @[@"phoneNumber", @"lable"];
    
    for (NSString *keyName in propertyArr) {
        NSString *value = [self valueForKeyPath:keyName];
        if (value == nil) {
            NSLog(@"%@是空的",keyName);
        }
        [aCoder encodeObject:value forKey:keyName];
    }
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *propertyArr = @[@"phoneNumber", @"lable"];
    if (self = [super init]) {
        for (NSString *keyName in propertyArr) {
            if ([aDecoder containsValueForKey:keyName]) {
                id value = [aDecoder decodeObjectForKey:keyName];
                if(!value){
                    NSLog(@"%@是空的",keyName);
                }
                [self setValue:value forKeyPath:keyName];
            }
        }
    }
    return self;
}

@end

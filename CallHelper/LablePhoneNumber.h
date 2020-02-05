//
//  LablePhoneNumber.h
//  CallHelper
//
//  Created by  on 16/11/12.
//  Copyright © 2016年 fawks96. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

@interface LablePhoneNumber : NSObject <NSCoding>

@property (nonatomic,assign)CXCallDirectoryPhoneNumber phoneNumber;
@property (nonatomic,copy)NSString *lable;

@end

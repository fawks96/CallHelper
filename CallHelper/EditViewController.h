//
//  EditViewController.h
//  CallHelper
//
//  Created by  on 16/11/12.
//  Copyright © 2016年 fawks96. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditViewControllerDelegate;

@interface EditViewController : UIViewController

@property (nonatomic,assign)id<EditViewControllerDelegate> delegate;

@end


@protocol EditViewControllerDelegate <NSObject>

@optional
- (void)editViewController:(EditViewController *)aVC didAddPhoneNumber:(NSString *)aPhoneNumber lable:(NSString *)aLbl;

@end

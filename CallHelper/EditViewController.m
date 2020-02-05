//
//  EditViewController.m
//  CallHelper
//
//  Created by  on 16/11/12.
//  Copyright © 2016年 fawks96. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()<UITextFieldDelegate> {
}
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTf;
@property (strong, nonatomic) IBOutlet UISwitch *blackSwitch;
@property (strong, nonatomic) IBOutlet UITextField *lableTf;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
- (IBAction)onConfirm:(id)sender;
- (IBAction)onPhoneNumberChanged:(id)sender;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _confirmBtn.layer.cornerRadius = 4.0;
    _confirmBtn.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showMessage:(NSString *)aMsg
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onConfirm:(id)sender {
    
    if (_phoneNumberTf.text.length == 0 ||
        (_phoneNumberTf.text.length != 4 &&
        _phoneNumberTf.text.length != 11) ) {
        [self showMessage:@"请输入完整手机号码或前4位"];
        return;
    }
    
    if (![_phoneNumberTf.text hasPrefix:@"1"]) {
        [self showMessage:@"手机号码有误"];
        return;
    }
    
    if (!_blackSwitch.isOn) {
        if (!_lableTf.text.length) {
            [self showMessage:@"请输入标记内容"];
            return;
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(editViewController:didAddPhoneNumber:lable:)]) {
        [_delegate editViewController:self didAddPhoneNumber:_phoneNumberTf.text lable:_blackSwitch.isOn?nil:_lableTf.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPhoneNumberChanged:(id)sender {
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger newLen = textField.text.length-range.length+string.length;
    if (newLen > 11) {
        return NO;
    }
    
    return YES;
}

@end

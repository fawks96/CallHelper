//
//  ViewController.m
//  CallHelper
//
//  Created by  on 16/11/12.
//  Copyright © 2016年 fawks96. All rights reserved.
//

#import "ViewController.h"
#import <CallKit/CallKit.h>
#import "EditViewController.h"


@interface ViewController ()<EditViewControllerDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    NSMutableArray <LablePhoneNumber *> *lableArr;
    NSMutableArray <NSNumber *> *blackArr;
}


@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)onSegmentChanged:(id)sender;
- (IBAction)onAdd:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.separatorInset = UIEdgeInsetsZero;
    
    NSData *data = [USER_DEFAULTS objectForKey:kLablePhoneNumberStoreKey];
    lableArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!lableArr) {
        lableArr = [NSMutableArray array];
    }
    
    blackArr = [USER_DEFAULTS objectForKey:kBlackPhoneNumberStoreKey];
    if (!blackArr) {
        blackArr = [NSMutableArray array];
    }
    
    [self checkPermissions];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)showMessage:(NSString *)aMsg
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:vc animated:YES completion:nil];
}

//检查权限
-(void)checkPermissions
{
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    // 获取权限状态
    [manager getEnabledStatusForExtensionWithIdentifier:kCallExtensionBundleID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
        if (!error) {
            if (enabledStatus != CXCallDirectoryEnabledStatusEnabled) {
                [self showMessage:@"未授权电话权限，请在“设置->通用->电话->来电阻止与身份识别”中开启"];
            }else{
                [self updateData];
            }
        }else{
            [self showMessage:@"获取电话授权权限失败"];
        }
    }];
}



-(void)updateData
{
    
//    for (LablePhoneNumber *lpn in lableArr) {
//        [self createNewPhoneNumberFromPhoneNumber:lpn.phoneNumber callBack:^(CXCallDirectoryPhoneNumber newPhoneNumber) {
//            NSLog(@"%lld",newPhoneNumber);
//        }];
//    }
    
    
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    [manager reloadExtensionWithIdentifier:kCallExtensionBundleID completionHandler:^(NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessage:@"更新失败"];
            });
        }
    }];
}

//- (NSString *)randTailNumber
//{
//    NSMutableString *randStr = [NSMutableString string];
//    for (NSInteger i = 0; i < 7; i++) {
//        [randStr appendFormat:@"%d",arc4random()%10];
//    }
//    
//    return randStr;
//}
//
//- (void)createNewPhoneNumberFromPhoneNumber:(CXCallDirectoryPhoneNumber)aPhoneNumber callBack:(void (^)(CXCallDirectoryPhoneNumber newPhoneNumber))aCallBack
//{
//    NSString *phoneStr = [NSString stringWithFormat:@"86%lld",aPhoneNumber];
//    if (aPhoneNumber < 10000) {
//        for (NSInteger i=0; i<20000; i++) {
//            NSString *newStr = [phoneStr stringByAppendingString:[self randTailNumber]];
//            if (aCallBack) {
//                CXCallDirectoryPhoneNumber newNum = [newStr longLongValue];
//                aCallBack(newNum);
//            }
//        }
//    }else{
//        if (aCallBack) {
//            CXCallDirectoryPhoneNumber newNum = [phoneStr longLongValue];
//            aCallBack(newNum);
//        }
//    }
//}


- (IBAction)onSegmentChanged:(id)sender {
    [_tableView reloadData];
}

- (IBAction)onAdd:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EditViewController"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segment.selectedSegmentIndex == 0) {
        return lableArr.count;
    }else{
        return blackArr.count;
    }
}

- (UITableViewCell *)getCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    if (_segment.selectedSegmentIndex == 0) {
        LablePhoneNumber *obj = lableArr[indexPath.row];
        NSString *text = [NSString stringWithFormat:@"%lld",obj.phoneNumber];
        if (text.length == 4) {
            text = [text stringByAppendingString:@"*******"];
        }
        cell.textLabel.text = text;
        cell.detailTextLabel.text = obj.lable;
    }else{
        NSNumber *num = blackArr[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",num.stringValue];
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (_segment.selectedSegmentIndex == 0) {
            //标记
            [lableArr removeObjectAtIndex:indexPath.row];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:lableArr];
            [USER_DEFAULTS setObject:data forKey:kLablePhoneNumberStoreKey];
        }else{
            //黑名单
            [blackArr removeObjectAtIndex:indexPath.row];
            [USER_DEFAULTS setObject:blackArr forKey:kBlackPhoneNumberStoreKey];
        }
        [USER_DEFAULTS synchronize];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self updateData];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction];
}

#pragma mark -
#pragma mark - EditViewControllerDelegate
- (void)editViewController:(EditViewController *)aVC didAddPhoneNumber:(NSString *)aPhoneNumber lable:(NSString *)aLbl
{
    CXCallDirectoryPhoneNumber phone = [aPhoneNumber longLongValue];
    if (aLbl) {
        //标记
        LablePhoneNumber *lpn = [[LablePhoneNumber alloc]init];
        lpn.phoneNumber = phone;
        lpn.lable = aLbl;
        [lableArr addObject:lpn];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:lableArr];
        [USER_DEFAULTS setObject:data forKey:kLablePhoneNumberStoreKey];
    }else{
        //黑名单
        NSNumber *num = [NSNumber numberWithLongLong:phone];
        [blackArr addObject:num];
        [USER_DEFAULTS setObject:blackArr forKey:kBlackPhoneNumberStoreKey];
    }
    [USER_DEFAULTS synchronize];
    [_tableView reloadData];
    [self updateData];
}

@end

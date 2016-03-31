//
//  LoginPhoneView.m
//  expressapp
//
//  Created by kangylk on 15-3-3.
//  Copyright (c) 2015年 Kevin Kang. All rights reserved.
//

#import "LoginPhoneView.h"
#import "RCTabBarViewController.h"


@interface LoginPhoneView () <UITextFieldDelegate>
{
    __weak IBOutlet UITextField *usernameTF;
    __weak IBOutlet UITextField *passwordTF;
    
    
    __weak IBOutlet UIView *phoneView;
    __weak IBOutlet UIView *codeView;
    
    
    __weak IBOutlet UIButton *checkBtn;
    
    // 动画约束
    __weak IBOutlet NSLayoutConstraint *_topConstraint;
    
}
@end

@implementation LoginPhoneView

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"LoginPhoneView" bundle:nil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    return self;
}

#pragma mark
#pragma mark - UIKeyboard Events

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardShow:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardHeight = CGRectGetHeight([aValue CGRectValue]);
    
    NSTimeInterval timeInterval = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = [curve integerValue];
    
    
    // 修改上边距约束
    if (checkBtn.bottom + keyBoardHeight > kScreenHeight) {
        _topConstraint.constant -= keyBoardHeight+checkBtn.bottom+20-kScreenHeight;
    }
    
    // 更新约束
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:animationCurve];

        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardHide:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    
    NSTimeInterval timeInterval = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = [curve integerValue];

    // 修改上边距约束
    _topConstraint.constant = 20;
    
    // 更新约束
    [UIView animateWithDuration:timeInterval animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:animationCurve];

        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";

    [self initUI];
    
    // 只提供一个登录成功接口
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)initUI {
    
    [usernameTF becomeFirstResponder];

    checkBtn.titleLabel.font = Font(18);
    
    [checkBtn SetBorderWithcornerRadius:5.f BorderWith:0.f AndBorderColor:nil];
    [phoneView SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:GLOBAL_COLOR];
    [codeView SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)]];
}

-(void)dismissSelf {
    [[SingleUserInfo sharedInstance] loginDissmiss];
}

- (void)dismissKeyBoard {
    [usernameTF resignFirstResponder];
    [passwordTF resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == usernameTF) {
        [phoneView SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:GLOBAL_COLOR];
        [codeView SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
    } else if (textField == passwordTF) {
        [phoneView SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:[UIColor colorWithWhite:0.92 alpha:1.0]];
        [codeView SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:GLOBAL_COLOR];
    }
    return YES;
}

//登陆
- (IBAction)onSignInBtn:(id)sender {
    
    NSString *username = [usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *password = [passwordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (username.length < 1) {
        show_alertView(@"请输入用户名");
        return;
    }
    
    if (password.length < 1) {
        show_alertView(@"请输入密码");
        return;
    }
    
    // 构造登录请求参数 私钥
    PlayerInfoModel *PIModel = [PlayerInfoModel new];
    PIModel.privateKey = passwordTF.text.md5;
    [[DataEngine sharedInstance] ConfigDataWith:PIModel];

    [[DataEngine sharedInstance] verifyUserDataWithAccount:usernameTF.text password:passwordTF.text success:^(id responseData) {
        NSDictionary *userDic = (NSDictionary *)responseData;
        DLog(@"登陆: %@",userDic);
        
        if ([userDic[@"Success"] integerValue] == 1) {
            
            NSString *userid = userDic[@"CallInfo"][@"userid"];
            
            if ([userid isEqualToString:@"0"] || ![userid isNotNullObject]) {//
                usernameTF.text = @"";
                passwordTF.text = @"";
                [usernameTF becomeFirstResponder];
                
                [self showErrorHUDWithText:@"账号或密码错误,请重新输入"];
            } else {
                NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
                [infoDic setObject:userid               forKey:@"userid"];
                [infoDic setObject:usernameTF.text      forKey:@"mobile"];
                [infoDic setObject:passwordTF.text      forKey:@"captcha"];
                [infoDic setObject:passwordTF.text.md5  forKey:@"privateKey"];
                
                // 2b 没有这些数据
                //NSString *sitename = userDic[@"CallInfo"][@"sitename"];
                //NSString *contact = userDic[@"CallInfo"][@"contact"];

                //[infoDic setObject:sitename forKey:@"sitename"];
                //[infoDic setObject:contact forKey:@"contact"];
                
                DLog(@"用户信息 :%@",infoDic);
                
                [[SingleUserInfo sharedInstance] savePlayerInfoLocationWithDictionary:infoDic];//save
                
                if (self.isFirstEnter) {
                    RCTabBarViewController *tabbarVC = [[RCTabBarViewController alloc] init];
                    AppDelegate *delegate = [AppDelegate Share];
                    UIWindow *window = delegate.window;
                    window.rootViewController = tabbarVC;
                    
                } else {
                    [[SingleUserInfo sharedInstance] loginDissmiss];//dismiss
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidLoginStatusNotification object:nil userInfo:@{@"loginStatus":@YES}];
            }
        } else {
            usernameTF.text = @"";
            passwordTF.text = @"";
            [usernameTF becomeFirstResponder];

            [self showErrorHUDWithText:@"账号或密码错误,请重新输入"];
        }

    } failed:^(NSError *error) {
        DLog(@"%@",error);
    }];
}


@end

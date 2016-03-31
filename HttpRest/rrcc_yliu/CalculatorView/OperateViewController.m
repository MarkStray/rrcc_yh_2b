//
//  OperateViewController.m
//  rrcc_yh
//
//  Created by user on 16/1/4.
//  Copyright © 2016年 ting liu. All rights reserved.
//

#import "OperateViewController.h"

#define kOperateViewHeihgt      400

#define kMostPurchaseQuantity   999

@interface OperateViewController () <UITextFieldDelegate>

{
    __weak IBOutlet SelectedAllTextField *_numTextField;
}

@end

@implementation OperateViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        [self.view setNeedsUpdateConstraints];
        [self.view updateConstraintsIfNeeded];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);

    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        if (_numTextField.text.integerValue < 0) {
            _numTextField.text = [NSString stringWithFormat:@"%d",self.defaultCount];
            
            NSString *alertMsg = [NSString stringWithFormat:@"亲! 商品购买数量不能小于0份"];
            [self showHUDWithText:alertMsg];
        }
        
        if (self.isOnSale) {
            if (_numTextField.text.intValue > self.amountCount) {
                _numTextField.text = [NSString stringWithFormat:@"%d",self.amountCount];
                
                NSString *alertMsg = [NSString stringWithFormat:@"亲! 本促销品每单限购%d份!",self.amountCount];
                [self showHUDWithText:alertMsg];
            }
        } else {
            if (_numTextField.text.intValue > kMostPurchaseQuantity) {
                _numTextField.text = [NSString stringWithFormat:@"%d",kMostPurchaseQuantity];
                
                NSString *alertMsg = [NSString stringWithFormat:@"亲! 本商品每单最多能购买%d份!",kMostPurchaseQuantity];
                [self showHUDWithText:alertMsg];
            }
        }
        
    }];
}

// reduce
- (IBAction)reduce:(id)sender {
    int temNum = _numTextField.text.intValue;
    temNum -= 1;
    if (temNum < 0) {
        _numTextField.text = [NSString stringWithFormat:@"%d",self.defaultCount];
        
        NSString *alertMsg = [NSString stringWithFormat:@"亲! 购买数量不能小于0份"];
        [self showHUDWithText:alertMsg];
    } else {
        _numTextField.text = [NSString stringWithFormat:@"%d",temNum];
    }
}

// add
- (IBAction)add:(id)sender {
    int temNum = _numTextField.text.intValue;
    temNum += 1;
    
    if (self.isOnSale) {
        if (temNum > self.amountCount) {
            _numTextField.text = [NSString stringWithFormat:@"%d",self.amountCount];
            
            NSString *alertMsg = [NSString stringWithFormat:@"亲! 本促销品每单限购%d份!",self.amountCount];
            [self showHUDWithText:alertMsg];
            
        } else {
            _numTextField.text = [NSString stringWithFormat:@"%d",temNum];
        }
    } else {
        if (temNum > kMostPurchaseQuantity) {
            _numTextField.text = [NSString stringWithFormat:@"%d",kMostPurchaseQuantity];
            
            NSString *alertMsg = [NSString stringWithFormat:@"亲! 本商品每单最多能购买%d份!",kMostPurchaseQuantity];
            [self showHUDWithText:alertMsg];
            
        } else {
            _numTextField.text = [NSString stringWithFormat:@"%d",temNum];
        }
    }
}

// cancel
- (IBAction)cancel:(id)sender {
    [self hide];
    if (self.updatePurchaseQuantity) self.updatePurchaseQuantity(self.defaultCount);
}

// confirm
- (IBAction)confirm:(id)sender {
    [self hide];
    if (self.updatePurchaseQuantity) self.updatePurchaseQuantity(_numTextField.text.intValue);
}
// 显示 数量框
- (void)show {
    // 数量修改默认值
    _numTextField.text = [NSString stringWithFormat:@"%d",self.defaultCount];
    
    [_numTextField becomeFirstResponder];
    if (self.showAction) self.showAction();
}

// 隐藏 数量框
- (void)hide {
    [_numTextField resignFirstResponder];
    if (self.hiddenAction) self.hiddenAction();
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField performSelector:@selector(selectAll:) withObject:textField];
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

@end

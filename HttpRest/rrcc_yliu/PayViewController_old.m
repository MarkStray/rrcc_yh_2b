//
//  PayViewController.m
//  rrcc_yh
//
//  Created by user on 15/11/5.
//  Copyright © 2015年 ting liu. All rights reserved.
//

#import "PayViewController.h"
#import "OrderDetailViewController.h"

#import "OrderSuccessedViewController.h"

#import "PayEngine.h"
#import "WXApi.h"// 微信

const int pay_base_tag = 201; // 支付方式

typedef NS_ENUM(NSUInteger, PayCellType) {
    PayCellTypeHeader,
    PayCellTypeMiddle,
    PayCellTypeFooter,
    PayCellTypeRedEnvelop,//红包
    PayCellTypeCommen,//单行cell
};

#define kPayHeaderCellIndetifier        @"PayHeaderCell"
#define kPayTypeCellIndetifier          @"PayTypeCell"
#define kPayRedEnvelopCellIndetifier    @"PayRedEnvelopCell"
#define kPayMiddleCellIndetifier        @"PayMiddleCell"
#define kPayFooterCellIndetifier        @"PayFooterCell"

@interface PayViewController () <UITableViewDataSource,UITableViewDelegate,PayEngineDelegate>

@property (nonatomic, strong) UITableView *payTableView;
@property (nonatomic, strong) UITableView *bottomTableView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) NSMutableArray *payDetailList;//

@property (nonatomic, strong) NSMutableArray *redEnvelopList;// 红包
@property (nonatomic, strong) RedPageModel *hasRedModel;// 有红包

@property (nonatomic, strong) NSMutableArray *distributerList;//自提点
@property (nonatomic, strong) NSMutableArray *pickupList;//取货时间

@property (nonatomic, assign) BOOL isLessThanThere;//明日三点之前

@property (nonatomic, strong) PresellModel *presellModel;//预售店铺

@property (nonatomic, copy) NSString *contact;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *inputAddress;

@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *sitename;
//@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) PayEngineType payType;

@property (nonatomic, assign) CGFloat offsetY;

@end

@implementation PayViewController
{
    BOOL _isSelectDistributer;//是否是选择自提点
    BOOL _hasRedEnvelop;//是否有红包
    BOOL _isOpen;// 红包是否展开
    BOOL _isClose;//是否已经发起支付
    
    BOOL _isTextViewEditing;//textView 是否在编辑状态
}

#pragma mark
#pragma mark - 去支付
/**确认支付*/
- (void)goPay:(UIButton *)sender {// 1订单 2支付
    // 去除空格
    //NSString *contact  = [self.contact stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *contact  = [self.contact stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *mobile   = [self.mobile stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *inputAddress  = [self.inputAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (contact.length < 1) {
        show_alertView(@"请输入有效的联系人姓名!!");
        return ;
    } else if (![Tools_Utils validateMobile:mobile]) {
        show_alertView(@"请输入正确的手机号码!!");
        return ;
    }  else if (inputAddress.length < 1) {
        show_alertView(@"请输入有效的收货地址!!");
        return ;
    } else {
        
        if (self.payType==PayEngineTypeWX && ![WXApi isWXAppInstalled]) {// 是否安装微信
            show_alertView(@"检测到您的设备没有安装微信,请选择支付宝支付,或安装微信后再来支付!!")
            return ;
        }
        
        // 本地保存相关信息 contact mobile address
        
        [[NSUserDefaults standardUserDefaults] setObject:contact forKey:kContactName];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSUserDefaults standardUserDefaults] setObject:mobile forKey:kContactMobile];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSUserDefaults standardUserDefaults] setObject:inputAddress forKey:kContactAddress];
        [[NSUserDefaults standardUserDefaults] synchronize];


        if (!_isClose) {
            _isClose = YES;
            NSString *distributerId = nil;
            for (DistributerModel *model in self.distributerList) {
                if (model.isDefault) {
                    distributerId = model.id;
                }
            }
            NSString *contact = [self.contact stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *mobile = self.mobile;
            NSString *remark = self.remark == nil? @"":[self.remark stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *address = [self.inputAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            
            //输入地址
            for (DistributerModel *model in self.distributerList) {
                if (model.isDefault) {
                    self.sitename = model.sitename;
                    //self.address = model.address;
                    break;
                }
            }
            //NSString *address = [[NSString stringWithFormat:@"%@  %@",self.sitename,self.address] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            
            //收货时间
            int appointmentIndex = 0;
            for (int i=0 ; i<self.pickupList.count; i++) {
                PickUpTimeModel *model = self.pickupList[i];
                if (model.isDefault == YES) {
                    appointmentIndex = i;
                    break;
                }
            }
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(appointmentIndex+1)];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            NSString *appointment = [NSString stringWithFormat:@"%@ %@",[formatter stringFromDate:date], @"9:00"];
            /*
             payment    1 货到付款 (2) 在线支付
             delivery   (1) 到店自提 2 配送
             */
            NSString *param = [NSString stringWithFormat:@"action=update&distributerId=%@&contact=%@&mobile=%@&address=%@&payment=%d&delivery=%d&appointment=%@&voucherId=%@&remark=%@",distributerId,contact,mobile,address,2,2,appointment,self.hasRedModel==nil?@"":self.hasRedModel.id,remark];
            DLog(@"param: %@",param);
            
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
            [[UIApplication sharedApplication].keyWindow addSubview:hud];
            hud.labelText = @"正在进入支付...";
            [hud showAnimated:YES whileExecutingBlock:^{
                sleep(1.5);
                [[DataEngine sharedInstance] requestUserOrderDataOrderId:self.orderModel.id parameter:param type:PUT success:^(id responseData) {//确认订单
                    _isClose = NO;
                    NSDictionary *dic = (NSDictionary *)responseData;
                    DLog(@"订单二： %@",dic);
                    if ([dic[@"Success"] integerValue] == 1) {//下单成功 预支付
                        self.orderModel = [UserOrderDetailModel creatWithDictionary:dic[@"CallInfo"]];
                        self.orderModel.orderid = self.orderModel.id;
                        [[SingleShoppingCar sharedInstance] setOrderModel:self.orderModel];// 状态0
                        
                        if (self.orderModel.status.integerValue == 1) { //订单更新成功
                            
                            if (self.orderModel.payment.integerValue == 2) {
                                [self prePayOnline];//预支付
                            } else {// 下单成功 到付 // 跳订单界面
                                [[SingleShoppingCar sharedInstance] clearShoppingCar];
                                
                                OrderSuccessedViewController *orderSuccess = [[OrderSuccessedViewController alloc] init];
                                [self pushNewViewController:orderSuccess];
                            }
                            
                        } else {
                            [self showHUDWithText:@"服务器异常"];
                        }
                    } else {
                        show_alertView(@"操作失败");
                    }
                } failed:^(NSError *error) {
                    _isClose = NO;
                    DLog(@"%@",error);
                }];
                
            } completionBlock:^{
                [hud removeFromSuperview];
            }];
        }
    }

}

#pragma mark
#pragma mark - 预支付

- (void)prePayOnline {
    NSString  *param = [NSString stringWithFormat:@"action=prepay&platform=%@",self.payType==PayEngineTypeWX? @"wxapp": @"taobao"];
    DLog(@"param: %@",param);
    
    [[DataEngine sharedInstance] requestUserOrderDataOrderId:self.orderModel.id parameter:param type:PUT success:^(id responseData) {
        NSDictionary *dic = (NSDictionary *)responseData;
        DLog(@"预支付： %@",dic);
        if ([dic[@"Success"] integerValue] == 1) {
            self.orderModel = [UserOrderDetailModel creatWithDictionary:dic[@"CallInfo"]];
            self.orderModel.orderid = self.orderModel.id;
            [[SingleShoppingCar sharedInstance] setOrderModel:self.orderModel];// 状态1
            
            //构造支付参数
            // custprice = price - discount
            NSString *payPrice = [NSString stringWithFormat:@"%.2f",self.orderModel.custprice.floatValue];
            
            //if (self.hasRedModel != nil) {
            //    payPrice = [NSString stringWithFormat:@"%.2f",self.orderModel.custprice.floatValue-self.hasRedModel.discount.floatValue];
            //}
            
            //调第三方支付
            [PayEngine sharedPay].delegate = self;
            [[PayEngine sharedPay] sendPayType:self.payType totalPrice:payPrice orderModel:self.orderModel];
        } else {
            show_alertView(@"操作失败");
        }
    } failed:^(NSError *error) {
        DLog(@"%@",error);
    }];
    
}

#pragma mark
#pragma mark - payEngineDelegate

- (void)PayEngineType:(PayEngineType)payType result:(id)resultData {
    if (payType == PayEngineTypeAli) {
        NSDictionary *resultDic = (NSDictionary *)resultData;
        DLog(@"AliResult --> %@",resultDic);
        if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]) {
            [self handlePayResult];
        } else if ([resultDic[@"resultStatus"] isEqualToString:@"8000"]) {
            [self showHUDWithText:@"正在处理中..."];
        } else if ([resultDic[@"resultStatus"] isEqualToString:@"4000"]) {
            [self showHUDWithText:@"订单支付失败"];
        } else if ([resultDic[@"resultStatus"] isEqualToString:@"6001"]) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"用户取消支付";
            [hud showAnimated:YES whileExecutingBlock:^{
                sleep(1.5);
            } completionBlock:^{
                [hud removeFromSuperview];
                
                [[SingleShoppingCar sharedInstance] clearShoppingCar];
                OrderDetailViewController *detailOrder = [[OrderDetailViewController alloc] init];
                [self pushNewViewController:detailOrder];
            }];
        } else if ([resultDic[@"resultStatus"] isEqualToString:@"6002"]) {
            [self showHUDWithText:@"网络连接出错"];
        } else {
            [self showHUDWithText:@"订单支付失败"];
        }
        
    } else if (payType == PayEngineTypeWX) {
        BaseResp *resp = (BaseResp *)resultData;
        DLog(@"WXResult --> %d %@",resp.errCode,resp.errStr);
        if ([resp isKindOfClass:[PayResp class]]) {
            PayResp *response = (PayResp *)resp;
            if (response.errCode == WXSuccess) {
                [self handlePayResult];
            } else if (response.errCode == WXErrCodeUserCancel) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:hud];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"用户取消支付";
                [hud showAnimated:YES whileExecutingBlock:^{
                    sleep(1.5);
                } completionBlock:^{
                    [hud removeFromSuperview];
                    
                    [[SingleShoppingCar sharedInstance] clearShoppingCar];
                    OrderDetailViewController *detailOrder = [[OrderDetailViewController alloc] init];
                    [self pushNewViewController:detailOrder];
                }];

            } else {
                [self showHUDWithText:@"订单支付失败"];
            }
        }
        
    } else {
        show_alertView(@"参数错误!!!");
    }
}

#pragma mark
#pragma mark - 支付成功

- (void)handlePayResult {// 通知服务器支付成功
    
    NSString  *param = [NSString stringWithFormat:@"action=pay&transactionId=%@&platformId=",self.orderModel.transaction_id];// 这里没有拿不到第三方的交易流水号
    DLog(@"param: %@",param);
    
    [[DataEngine sharedInstance] requestUserOrderDataOrderId:self.orderModel.id parameter:param type:PUT success:^(id responseData) {
        NSDictionary *dic = (NSDictionary *)responseData;
        DLog(@"支付成功: %@",dic);
        if ([dic[@"Success"] integerValue] == 1) { // 第三方 支付
            self.orderModel = [UserOrderDetailModel creatWithDictionary:dic[@"CallInfo"]];
            self.orderModel.orderid = self.orderModel.id;// 订单 ID 转换 用于跳转
            [[SingleShoppingCar sharedInstance] setOrderModel:self.orderModel];// 状态2
        }
        
        [[SingleShoppingCar sharedInstance] clearShoppingCar];
        
        OrderSuccessedViewController *orderSuccess = [[OrderSuccessedViewController alloc] init];
        [self pushNewViewController:orderSuccess];
        
    } failed:^(NSError *error) {
        DLog(@"%@",error);
    }];
    
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
    [UIView animateWithDuration:timeInterval animations:^{
        self.offsetY = self.payTableView.contentOffset.y;
        if (_isTextViewEditing) {
            self.payTableView.contentOffset = CGPointMake(0, self.offsetY + keyBoardHeight - 50);
        }
    } completion:nil];
}

- (void)keyboardHide:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    NSTimeInterval timeInterval = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:timeInterval animations:^{
        self.payTableView.contentOffset = CGPointMake(0, self.offsetY);
    } completion:nil];
}

- (void)resignTTFirstResponder {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResignFirstResponder" object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self resignTTFirstResponder];
}


#pragma mark
#pragma mark - 初始化UI

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单结算";
    [self.view addSubview:self.payTableView];
    [self.view addSubview:self.bottomView];

    [self initUIDataContainer];
    [self downloadRedEnvelopData];
}
- (UITableView *)payTableView {
    if (!_payTableView) {
        _payTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, self.view.height-64-50) style:UITableViewStyleGrouped];
        _payTableView.backgroundColor = BACKGROUND_COLOR;
        _payTableView.delegate = self;
        _payTableView.dataSource = self;
        
        _payTableView.separatorColor = [UIColor clearColor];
        _payTableView.showsVerticalScrollIndicator = YES;
        
        [_payTableView registerNib:[UINib nibWithNibName:kPayHeaderCellIndetifier bundle:nil] forCellReuseIdentifier:kPayHeaderCellIndetifier];
        [_payTableView registerNib:[UINib nibWithNibName:kPayTypeCellIndetifier bundle:nil] forCellReuseIdentifier:kPayTypeCellIndetifier];
        [_payTableView registerNib:[UINib nibWithNibName:kPayRedEnvelopCellIndetifier bundle:nil] forCellReuseIdentifier:kPayRedEnvelopCellIndetifier];
        [_payTableView registerNib:[UINib nibWithNibName:kPayMiddleCellIndetifier bundle:nil] forCellReuseIdentifier:kPayMiddleCellIndetifier];
        [_payTableView registerNib:[UINib nibWithNibName:kPayFooterCellIndetifier bundle:nil] forCellReuseIdentifier:kPayFooterCellIndetifier];
    }
    return _payTableView;
}

- (UITableView *)bottomTableView {
    if (!_bottomTableView) {
        _bottomTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.height-35-65*2, kScreenWidth, 35+65*2) style:UITableViewStylePlain];
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        
        _bottomTableView.separatorColor = [UIColor clearColor];
        _bottomTableView.showsVerticalScrollIndicator = NO;
        
        [_bottomTableView registerNib:[UINib nibWithNibName:@"SettleCell" bundle:nil] forCellReuseIdentifier:@"SettleCellID"];
    }
    return _bottomTableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [ZZFactory viewWithFrame:CGRectMake(0, self.view.height-50, kScreenWidth, 50) color:BACKGROUND_COLOR];
        UIButton *payBtn = [ZZFactory buttonWithFrame:CGRectMake(16, 7, kScreenWidth-16*2, 35) title:@"确认订单" titleColor:[UIColor whiteColor] image:nil bgImage:nil];
        payBtn.backgroundColor = GLOBAL_COLOR;
        [payBtn SetBorderWithcornerRadius:5.f BorderWith:0.f AndBorderColor:nil];
        [payBtn addTarget:self action:@selector(goPay:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:payBtn];
    }
    return _bottomView;
}

#pragma mark
#pragma mark - 初始化数据容器

- (void)initUIDataContainer {
    // 联系人
    self.contact = @"";
    // 手机号
    self.mobile = [[[SingleUserInfo sharedInstance] playerInfoModel] mobile];
    // 地址
    self.inputAddress = @"";
    
    //预售店铺
    self.presellModel = [[SingleShoppingCar sharedInstance] presellModel];

    //自提点 时间
    self.distributerList = [NSMutableArray array];
    self.pickupList = [NSMutableArray array];
    
    self.distributerList = [[SingleShoppingCar sharedInstance] distributerList];
    
    self.isLessThanThere = [[[Utility Share] GetHMSTime] floatValue] < 150000; //明日三点之前

    PickUpTimeModel *model = [PickUpTimeModel creatWithDictionary:@{@"pickupDate":@"明日取货",
                                                                    @"pickupTime":@"取货时间: AM9:00-PM20:00",
                                                                    @"attach":@"15点前下单可预约次日取货",
                                                                    @"isDefault":@(self.isLessThanThere)}];
    [self.pickupList addObject:model];
    
    model = [PickUpTimeModel creatWithDictionary:@{@"pickupDate":@"后日取货",
                                                   @"pickupTime":@"取货时间: AM9:00-PM20:00",
                                                   @"attach":@"15点后下单可预约后日取货",
                                                   @"isDefault":@(!self.isLessThanThere)}];
    [self.pickupList addObject:model];
    
    
    //DLog(@"\n\n\n%@\n\n\n%@\n\n\n",self.distributerList,self.pickupList);
    
    NSString *price = self.orderModel.price;
    NSString *discount = [NSString stringWithFormat:@"-￥%@",self.orderModel.discount==nil? @"0.00": self.orderModel.discount];
    NSString *redEnvelopGift = [NSString stringWithFormat:@"-￥%@",@"0.00"];
    NSString *gift = [NSString stringWithFormat:@"%@",self.orderModel.gift==nil?@"暂无赠品":self.orderModel.gift];
    NSString *payAdd = [NSString stringWithFormat:@"￥%.2f",self.orderModel.custprice.floatValue];
    
    self.payDetailList = [NSMutableArray arrayWithArray:@[@{@"title":@"商品总额",@"detail":price,@"hidden":@YES},
                                                          @{@"title":@"满减活动",@"detail":discount,@"hidden":@YES},
                                                          @{@"title":@"红包优惠",@"detail":redEnvelopGift,@"hidden":@NO},
                                                          @{@"title":@"满增活动",@"detail":gift,@"hidden":@NO},
                                                          @{@"title":@"还需支付",@"detail":payAdd,@"hidden":@YES}]];
}

- (void)downloadRedEnvelopData {
    self.redEnvelopList = [NSMutableArray array];

    [[DataEngine sharedInstance] requestUserVoucherListDataSuccess:^(id responseData) {
        NSDictionary *dic = (NSDictionary *)responseData;
        DLog(@"红包 %@",dic);
        if ([dic[@"Success"] integerValue] == 1) {
            NSArray *info = dic[@"CallInfo"];
            for (NSDictionary *d in info) {
                RedPageModel *model = [RedPageModel creatWithDictionary:d];
                [self.redEnvelopList addObject:model];
            }
            
            if (self.redEnvelopList.count > 0) {
                _hasRedEnvelop = YES;
                RedPageModel *lastModel = [[RedPageModel alloc] init];
                lastModel.isLastest = YES;
                [self.redEnvelopList addObject:lastModel];
                [self.payTableView reloadData];
            } else {
                _hasRedEnvelop = NO;
            }

        }
    } failed:^(NSError *error) {
        DLog(@"%@",error);
    }];
}

#pragma mark
#pragma mark - UITableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.bottomTableView) return 1;
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.bottomTableView) return _isSelectDistributer? self.distributerList.count: self.pickupList.count;

    if (section == 2) return _hasRedEnvelop ? 1: 0;//第三分区
    if (section == 3) return self.payDetailList.count;//第四分区
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.payTableView) {
        return section==0? CGFLOAT_MIN: 10;
    } else {
        return 35;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.payTableView) {
        if (indexPath.section == 0) return 180;
        if (indexPath.section == 1) return 35;
        if (indexPath.section == 2) {// 红包分区
            if (_hasRedEnvelop) {
                if (_isOpen) {
                    return (35 + (self.redEnvelopList.count+1)/2 * 75);
                } else {
                    return 35;
                }
            } else {
                return 35;
            }
        }
        if (indexPath.section == 4) return 44;
        return 35;
    } else {
        return 65;
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.payTableView) {
        return nil;
    } else {
        UIView *hView = [ZZFactory viewWithFrame:CGRectMake(0, 0, kScreenWidth, 35) color:[UIColor whiteColor]];
        
        NSString *title = [NSString stringWithFormat:@"%@",_isSelectDistributer? @"选择自提地址": @"选择取货时间"];
        UILabel *lbl = [ZZFactory labelWithFrame:CGRectMake(0, 0, kScreenWidth, 35) font:Font(16) color:[UIColor darkGrayColor] text:title];
        lbl.textAlignment = NSTextAlignmentCenter;
        [hView addSubview:lbl];
        
        UIButton *btn = [ZZFactory buttonWithFrame:CGRectMake(10, 0, 35, 35) title:nil titleColor:nil image:@"close" bgImage:nil];
        [btn addTarget:self action:@selector(closePopView) forControlEvents:UIControlEventTouchUpInside];
        [hView addSubview:btn];
        
        [ZZFactory viewWithFrame:CGRectMake(0, 34, kScreenWidth, 1) color:BACKGROUND_COLOR superView:hView];
        return hView;
    }
}

- (void)closePopView {
    [self pushTipView:self.bottomTableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.payTableView) {
        if (indexPath.section == 0) {
            PayHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayHeaderCellIndetifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // 联系人 & 手机号 & 地址
            
            // 展示相关信息
            NSString *contact = [[NSUserDefaults standardUserDefaults] objectForKey:kContactName];
            if (contact)    self.contact = contact;
            cell.contactTextField.text = self.contact;
            
            NSString *mobile = [[NSUserDefaults standardUserDefaults] objectForKey:kContactMobile];
            if (mobile)    self.mobile = mobile;
            cell.telTextField.text = self.mobile;
            
            NSString *inputAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kContactAddress];
            if (inputAddress)    self.inputAddress = inputAddress;
            cell.addrTextField.text = self.inputAddress;
            
            // 修改后 重新获取
            cell.contactBlock = ^ (NSString *contact) {
                self.contact = contact;
            };
            
            cell.mobileBlock = ^ (NSString *mobile) {
                self.mobile = mobile;
            };
            
            // 输入地址
            cell.addressBlock = ^ (NSString *address) {
                self.inputAddress = address;
            };
            

            // 自提点
            for (DistributerModel *model in self.distributerList) {
                if (model.isDefault) {
                    cell.takeTitleLabel.text = model.sitename;
                    cell.takeDetailLabel.text = model.address;
                    break;
                }
            }
            
            // 提货时间
            for (PickUpTimeModel *model in self.pickupList) {
                if (model.isDefault) {
                    cell.timeTitleLabel.text = model.pickupDate;
                    cell.timeDetailLabel.text = model.pickupTime;
                    break;
                }
            }
            
            cell.selectBlock = ^ (BOOL isSelectDistributer) {
                [self resignTTFirstResponder];
                // 自提点 不能更改
                _isSelectDistributer = isSelectDistributer;
                if (!isSelectDistributer) {
                    [self popTipView:self.bottomTableView];
                    [self.bottomTableView reloadData];
                }
            };
            
            return cell;
        } else if (indexPath.section == 1) {
            PayTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayTypeCellIndetifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // 支付方式
            self.payType = PayEngineTypeAli;
            
            return cell;
        } else if (indexPath.section == 2) {
            if (_hasRedEnvelop) {
                PayRedEnvelopCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayRedEnvelopCellIndetifier forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.openBlock = ^ (BOOL isOpen) {
                    _isOpen = isOpen;
                    [self resignTTFirstResponder];
                    [self.payTableView reloadData];
                };
                
                // 这里传入满减之后的价格
                [cell updateUIUsingArray:self.redEnvelopList tolPrice:self.orderModel.custprice complete:^(RedPageModel *model) {
                    
                    self.hasRedModel = model;//使用红包
                    
                    NSMutableDictionary *redEnvelopGiftDict = [NSMutableDictionary dictionaryWithDictionary:self.payDetailList[2]];
                    NSMutableDictionary *payAddDict = [NSMutableDictionary dictionaryWithDictionary:self.payDetailList[4]];
                    
                    NSString *redEnvelopGift = [NSString stringWithFormat:@"-￥%.2f",model.discount.floatValue];
                    
                    [redEnvelopGiftDict setObject:redEnvelopGift forKey:@"detail"];
                    NSString *payAdd = [NSString stringWithFormat:@"￥%.2f",self.orderModel.custprice.floatValue-model.discount.integerValue];
                    [payAddDict setObject:payAdd forKey:@"detail"];
                    
                    [self.payDetailList replaceObjectAtIndex:2 withObject:redEnvelopGiftDict];
                    [self.payDetailList replaceObjectAtIndex:4 withObject:payAddDict];
                    [self.payTableView reloadData];
                }];

                return cell;
            }
            return nil;
        } else if (indexPath.section == 3) {
            PayMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayMiddleCellIndetifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            NSDictionary *payDetailDict = self.payDetailList[indexPath.row];
            NSString *title = payDetailDict[@"title"];
            NSString *detail = payDetailDict[@"detail"];
            BOOL ishidden = [payDetailDict[@"hidden"] boolValue];
            
            cell.titleLabel.text = title;
            cell.detailLabel.text = detail;
            cell.lineView.hidden = ishidden;
            
            return cell;
        } else{
            PayFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:kPayFooterCellIndetifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.remarkBlock = ^ (NSString *remark) {
                self.remark = remark;
            };
            cell.editingStatusBlock = ^ (BOOL isEdit) {
                _isTextViewEditing = isEdit;
            };
            
            return cell;
        }
    } else {
        SettleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettleCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_isSelectDistributer) {// not execute
            return nil;
        } else {
            PickUpTimeModel *model = self.pickupList[indexPath.row];
            
            [cell updateUIUsingModel:model isLessThanThere:self.isLessThanThere complete:^ (BaseModel *model){
                PickUpTimeModel *pickupTimeModel = (PickUpTimeModel *)model;
                
                if (pickupTimeModel.isDefault) {
                    [self.pickupList replaceObjectAtIndex:indexPath.row withObject:pickupTimeModel];
                    for (int i=0; i<self.pickupList.count; i++) {
                        PickUpTimeModel *tempModel = self.pickupList[i];
                        if (indexPath.row != i) {
                            tempModel.isDefault = NO;
                            [self.pickupList replaceObjectAtIndex:i withObject:tempModel];
                        }
                    }
                    
                    [self.bottomTableView reloadData];
                    [self.payTableView reloadData];
                } else {
                    
                    [self.pickupList replaceObjectAtIndex:indexPath.row withObject:pickupTimeModel];
                    for (int i=0; i<self.pickupList.count; i++) {
                        PickUpTimeModel *tempModel = self.pickupList[i];
                        if (indexPath.row != i) {
                            tempModel.isDefault = YES;
                            [self.pickupList replaceObjectAtIndex:i withObject:tempModel];
                        }
                    }
                    
                    [self.bottomTableView reloadData];
                    [self.payTableView reloadData];

                    //[self.payTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
            return cell;
        }

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resignTTFirstResponder];

    if (tableView == self.payTableView) {
        
    } else {
        SettleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell clickSelectedButton:cell.selectedButton];
    }
}


@end

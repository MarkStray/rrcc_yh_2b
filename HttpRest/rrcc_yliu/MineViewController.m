//
//  MineViewController.m
//  rrcc_yh
//
//  Created by user on 15/9/18.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "MineViewController.h"

#import "OrderListViewController.h"
#import "BalanceViewController.h"
#import "SalaryViewController.h"
#import "PurchaseRecodeViewController.h"
#import "QAndAViewController.h"

#import "LoginPhoneView.h"

@interface MineViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSString *_balance,*_credit;
}
@property (nonatomic, strong) UITableView *mineTableView;

@property (nonatomic, strong) NSArray *imgAndTitle;
@property (nonatomic, strong) NSMutableArray *details;

@property (nonatomic, strong) UIButton *headerBtn;
@property (nonatomic, strong) UILabel *headerLabel;

@end

@implementation MineViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showCustomTabBar];
    
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserverForName:kDidLoginStatusNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        BOOL loginStatus = [note.userInfo[@"loginStatus"] boolValue];
        if (loginStatus) {
            NSString *mobile = [[[SingleUserInfo sharedInstance] playerInfoModel] mobile];
            self.headerLabel.text = mobile;
        } else {
            self.headerLabel.text = @"点击头像登录";
        }
    }];
    
    [self initUserData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidLoginStatusNotification object:nil];
}

- (void)login {
    //检测用户是否登录
    if (![[SingleUserInfo sharedInstance] locationPlayerStatus]) {
        [[SingleUserInfo sharedInstance] showLoginView];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (UITableView *)mineTableView {
    if (!_mineTableView) {
        _mineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, kScreenWidth, self.view.height-49-140) style:UITableViewStyleGrouped];
        _mineTableView.delegate = self;
        _mineTableView.dataSource = self;
        _mineTableView.rowHeight = 40;
        _mineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mineTableView registerNib:[UINib nibWithNibName:@"MineCell" bundle:nil] forCellReuseIdentifier:@"MineCellId"];
    }
    return _mineTableView;
}

- (void)initUI {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 140)];
    headerView.backgroundColor = BACKGROUND_COLOR;
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    headerImgView.image = [UIImage imageNamed:@"mine-background"];
    [headerView addSubview:headerImgView];
    
    self.headerBtn = [ZZFactory buttonWithFrame:CGRectMake(kScreenWidth/2-35, 25, 70, 70) title:nil titleColor:nil image:nil bgImage:@"portrait"];
    [self.headerBtn SetBorderWithcornerRadius:35.f BorderWith:0.f AndBorderColor:nil];
    [self.headerBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.headerBtn];
    
    NSString *mobile = [[[SingleUserInfo sharedInstance] playerInfoModel] mobile];
    
    self.headerLabel = [ZZFactory labelWithFrame:CGRectMake(0, 95, kScreenWidth, 30) font:Font(16) color:[UIColor whiteColor] text:mobile==nil?@"点击头像登录":mobile];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:self.headerLabel];
    [self.view addSubview:headerView];
    
    [self.view addSubview:self.mineTableView];
}

- (void)initUserData {
    
    // load location resource
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"mine" ofType:@"plist"];
    NSArray *mineAsset = [NSArray arrayWithContentsOfFile:plistPath];
    self.imgAndTitle = mineAsset;
    
    [self showLoadingIndicator];//
    [[DataEngine sharedInstance] requestUserInfoDataSuccess:^(id responseData) {
        [self hideLoadingIndicator];//
        NSDictionary *dic = (NSDictionary *)responseData;
        DLog(@"UserInfo: %@",dic);
        if ([dic[@"Success"] integerValue] == 1) {
            NSDictionary *userDict = dic[@"CallInfo"][@"User"];
            
            _balance = userDict[@"balance"];
            NSString *balance = [NSString stringWithFormat:@"当前余额%@元",_balance];
            
            //_credit  = userDict[@"credit"];
            //NSString *credit = [NSString stringWithFormat:@"当前积分%@分",_credit];
            
            self.details = [NSMutableArray arrayWithArray:@[@[@"查看全部订单",@""],@[balance],@[@"",@""],@[@""]]];
            [self.mineTableView reloadData];
        } else {
            self.details = [NSMutableArray arrayWithArray:@[@[@"",@""],@[@""],@[@"",@""],@[@""]]];
            [self.mineTableView reloadData];
        }
        
    } failed:^(NSError *error) {
        [self hideLoadingIndicator];//
        DLog(@"%@",error);
    }];
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.details.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)self.details[section]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *tempDict = [self.imgAndTitle[indexPath.section] objectAtIndex:indexPath.row];
    NSString *imageName = [tempDict objectForKey:@"img"];
    NSString *title = [tempDict objectForKey:@"title"];
    
    NSString *detail = [self.details[indexPath.section] objectAtIndex:indexPath.row];
    
    UIColor *detailTextColor = [UIColor lightGrayColor];
    if (indexPath.section == 1) {
        detailTextColor = [UIColor redColor];
        if (indexPath.row == 2) {
            detailTextColor = [UIColor greenColor];
        }
    }
    
    BOOL isHidden = YES;
    BOOL isImgHidden = NO;
    
    if (indexPath.row == 0) {
        if (indexPath.section != self.details.count-1) {
            isHidden = NO;
        }
    }
    
    if (indexPath.section != 0) {
        if (indexPath.row == 0) {
            isImgHidden = YES;
        }
    }
    
    [cell updateUIUsingImage:imageName lineViewHidden:isHidden arrowImgHidden:isImgHidden title:title detail:detail color:detailTextColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *tempDict = [self.imgAndTitle[indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = [tempDict objectForKey:@"title"];

    
    if (indexPath.section == 0) {
        //检测用户是否登录
        if (![[SingleUserInfo sharedInstance] locationPlayerStatus]) {
            [[SingleUserInfo sharedInstance] showLoginView];
            return;
        }
        
        if (indexPath.row == 0) {
            // 订单
            OrderListViewController *orderList = [[OrderListViewController alloc] init];
            orderList.title = title;
            [self pushNewViewController:orderList];
        } else if (indexPath.row == 1) {
            // 购买记录
            PurchaseRecodeViewController *purchaseRecode = [[PurchaseRecodeViewController alloc] init];
            purchaseRecode.title = title;
            [self pushNewViewController:purchaseRecode];
        }
    } else if (indexPath.section == 1) {
        //检测用户是否登录
        if (![[SingleUserInfo sharedInstance] locationPlayerStatus]) {
            [[SingleUserInfo sharedInstance] showLoginView];
            return;
        }
        
        if (indexPath.row == 0) {
            return;// 只显示余额
            // 余额
            BalanceViewController *balance = [[BalanceViewController alloc] init];
            balance.title = title;
            [self pushNewViewController:balance];
        } else if (indexPath.row == 1) {
            // 红包
            //SalaryViewController *salary = [[SalaryViewController alloc] init];
            //salary.title = title;
            //[self pushNewViewController:salary];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[Utility Share] makeCall:@"4000-285-927"];
        } else if (indexPath.row == 1) {
            QAndAViewController *qa = [[QAndAViewController alloc] init];
            qa.title = title;
            [self pushNewViewController:qa];
        }
    } else {
        [[SingleShoppingCar sharedInstance] clearShoppingCar];
        
        [[SingleUserInfo sharedInstance] setIsExit:YES];
        [[SingleUserInfo sharedInstance] setLocationPlayerStatus:NO];
        //[[SingleUserInfo sharedInstance] showLoginView];
        
        self.details = [NSMutableArray arrayWithArray:@[@[@"",@""],@[@"",@""],@[@"",@""],@[@""]]];
        [self.mineTableView reloadData];
    }
}

@end

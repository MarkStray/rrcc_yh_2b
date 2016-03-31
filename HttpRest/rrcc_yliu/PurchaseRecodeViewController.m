//
//  PurchaseRecodeViewController.m
//  rrcc_yh
//
//  Created by user on 16/3/29.
//  Copyright © 2016年 ting liu. All rights reserved.
//

#import "PurchaseRecodeViewController.h"

@interface PurchaseRecodeViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *recodeArray;
@property (nonatomic, strong) UITableView *recodeTableView;

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation PurchaseRecodeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showCustomTabBar];
    [[UIApplication sharedApplication].keyWindow addSubview:self.bottomView];
    
    [self doWithUserHistorySkusData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bottomView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.recodeTableView];
}

- (void)doWithUserHistorySkusData {
    self.recodeArray = [NSMutableArray array];
    
    [self showLoadingGIF];
    [[DataEngine sharedInstance] requestUserHistorySkusDataSuccess:^(id responseData) {
        [self hideLoadingGIF];
        
        // 购物车已加入数据
        NSMutableArray *carProducts = [[SingleShoppingCar sharedInstance] productsDataSource];

        NSDictionary *dic = (NSDictionary *)responseData;
        DLog(@"购买记录 %@",dic);
        
        if ([dic[@"Success"] integerValue] == 1) {
            NSArray *info = dic[@"CallInfo"];
            for (NSDictionary *d in info) {
                ProductsModel *model = [ProductsModel creatWithDictionary:d];
                
                /* 对数据源进行过滤 */
                for (ProductsModel *carModel in carProducts) {
                    if ([model.skuid isEqualToString:carModel.skuid]) {
                        //只替换对应数量
                        model.count = carModel.count;
                    }
                }
                
                [self.recodeArray addObject:model];

            }
        }
        
        if (self.recodeArray.count == 0) {
            [self.view addSubview:self.lowerFloorView];
        } else {
            [self.recodeTableView reloadData];
        }
    } failed:^(NSError *error) {
        
        [self hideLoadingGIF];
        [self.view addSubview:self.lowerFloorView];
        DLog(@"%@",error);
    }];
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-49, kScreenWidth-80, 49)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}


- (UITableView *)recodeTableView {
    if (!_recodeTableView) {
        _recodeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, self.view.height-64-49) style:UITableViewStylePlain];
        _recodeTableView.delegate = self;
        _recodeTableView.dataSource = self;
        
        _recodeTableView.rowHeight = 75*autoSizeScaleY;
        _recodeTableView.separatorColor = [UIColor clearColor];
        _recodeTableView.backgroundColor = BACKGROUND_COLOR;
        
        [_recodeTableView registerNib:[UINib nibWithNibName:@"ProductCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ProductCellId"];
        
    }
    return _recodeTableView;
}

- (UIView *)lowerFloorView {
    if (!_lowerFloorView) {
        _lowerFloorView = [[UIView alloc] initWithFrame:self.view.bounds];
        _lowerFloorView.backgroundColor = [UIColor whiteColor];
        UIImageView *imgV = [ZZFactory imageViewWithFrame:CGRectMake(0, 0, 150, 150) defaultImage:@"radish"];
        imgV.center = self.view.center;
        [_lowerFloorView addSubview:imgV];
        UILabel *lbl = [ZZFactory labelWithFrame:CGRectMake(0, imgV.bottom, kScreenWidth, 21) font:Font(14) color:[UIColor darkGrayColor] text:@"亲,你还没有购买记录"];
        lbl.textAlignment = NSTextAlignmentCenter;
        [_lowerFloorView addSubview:lbl];
    }
    return _lowerFloorView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recodeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ProductsModel *model = [self.recodeArray objectAtIndex:indexPath.row];
    
    [cell updateUIUsingModel:model];
    
    cell.purchaseBlockCB =  ^ BOOL (ProductsModel *model) {
        return [[SingleShoppingCar sharedInstance] playerProductsModel:model];
    };

    return cell;
}

@end

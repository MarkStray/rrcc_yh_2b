//
//  SearchViewController.m
//  rrcc_yh
//
//  Created by user on 15/10/22.
//  Copyright © 2015年 ting liu. All rights reserved.
//

#import "SearchViewController.h"
#import "ProductDetailViewController.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *productsSearchBar;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *originalProductList;
@property (nonatomic, strong) NSMutableArray *filteredProductList;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.productsSearchBar];
    UIButton *searchBtn = [ZZFactory buttonWithFrame:CGRectMake(0, 0, 60*autoSizeScaleX, 28) title:@"取消" titleColor:GLOBAL_COLOR image:nil bgImage:nil];
    searchBtn.backgroundColor = [UIColor whiteColor];
    [searchBtn SetBorderWithcornerRadius:5.f BorderWith:0.f AndBorderColor:nil];
    [searchBtn addTarget:self action:@selector(showDismiss) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    [ZZFactory imageViewWithFrame:CGRectMake((kScreenWidth-100)/2, 120, 100, 70) defaultImage:@"Search_Content" superView:self.view];
    [self initSearchDataSource];
}

- (void)initSearchDataSource {
    self.originalProductList = [NSMutableArray array];
    self.filteredProductList = [NSMutableArray array];
    for (NSArray *item in self.itemList)
        for (ProductsModel *model in item)
            [self.originalProductList addObject:model];
}

- (UISearchBar *)productsSearchBar {
    if (!_productsSearchBar) {
        _productsSearchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 220*autoSizeScaleX, 40)];
        _productsSearchBar.backgroundImage = [_productsSearchBar imageWithColor:[UIColor clearColor] size:_productsSearchBar.bounds.size];
        _productsSearchBar.tintColor = RGBCOLOR(66, 107, 242);
        _productsSearchBar.placeholder=@"请输入搜索内容";
        _productsSearchBar.delegate=self;
    }
    return _productsSearchBar;
}

- (UITableView *)searchTableView {
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, self.view.height-64) style:UITableViewStylePlain];
        _searchTableView.dataSource = self;
        _searchTableView.delegate = self;
        _searchTableView.rowHeight =  120*autoSizeScaleY;
        _searchTableView.backgroundColor = BACKGROUND_COLOR;
        _searchTableView.separatorColor = [UIColor clearColor];
        [_searchTableView registerNib:[UINib nibWithNibName:@"MainCell" bundle:nil] forCellReuseIdentifier:@"MainCellID"];
    }
    return _searchTableView;
}

- (UIView *)lowerFloorView {
    if (!_lowerFloorView) {
        _lowerFloorView = [[UIView alloc] initWithFrame:self.view.bounds];
        _lowerFloorView.backgroundColor = [UIColor whiteColor];
        UIImageView *imgV = [ZZFactory imageViewWithFrame:CGRectMake((kScreenWidth-150)/2, 120, 150, 150) defaultImage:@"radish"];
        [_lowerFloorView addSubview:imgV];
        UILabel *lbl = [ZZFactory labelWithFrame:CGRectMake(0, imgV.bottom+10, kScreenWidth, 21) font:Font(14) color:[UIColor darkGrayColor] text:@"亲,没有找到您要搜索的商品"];
        lbl.textAlignment = NSTextAlignmentCenter;
        [_lowerFloorView addSubview:lbl];
    }
    return _lowerFloorView;
}


#pragma mark - search

- (void)showDismiss {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchBar:searchBar textDidChange:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *predicateStr = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"skuname",searchText];
    self.filteredProductList = [[self.originalProductList filteredArrayUsingPredicate:predicateStr] mutableCopy];
    if ([self.view.subviews containsObject:self.lowerFloorView]) {
        [self.lowerFloorView removeFromSuperview];
    }
    if (self.filteredProductList.count == 0) {
        [self.view addSubview:self.lowerFloorView];
        return ;
    }
    [self.view addSubview:self.searchTableView];
    [self.searchTableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.productsSearchBar resignFirstResponder];
}

#pragma mark - UITableView 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [ZZFactory viewWithFrame:CGRectMake(0, 0, kScreenWidth, 30) color:BACKGROUND_COLOR];
    NSString *title = [NSString stringWithFormat:@"共找到您需要的\"%ld\"款商品",(unsigned long)self.filteredProductList.count];
    [ZZFactory labelWithFrame:CGRectMake(16, 4, kScreenWidth-16, 21) font:Font(16) color:[UIColor lightGrayColor] text:title superView:headView];
    return headView;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProductList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCellID" forIndexPath:indexPath];
    ProductsModel *model = self.filteredProductList[indexPath.row];
    [cell updateUIUsingModel:@[model] complete:^(ProductsModel *model) {
        NSMutableArray *productsModel = [[SingleShoppingCar sharedInstance] productsDataSource];
        ProductDetailViewController *pVC = [[ProductDetailViewController alloc] init];
        for (ProductsModel *mdl in productsModel)
            if ([model.skuid isEqualToString:mdl.skuid]) model.count = mdl.count;
        pVC.detailProductModel = model;
        [self pushNewViewController:pVC];
    }];
    return cell;
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

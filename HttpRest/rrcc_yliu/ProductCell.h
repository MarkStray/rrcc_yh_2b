//
//  ProductCell.h
//  rrcc_yh
//
//  Created by user on 15/9/20.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CalculatorView.h"

@interface ProductCell : UITableViewCell <CalculatorViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *onsaleImg;
@property (weak, nonatomic) IBOutlet UIImageView *logoImgView;
@property (weak, nonatomic) IBOutlet UILabel *brandLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *weightLbl;

@property (weak, nonatomic) IBOutlet LineLabel *avgPrice;// 市场价

@property (weak, nonatomic) IBOutlet UILabel *salePriceLbl;
@property (weak, nonatomic) IBOutlet LineLabel *oldPriceLbl;

@property (weak, nonatomic) IBOutlet CalculatorView *CalcView;

@property (nonatomic, strong) ProductsModel *model;
@property (nonatomic, copy) BOOL (^purchaseBlockCB) (ProductsModel *model);

- (void)updateUIUsingModel:(ProductsModel *)model;

@end

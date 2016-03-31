//
//  OperateViewController.h
//  rrcc_yh
//
//  Created by user on 16/1/4.
//  Copyright © 2016年 ting liu. All rights reserved.
//

#import "XHBaseViewController.h"
#import "SelectedAllTextField.h"

typedef void (^ShowAction) ();// 显示 动作

typedef void (^HiddenAction) ();// 隐藏动作

typedef void (^UpdatePurchaseQuantity) (int newQuantity);// 返回修改后数量



@interface OperateViewController : XHBaseViewController

@property (nonatomic, assign) int defaultCount; // 购物车种已经添加的数量
@property (nonatomic, assign) int amountCount;  // 促销限购数量
@property (nonatomic, assign) BOOL isOnSale;    // 是否是促销

@property (nonatomic, copy) ShowAction showAction;

@property (nonatomic, copy) HiddenAction hiddenAction;

@property (nonatomic, copy) UpdatePurchaseQuantity updatePurchaseQuantity;

// 显示 数量框
- (void)show;

// 隐藏 数量框
- (void)hide;

@end

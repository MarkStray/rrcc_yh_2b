//
//  OperateManager.h
//  rrcc_yh
//
//  Created by user on 16/1/5.
//  Copyright © 2016年 ting liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperateViewController.h"


@interface OperateManager : NSObject

+ (OperateManager *)defaultOperateManager;

- (void)updatePurchaseQuantityWithOldQuantity:(int)oldQuantity
                               amountQuantity:(int)amountQuantity
                                     isOnSale:(BOOL)isOnSale
                                     complete:(UpdatePurchaseQuantity)updatePurchaseQuantity;

@end

//
//  OperateManager.m
//  rrcc_yh
//
//  Created by user on 16/1/5.
//  Copyright © 2016年 ting liu. All rights reserved.
//

#import "OperateManager.h"

@implementation OperateManager
{
    OperateViewController *_operation;
}

+ (OperateManager *)defaultOperateManager {
    static OperateManager *_manager = nil;
    @synchronized(self) {
        if (_manager == nil) {
            _manager = [[OperateManager alloc] init];
        }
    }
    return _manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self customInit];

    }
    return self;
}

- (void)customInit {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    _operation = [[OperateViewController alloc] initWithNibName:@"OperateViewController" bundle:nil];
    [window addSubview:_operation.view];
    _operation.view.top = window.bottom;
    
    __weak typeof(_operation) weak_operation = _operation;

    _operation.showAction = ^ {
        [UIView animateWithDuration:.35f animations:^{
            weak_operation.view.top = window.top;
        }];
    };
    
    _operation.hiddenAction = ^ {
        [UIView animateWithDuration:.35f animations:^{
            weak_operation.view.top = window.bottom;
        }];
    };
}

- (void)updatePurchaseQuantityWithOldQuantity:(int)oldQuantity
                               amountQuantity:(int)amountQuantity
                                     isOnSale:(BOOL)isOnSale
                                     complete:(UpdatePurchaseQuantity)updatePurchaseQuantity {
    
    _operation.defaultCount             =   oldQuantity;
    _operation.amountCount              =   amountQuantity;
    _operation.isOnSale                 =   isOnSale;
    _operation.updatePurchaseQuantity   =   updatePurchaseQuantity;
    
    [_operation show];
}


@end

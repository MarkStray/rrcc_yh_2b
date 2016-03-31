//
//  ProductCell.m
//  rrcc_yh
//
//  Created by user on 15/9/20.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "ProductCell.h"
#import "OperateManager.h"

@interface ProductCell () 

@end

@implementation ProductCell


- (void)awakeFromNib {
    // 鲜店字体没有改
    
    self.brandLbl.font = Font(14);
    self.titleLbl.font = Font(14);
    self.weightLbl.font = Font(12);
    self.avgPrice.font = Font(12);
    self.salePriceLbl.font = Font(14);
    self.oldPriceLbl.font = Font(12);
    
    self.CalcView.delegate = self;
    
    self.avgPrice.isWithStrikeThrough = NO;
    self.oldPriceLbl.isWithStrikeThrough = YES;//划线
    
    [self.brandLbl SetBorderWithcornerRadius:5.f BorderWith:1.f AndBorderColor:GLOBAL_COLOR];
    
    
}

- (void)updateUIUsingModel:(ProductsModel *)model {
    
    self.model = model;
    self.CalcView.count = model.count;// need
    
    self.onsaleImg.hidden = model.onsale.integerValue==1?NO:YES;
    
    sd_image_url(self.logoImgView, model.imgurl);
    
    self.titleLbl.text = model.skuname;
    
    self.weightLbl.text = model.spec;
    
    if (model.onsale.integerValue == 0) {
        self.salePriceLbl.text = [NSString stringWithFormat:@"￥%@",model.price];
        self.avgPrice.text = [NSString stringWithFormat:@"市场价￥%@",model.avgprice];

        self.oldPriceLbl.hidden = YES;
        
    } else {
        self.salePriceLbl.text = [NSString stringWithFormat:@"￥%@",model.saleprice];
        self.avgPrice.text = [NSString stringWithFormat:@"市场价￥%@",model.avgprice];

        self.oldPriceLbl.hidden = YES;
    }

}

- (void)CalculatorViewDidClickAddButton:(CalculatorView *)aView {
    if (self.model.onsale.intValue == 1) {
        if (self.CalcView.count == self.model.saleamount.intValue) {
            NSString *msg = [NSString stringWithFormat:@"亲,本促销品每单限购%d份!",self.model.saleamount.intValue];
            show_alertView(msg);
            return ;
        } else {
            self.model.count ++;
        }
    } else {
        if (self.CalcView.count == 999) {
            NSString *msg = [NSString stringWithFormat:@"亲!本商品每单最多能购买999份!"];
            show_alertView(msg);
            return ;
            
        } else {
            self.model.count ++;
        }
    }
    if (self.purchaseBlockCB) {
        if (self.purchaseBlockCB(self.model)) {
            self.CalcView.count = self.model.count;
        } else {
            self.model.count --;
            self.CalcView.count = self.model.count;
        }
    }
}

- (void)CalculatorViewDidClickReduceButton:(CalculatorView *)aView {
    self.model.count --;
    if (self.purchaseBlockCB) {
        if (self.purchaseBlockCB(self.model)) {
            self.CalcView.count = self.model.count;
        }
    }
}

- (void)CalculatorViewDidClickInputView:(CalculatorView *)aView {
    [self goOperation];
}

- (void)goOperation {
    int oldCount = self.model.count;
    int amountCount = self.model.saleamount.intValue;
    BOOL isOnSale = self.model.onsale.intValue==1 ? YES: NO;
    [[OperateManager defaultOperateManager] updatePurchaseQuantityWithOldQuantity:oldCount amountQuantity:amountCount isOnSale:isOnSale complete:^(int newQuantity) {
        if (self.purchaseBlockCB) {
            self.model.count = newQuantity;
            if (self.purchaseBlockCB(self.model)) {
                self.CalcView.count = newQuantity;
            } else {
                self.CalcView.count = 0;
                self.model.count    = 0;
            }
        }
    }];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

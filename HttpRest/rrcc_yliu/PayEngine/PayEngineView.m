//
//  PayEngineView.m
//  rrcc_yh
//
//  Created by user on 15/11/11.
//  Copyright © 2015年 ting liu. All rights reserved.
//

#import "PayEngineView.h"

@implementation PayEngineView
{
    NSMutableArray *_payBtnArray;
    NSMutableArray *_payImgArray;
    PayEngineType _payType;
}

#pragma mark - custom pay view

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _payBtnArray = [NSMutableArray array];
        _payImgArray = [NSMutableArray array];
        
        UILabel *title = [ZZFactory labelWithFrame:CGRectMake(0, 10, self.width, 20) font:Font(16) color:[UIColor darkGrayColor] text:@"请选择支付方式"];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        NSArray *payLogoImgs = @[@"Pay_WeChat",@"Pay_Ali"];
        NSArray *payTitles = @[@"微信支付",@"支付宝支付"];
        
        for (int i=0; i<payTitles.count; i++) {
            CGFloat offsetY = 35+(25+10)*i;
            [ZZFactory imageViewWithFrame:CGRectMake(16, offsetY, 25, 25) defaultImage:payLogoImgs[i] superView:self];
            [ZZFactory labelWithFrame:CGRectMake(50, offsetY, kScreenWidth-16*2-25*2, 25) font:Font(16) color:[UIColor darkGrayColor] text:payTitles[i] superView:self];
            
            UIImageView *img = [ZZFactory imageViewWithFrame:CGRectMake(self.width-32, offsetY, 25, 25) defaultImage:@"UnSelected"];
            if (i == 0) {
                _payType = PayEngineTypeWX;
                img.image = [UIImage imageNamed:@"Selected"];
            }
            [self addSubview:img];
            [_payImgArray addObject:img];
            
            UIButton *btn = [ZZFactory buttonWithFrame:CGRectMake(0, offsetY-5, kScreenWidth, 35) title:nil titleColor:nil image:nil bgImage:nil];
            btn.tag = 1001 + i;
            [btn addTarget:self action:@selector(payBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [_payBtnArray addObject:btn];
            
            [ZZFactory viewWithFrame:CGRectMake(0, btn.bottom, kScreenWidth, 1) color:BACKGROUND_COLOR superView:self];
        }
        
        UIButton *leftBtn = [ZZFactory buttonWithFrame:CGRectMake(30, 120, 60, 30) title:@"取消" titleColor:[UIColor darkGrayColor] image:nil bgImage:nil];
        [leftBtn addTarget:self action:@selector(popLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *rightBtn = [ZZFactory buttonWithFrame:CGRectMake(self.width-30-60, 120, 60, 30) title:@"确定" titleColor:[UIColor darkGrayColor] image:nil bgImage:nil];
        [rightBtn addTarget:self action:@selector(popRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        [self addSubview:rightBtn];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)popLeftBtnClick:(UIButton *)button {//取消
    if (self.cancelBlock) self.cancelBlock();
}

- (void)popRightBtnClick:(UIButton *)button {//支付
    if (self.confirmBlock) self.confirmBlock(_payType);
}

- (void)payBtnAction:(UIButton *)btn {
    _payType = btn.tag - 1001;
    for (int i=0; i<_payBtnArray.count; i++) {
        UIButton *button = (UIButton *)_payBtnArray[i];
        UIImageView *imageView = (UIImageView *)_payImgArray[i];
        if (btn.tag == button.tag) {
            imageView.image = [UIImage imageNamed:@"Selected"];
        } else {
            imageView.image = [UIImage imageNamed:@"UnSelected"];
        }
    }
}



@end

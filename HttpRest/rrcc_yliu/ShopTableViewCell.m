//
//  ShopTableViewCell.m
//  rrcc_yh
//
//  Created by lawwilte on 15/11/20.
//  Copyright © 2015年 ting liu. All rights reserved.
//

#import "ShopTableViewCell.h"

#import "UIImageView+WebCache.h"

#define kVegViewWidth 82
#define kVegViewHeight 92


@implementation ShopTableViewCell
{
    
    __weak IBOutlet UIView *view4;
    
    __weak IBOutlet UIView *view5;
    
    
    __weak IBOutlet UIImageView *portraitImageView;
    
    __weak IBOutlet UILabel *nameLabel;
    
    __weak IBOutlet UILabel *superMarketLabel;
    
    __weak IBOutlet ZZStarRating *starRating;
    
    __weak IBOutlet UILabel *actLabel;
    
    __weak IBOutlet UIImageView *reduceImg;
    
    __weak IBOutlet UIImageView *addImg;
    
    __weak IBOutlet UILabel *reduceLabel;
    
    __weak IBOutlet UILabel *addLabel;
    
}
- (void)awakeFromNib {
    
    nameLabel.font = Font(14);
    superMarketLabel.font = BoldFont(14);
    actLabel.font = Font(12);
    reduceLabel.font = Font(12);
    addLabel.font = Font(12);
    
    view4.hidden = YES;
    view5.hidden = YES;
    
    [portraitImageView SetBorderWithcornerRadius:5.f BorderWith:0 AndBorderColor:nil];
}

//更新主界面数据
-(void)updateUIWithModel:(PresellModel *)model {
    
    sd_image_url(portraitImageView, model.logo);
    
    nameLabel.text = model.contact;
    
    superMarketLabel.text = model.shop_name;
    
    [starRating setStarLevel:model.score.floatValue/5];
    
    actLabel.text = model.shop_desc;
    
    reduceLabel.text = [NSString stringWithFormat:@"单笔订单满%@减%@",model.discount_limit,model.discount];
    addLabel.text = [NSString stringWithFormat:@"单笔订单满%@赠送%@一份",model.gift_limit,model.gift];
}


@end

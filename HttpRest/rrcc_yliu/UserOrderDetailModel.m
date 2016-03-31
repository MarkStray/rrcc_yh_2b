//
//  UserOrderDetailModel.m
//  rrcc_yh
//
//  Created by user on 15/7/2.
//  Copyright (c) 2015年 ting liu. All rights reserved.
//

#import "UserOrderDetailModel.h"

@implementation UserOrderDetailModel

- (id)initWithDictionary:(NSDictionary*)jsonDic {
    if ((self = [super init])) {
        self.productItemList = [NSMutableArray array];
        self.actionList = [NSMutableArray array];
        self.statusList = [NSMutableArray array];
        
        [self setValuesForKeysWithDictionary:jsonDic];
    }
    return self;
}

+ (id)creatWithDictionary:(NSDictionary *)jsonDic {
    return [[self alloc] initWithDictionary:jsonDic];
}

@end

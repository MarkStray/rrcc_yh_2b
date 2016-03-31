//
//  BLEViewController.h
//  rrcc_distribution
//
//  Created by lawwilte on 9/21/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import "XHBaseViewController.h"

@interface BLEViewController : XHBaseViewController

-(void)PrintWithInfoDic:(NSDictionary*)InfoDic;

- (void)doPrintWithInfoDic:(NSMutableDictionary *)infoDic;

@end

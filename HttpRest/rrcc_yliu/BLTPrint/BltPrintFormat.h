//
//  BltPrintFormat.h
//  rrcc_sj
//
//  Created by lawwilte on 7/9/15.
//  Copyright (c) 2015 ting liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BltPrintFormat : NSObject{
    /**
     *最后需要打印的字符串
     */
    NSString *EndPrintString;
}

@property (strong,nonatomic) CBPeripheral *ConnectPhera;
@property (strong,nonatomic) NSString       *ConnectState;
@property (strong,nonatomic) NSMutableArray *ConnectPerpheras;
+(BltPrintFormat*)ShareBLTPrint;

//标题居中对齐
-(NSString*)PrintTitleInCenter:(NSString*)Title;

//根据订单信息动态打印
-(NSString*)AppendNames:(NSMutableArray *)NameList Nums:(NSMutableArray *)NumList Prices:(NSMutableArray *)Prices Weight:(NSMutableArray*)Weights;

@end

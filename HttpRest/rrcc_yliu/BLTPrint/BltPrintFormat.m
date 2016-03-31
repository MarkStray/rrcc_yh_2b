//
//  BltPrintFormat.m
//  rrcc_sj
//
//  Created by lawwilte on 7/9/15.
//  Copyright (c) 2015 ting liu. All rights reserved.
//

#import "BltPrintFormat.h"

/** 打印纸一行最大的字节
 *
 */

static int LINE_TOTAL_SIZE  = 32;//打印纸的字符长度为32
static int LEFT_BYTE_SIZE   = 15;//左边最大的字符 //15个字符
static int RIGHT_BYTE_SIZE  = 7; //右边最大字符//7个字节

@implementation BltPrintFormat
@synthesize ConnectPhera,ConnectState,ConnectPerpheras;

//单例
+(BltPrintFormat*)ShareBLTPrint{
    static BltPrintFormat *instance = nil;
    @synchronized(self){
        if (!instance){
            instance = [[BltPrintFormat alloc] init];
        }
    }
    return instance;
}

#pragma mark  标题居中对齐
-(NSString*)PrintTitleInCenter:(NSString *)Title{
    EndPrintString = @"";
    for(int i=0;i<(LINE_TOTAL_SIZE - [self GetStringBytesLenth:Title])/2;i++){
        EndPrintString = [EndPrintString stringByAppendingString:@" "];
    }
    EndPrintString = [EndPrintString stringByAppendingString:Title];
    return EndPrintString;
}

-(NSString*)AppendNames:(NSMutableArray *)NameList Nums:(NSMutableArray *)NumList Prices:(NSMutableArray *)Prices Weight:(NSMutableArray*)Weights{
    NSString *OrderInfoStr;
    NSString *NameStr;
    NSString *NumStr;
    NSString *PriceStr;
    NSString *WeightStr;
    int NumWeightLenth;
    int numPrefixLenth;
    int pricePrefixLenth;
    
    NSMutableArray *Array = [[NSMutableArray alloc]init];
    for (int i=0;i<NameList.count;i++){
        NameStr  = [NameList objectAtIndex:i];
        NumStr   = [NumList  objectAtIndex:i];
        PriceStr = [Prices   objectAtIndex:i];
        WeightStr= [Weights  objectAtIndex:i];
        //去除字符串里的空格
        NameStr  = [NameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        numPrefixLenth   = [self GetStringBytesLenth:NumStr];
        pricePrefixLenth = [self GetStringBytesLenth:PriceStr];
        
        NSString *SerialNumber = [NSString stringWithFormat:@"%d%@",i+1,@"."];
        NSString *NumWeightStr = [NSString stringWithFormat:@"%@%@%@%@",@"  ",WeightStr,@"克/份x",NumStr];//数量重量
        NSString *CenterStr    = @" 小计:";
        NumWeightLenth  = [self GetStringBytesLenth:NumWeightStr];
        for (int i=0;i<LEFT_BYTE_SIZE-NumWeightLenth;i++){
            NumWeightStr   =[NumWeightStr stringByAppendingString:@" "];
        }
        NSString *numPrice = [NSString stringWithFormat:@"%.2f",[NumStr floatValue]*[PriceStr floatValue]];
        for (int i=0;i<RIGHT_BYTE_SIZE-pricePrefixLenth;i++){
            EndPrintString = @" ";
            numPrice = [EndPrintString stringByAppendingString:numPrice];
        }
        NSString *ItemInfo = [NSString stringWithFormat:@"%@%@\n%@%@%@%@\n",SerialNumber,NameStr,NumWeightStr,CenterStr,numPrice,@"元"];
        OrderInfoStr = [NSString stringWithFormat:@"%@",ItemInfo];
        [Array addObject:OrderInfoStr];
    }
    NSString *Str = [Array componentsJoinedByString:@""];
    return Str;
}



/**
 * 获取字符串字节长度
 * @param string
 * @return sting
*/
-(int)GetStringBytesLenth:(NSString *)strtemp{
    int strlenth = 0;
    char *p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];i++){
        if (*p){
            p++;
            strlenth++;
        }else{
            p++;
        }
    }
    return strlenth;
}

@end

//
//  BleManager.h
//  rrcc_distribution
//
//  Created by lawwilte on 9/23/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BleManagerDelegate <NSObject>

-(void)bleMangerConnectedPeripheral :(BOOL)isConnect;
-(void)bleMangerDisConnectedPeripheral :(CBPeripheral *)_peripheral;
-(void)bleMangerReceiveDataPeripheralData :(NSData *)data from_Characteristic :(CBCharacteristic *)curCharacteristic;

@end

@interface BleManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *_m_manager;
    CBPeripheral     *_m_peripheral;
    NSMutableArray   *m_array_peripheral;
    NSMutableArray   *peripheralsArray;
    CBCharacteristic *writeCharacteristic;//写入数据的Characyeristic
    CBPeripheral     *connectPeripheral;
}


+(BleManager*)shareInstance;

@property(nonatomic,copy)     NSMutableArray   *m_array_peripheral;
@property(nonatomic,copy)     NSMutableArray   *peripheralsArray;
@property(nonatomic,strong)   CBCentralManager *m_manger;
@property(nonatomic,strong)   CBPeripheral     *m_peripheral;
@property(weak,nonatomic) id<BleManagerDelegate> mange_delegate;

-(void)initCentralManger;
- (void)sendValue:(CBPeripheral*)peripheral sendData:(NSData *)data type:(CBCharacteristicWriteType)type;
-(void)sendData:(NSData*)data  type:(CBCharacteristicWriteType)type;

-(void)disConnectPeripheral;
@end

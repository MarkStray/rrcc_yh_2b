//
//  BlePeripheral.h
//  rrcc_distribution
//
//  Created by lawwilte on 9/23/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlePeripheral : NSObject
@property(nonatomic,copy) CBPeripheral *m_peripheral;
@property(nonatomic,copy) NSString *m_peripheralIdentifier;
@property(nonatomic,copy) NSString *m_peripheralLocaName;
@property(nonatomic,copy) NSString *m_peripheralName;
@property(nonatomic,copy) NSString *m_peripheralUUID;
@property(nonatomic,copy) NSNumber *m_peripheralRSSI;
@property(nonatomic)      NSInteger  m_peripheralServices;
@end

//
//  Commom.h
//  rrcc_distribution
//
//  Created by lawwilte on 9/23/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Header.h"

@interface Commom : NSObject

AS_SINGLETON(Commom);
@property(nonatomic,copy)CBPeripheral *currentPeripheral;
@end

//
//  BlePeripheral.m
//  rrcc_distribution
//
//  Created by lawwilte on 9/23/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import "BlePeripheral.h"

@implementation BlePeripheral

-(id) init{
    if((self = [super init])) {
        self.m_peripheralIdentifier = @"";
        self.m_peripheralLocaName   = @"";
        self.m_peripheralName       = @"";
        self.m_peripheralUUID       = @"";
        self.m_peripheralRSSI       = 0;
        self.m_peripheralServices   = 0;
    }
    return self;
}

@end

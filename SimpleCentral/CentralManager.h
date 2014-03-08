//
//  CentralManager.h
//  SimpleCentral
//
//  Created by Nicolas Flacco on 3/8/14.
//  Copyright (c) 2014 Nicolas Flacco. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@class CentralManager;

@protocol CentralManagerDelegate <NSObject>

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral rssi:(NSNumber *)RSSI;
- (void)receivedFromPerpiheral:(CBPeripheral *)peripheral msg:(NSString *)msg;

@end

@interface CentralManager : NSObject

@property(nonatomic) id <CentralManagerDelegate> delegate;

+ (CentralManager*)sharedInstance;
- (void)startScanning;
- (void)stopScanning;

@end

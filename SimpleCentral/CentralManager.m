//
//  CentralManager.m
//  SimpleCentral
//
//  Created by Nicolas Flacco on 3/8/14.
//  Copyright (c) 2014 Nicolas Flacco. All rights reserved.
//

#import "CentralManager.h"
#import "BLEInfo.h"

@interface CentralManager() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic,strong) CBCentralManager    *centralManager;
@property(nonatomic,strong) NSMutableDictionary *peripherals;

@end

@implementation CentralManager

+ (CentralManager *)sharedInstance
{
    static dispatch_once_t once=0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    if (self=[super init]) {
        _peripherals = [[NSMutableDictionary alloc] init];
        
        // TODO: Init CBCentralManager and a queue
        
    }
    return self;
}

- (void)startScanning
{
    NSLog(@"CM Scanning started");
    // TODO
}

- (void)stopScanning
{
    NSLog(@"CM Scanning stopped");
    // TODO
}

- (void)addPeripheral:(CBPeripheral *)peripheral
{
    
    [_peripherals setObject:[[NSMutableArray alloc] init]
                     forKey:peripheral];
}

- (void)removePeripheral:(CBPeripheral *)peripheral
{
    [_peripherals removeObjectForKey:peripheral];
}

- (NSMutableArray *)getPeripheralQueue:(CBPeripheral *)peripheral
{
    return [_peripherals objectForKey:peripheral];
}


#pragma mark - CBCentralManager delegate methods

//call on init of centralManager to check if BT is supported and available
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Give class this -> Key point is you cannot scan before hardware is ready
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        
        // TODO
        
    }else if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }else if ([central state] == CBCentralManagerStateResetting) {
        NSLog(@"CoreBluetooth BLE hardware is resetting");
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"CM Discovered name:%@ id:%@ rssi:%@", peripheral.name, [peripheral.identifier UUIDString] , RSSI);
    // TODO
}

/** If the connection fails for whatever reason, we need to deal with it. */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"CM Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    // TODO
}

/** Once the disconnection happens, we need to clean up our local copy of the peripheral */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // TODO
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"CM Peripheral didConnectPeripheral:%@", peripheral.identifier);
    // TODO
}

/** The Transfer Service was discovered */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // TODO
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"CM didDiscoverCharacteristicsForService");
    // TODO
}

/** The peripheral letting us know whether our subscribe/unsubscribe happened or not */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // TODO
}

/** This callback lets us know more data has arrived via notification on the characteristic.
 Specifically, this means that the Peripheral wants to send data to us (analagous to a server push
 notification). */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"CM didUpdateValueForCharacteristic: %@", characteristic.UUID);
    // TODO
}

@end
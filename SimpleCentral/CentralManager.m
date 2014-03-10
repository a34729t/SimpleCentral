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
        // We create a queue and start the central manager
        dispatch_queue_t queue=dispatch_queue_create("com.flaccoDev.centralqueue", 0);
        _centralManager=[[CBCentralManager alloc]initWithDelegate:self
                                                            queue:queue
                                                          options:nil];
        _peripherals = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)startScanning
{
    // Scanning and detecting are used in a similar fashion and the literature
    // BEWARE which UUID you are using. Also, created the CBUUID, don't just give it a string
    [_centralManager scanForPeripheralsWithServices:@[SERVICE_CBUUID]
                                            options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    NSLog(@"CM Scanning started");
}

- (void)stopScanning
{
    [_centralManager stopScan];
    NSLog(@"CM Scanning stopped");
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
        [self startScanning];
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
    
    //Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) return;
    
    // Attempt connection
    [self addPeripheral:peripheral]; // NOTE: We need to retain the peripheral!!!!
    [_centralManager connectPeripheral:peripheral options:nil];
    
    // NOTE: Delagates to UI fire in main thread
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_delegate didDiscoverPeripheral:peripheral rssi:RSSI];
    });
}

/** If the connection fails for whatever reason, we need to deal with it. */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"CM Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self removePeripheral:peripheral];
}

/** Once the disconnection happens, we need to clean up our local copy of the peripheral */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
        NSLog(@"CM Peripheral Disconnected error: %@", error);
    else
        NSLog(@"CM Peripheral Disconnected");
    
    [self removePeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"CM Peripheral didConnectPeripheral:%@", peripheral.identifier);
    peripheral.delegate = self;
    [peripheral discoverServices:@[SERVICE_CBUUID]];
}

/** The Transfer Service was discovered */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"CM Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service with uuid:%@", service.UUID);
        if ([service.UUID isEqual:SERVICE_CBUUID]) {
            NSLog(@"CM didDiscoverServices->discoverCharacteristics");
            [peripheral discoverCharacteristics:@[NOTIFY_CHARACTERISTIC_CBUUID] forService:service];
        }
    }
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"CM didDiscoverCharacteristicsForService");
    // Deal with errors (if any)
    if (error) {
        NSLog(@"CM:Error didDiscoverCharacteristicsForService: %@ for service: %@", [error localizedDescription], service.UUID);
        [self removePeripheral:peripheral];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:NOTIFY_CHARACTERISTIC_CBUUID])
        {
            NSLog(@"CM didDiscoverCharacteristicsForService: 'notify'");
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    // Once this is complete, we just need to wait for the data to come in.
}

/** The peripheral letting us know whether our subscribe/unsubscribe happened or not */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:NOTIFY_CHARACTERISTIC_CBUUID]){
        if (characteristic.isNotifying)
        {
            NSLog(@"CM didUpdateNotificationStateForCharacteristic on %@", characteristic);
        }
        else
        {
            NSLog(@"CM didUpdateNotificationStateForCharacteristic off %@", characteristic);
            [self removePeripheral:peripheral];
        }
    }
}

/** This callback lets us know more data has arrived via notification on the characteristic.
 Specifically, this means that the Peripheral wants to send data to us (analagous to a server push
 notification). */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"CM didUpdateValueForCharacteristic: %@", characteristic.UUID);
    
    if (error || ![characteristic value]) {
        NSLog(@"CM Error didUpdateValueForCharacteristic: %@ for service: %@", [error localizedDescription], characteristic.UUID);
        return;
    }
    
    if ([characteristic.UUID isEqual:NOTIFY_CHARACTERISTIC_CBUUID])
    {
        NSMutableArray *queue = [self getPeripheralQueue:peripheral];
        NSData *chunk = characteristic.value;
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"CM rx chunk: %@", stringFromData);
        
        if ([chunk isEqual:[self eom]]) {
            NSData *unchunkedData = [self unchunkData:queue];
            
            NSString *fullString = [[NSString alloc] initWithData:unchunkedData encoding:NSUTF8StringEncoding];
            NSLog(@"CM **DUVFC Received: %@**", fullString);
            
            // NOTE: Delagates to UI fire in main thread
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_delegate receivedFromPerpiheral:peripheral msg:fullString];
            });
        }else{
            NSLog(@"addChunk to rxQueue");
            [queue addObject:chunk];
        }
    }
}


#pragma mark - Message chunking functions

- (NSData *) eom
{
    return [[NSData alloc]init]; // empty data // empty data
}

- (NSData *) unchunkData:(NSMutableArray *)queue
{
    // Called when we've received an EOM
    
    if ([queue isEqual:nil] || [queue count] == 0)
        return nil;
    
    NSMutableData *completeData = [[NSMutableData alloc] init];
    while ([queue count] > 0) {
        NSData *data = [self dequeue:queue];
        if (data != nil) {
            [completeData appendData:data];
        }
    }
    return [NSData dataWithData:completeData];
}

- (NSData *) dequeue:(NSMutableArray *)queue {
    id head = [queue objectAtIndex:0];
    if (head != nil) {
        [queue removeObjectAtIndex:0];
        return (NSData *)head;
    } else {
        return nil;
    }
}


@end

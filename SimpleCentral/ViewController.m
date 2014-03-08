//
//  ViewController.m
//  SimpleCentral
//
//  Created by Nicolas Flacco on 3/8/14.
//  Copyright (c) 2014 Nicolas Flacco. All rights reserved.
//

#import "ViewController.h"
#import "CentralManager.h"

@interface ViewController () <CentralManagerDelegate>

@property(nonatomic,strong) CentralManager *centralManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _centralManager = [CentralManager sharedInstance];
    _centralManager.delegate = self;
    [_centralManager startScanning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didDiscoverPeripheral:(CBPeripheral *)peripheral rssi:(NSNumber *)RSSI
{
    NSLog(@"VC didDiscoverPeripheral:%@ rssi:%@", peripheral.identifier, RSSI);
}

- (void)receivedFromPerpiheral:(CBPeripheral *)peripheral msg:(NSString *)msg
{
    NSLog(@"VC receivedFromPerpiheral:%@ msg:%@", peripheral, msg);
}

@end

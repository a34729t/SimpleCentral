//
//  ViewController.m
//  SimpleCentral
//
//  Created by Nicolas Flacco on 3/8/14.
//  Copyright (c) 2014 Nicolas Flacco. All rights reserved.
//

#import "ViewController.h"
#import "CentralManager.h"

#define screenFlashInterval .3
#define screenFlashTimeOut  1

@interface ViewController () <CentralManagerDelegate>

@property(nonatomic,strong) CentralManager *centralManager;
@property(nonatomic,strong) UIView *overlay;
@property(nonatomic)BOOL slTimeOut;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _centralManager = [CentralManager sharedInstance];
    _centralManager.delegate = self;
    
    // Overlay: Flash a UIView on the screen in the color Twitter Blue for time=screenFlashInterval,
    // with a 1 flash maximum per time=screenFlashTimeOut
    self.overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlay.backgroundColor = [UIColor colorWithRed:(85.0/255.0) green:(172.0/255.0) blue:(238.0/255.0) alpha:1.0];
    [self.view addSubview:self.overlay];
    self.overlay.alpha = 0.0; // change to set overlay transparency
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
    [self flashScreen];
}

#pragma mark - Overlay stuff

- (void)flashScreen
{
    if(!self.slTimeOut){
        self.overlay.alpha=0.7;
        [self.view setNeedsDisplay];
        [NSTimer scheduledTimerWithTimeInterval:screenFlashInterval target:self selector:@selector(resetOverlay) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:screenFlashTimeOut target:self selector:@selector(resetSLTimer) userInfo:nil repeats:NO];
        self.slTimeOut=YES;
    }
}

- (void)resetOverlay
{
    self.overlay.alpha = 0.0;
}

- (void)resetSLTimer
{
    self.slTimeOut=NO;
}

@end

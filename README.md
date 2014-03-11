# Simple Central

This is a demonstration of the basic functionality of Apple's CoreBluetooth Framework. We construct
a CBCentralManager that connects to Peripherals and subscribes to their characteristics to retrieve
data. Watch the log messages carefully!

## Important Files

* Lecture.pptx - lecture notes
* BLEInfo.h - configuration file
* CentralManager.h/.m - connect to a peripheral to retrieve data from it

## Branches

* master
* simplemsg - simple notifications (single packet) from peripheral
* chunkmsg - multi-packet notifications from peripheral
* twitteru - most of the logic is stripped out of the CentralManager for learning purposes
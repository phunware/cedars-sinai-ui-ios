//
//  PWCoreDevice.h
//  PWCore
//
//  Copyright (c) 2015 Phunware. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface PWCoreDevice : NSObject

+ (NSString *)macaddress;
+ (NSString *)hardwareModel;
+ (NSString *)IPAddress;
+ (NSString *)carrierName;
+ (NSString *)timestamp;
+ (NSString *)systemVersion;
+ (NSDictionary *)currentWifi;
+ (NSString *)connection;
+ (NSString *)userAgent;
+ (BOOL)wifiEnabled;
+ (BOOL)pushEnabled;
+ (BOOL)bluetoothEnabled;

+ (NSDictionary *)locationInfo;
+ (NSDictionary *)addressInfo;

+ (NSString *) uniqueDeviceIdentifier;
+ (NSString *) uniqueGlobalDeviceIdentifier;
+ (NSDictionary*) uniqueGlobalDeviceIdentifierInfo;

// Convenience
+ (NSDateFormatter *)standardDateFormatter;


@end

//
//  DeviceVirtualUUID.h
//  MBProgressHUD
//
//  Created by 刘江 on 2019/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceVirtualUUID : NSObject
+ (NSString *)virtualDeviceUUID;
+ (NSString *)virtualDeviceMacAddress;
+ (NSString *)virtualBlueToothUUID;
+ (NSString *)virtualBlueToothMac;

@end

NS_ASSUME_NONNULL_END

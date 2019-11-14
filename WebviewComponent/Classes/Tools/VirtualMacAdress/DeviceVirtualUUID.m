//
//  DeviceVirtualUUID.m
//  MBProgressHUD
//
//  Created by 刘江 on 2019/11/12.
//

#import "DeviceVirtualUUID.h"
#import "LLWebKeyChainSaver.h"
#define kTargetName [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey]

@implementation DeviceVirtualUUID
+ (NSString *)virtualDeviceUUID {
    NSString *keyChain_key = [NSString stringWithFormat: @"%@_Device_UUID", kTargetName];
    NSString *UUID = (NSString *)[LLWebKeyChainSaver loadByKey:keyChain_key];
    
    //首次执行该方法时，uuid为空
    if (!UUID || UUID.length < 1) {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
        UUID = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(uuidString);
        CFRelease(uuidRef);
        [LLWebKeyChainSaver saveWithKey:keyChain_key data:UUID];
        
    }
    return UUID;
  
}

+ (NSString *)virtualDeviceMacAddress {
    NSString *keyChain_key = [NSString stringWithFormat: @"%@_Device_MAC", kTargetName];
    NSString *mac = (NSString *)[LLWebKeyChainSaver loadByKey:keyChain_key];
    //首次执行该方法时，uuid为空
    if (!mac || mac.length < 1) {
        //0-9 48~57  A-F 65~70
        mac = [NSString string];
        int temp = 0;
        for (int i = 0; i < 12; i++) {
            int i = arc4random()%16;
            if (i < 10) {
                mac = [mac stringByAppendingString:[NSString stringWithFormat:@"%c", arc4random()%10+48]];
            }else {
                mac = [mac stringByAppendingString:[NSString stringWithFormat:@"%c", arc4random()%6+65]];
            }
            temp++;
            if (temp % 2 == 0) {
                mac = [mac stringByAppendingString:@":"];
                temp = 0;
            }
        }
        if (mac.length > 1) {
            mac = [mac stringByReplacingCharactersInRange:NSMakeRange(mac.length-1, 1) withString:@""];
        }
        [LLWebKeyChainSaver saveWithKey:keyChain_key data:mac];
    }
    return mac;
}

+ (NSString *)virtualBlueToothUUID {
    NSString *keyChain_key = [NSString stringWithFormat: @"%@_BlueTooth_UUID", kTargetName];
    NSString *UUID = (NSString *)[LLWebKeyChainSaver loadByKey:keyChain_key];
    
    //首次执行该方法时，uuid为空
    if (!UUID || UUID.length < 1) {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
        UUID = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(uuidString);
        CFRelease(uuidRef);
        [LLWebKeyChainSaver saveWithKey:keyChain_key data:UUID];
        
    }
    return UUID;
}

+ (NSString *)virtualBlueToothMac {
    NSString *keyChain_key = [NSString stringWithFormat: @"%@_BlueTooth_MAC", kTargetName];
    NSString *bleMac = (NSString *)[LLWebKeyChainSaver loadByKey:keyChain_key];
    //首次执行该方法时，uuid为空
    if (!bleMac || bleMac.length < 1) {
        //0-9 48~57  A-F 65~70
        bleMac = [NSString string];
        int temp = 0;
        for (int i = 0; i < 12; i++) {
            int i = arc4random()%16;
            if (i < 10) {
                bleMac = [bleMac stringByAppendingString:[NSString stringWithFormat:@"%c", arc4random()%10+48]];
            }else {
                bleMac = [bleMac stringByAppendingString:[NSString stringWithFormat:@"%c", arc4random()%6+65]];
            }
            temp++;
            if (temp % 2 == 0) {
                bleMac = [bleMac stringByAppendingString:@":"];
                temp = 0;
            }
        }
        if (bleMac.length > 1) {
           bleMac = [bleMac stringByReplacingCharactersInRange:NSMakeRange(bleMac.length-1, 1) withString:@""];
        }
        [LLWebKeyChainSaver saveWithKey:keyChain_key data:bleMac];
    }
    return bleMac;
}

@end

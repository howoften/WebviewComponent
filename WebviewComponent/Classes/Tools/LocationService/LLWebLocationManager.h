//
//  LocationManager.h
//  SJTransport
//
//  Created by Liu Jiang on 2017/8/10.
//  Copyright © 2017年 jiang liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LLWebLocationManager : NSObject
@property (nonatomic, strong, readonly)NSString *country;
@property (nonatomic, strong, readonly)NSString *province;
@property (nonatomic, strong, readonly)NSString *city;
@property (nonatomic, strong, readonly)NSString *region;
@property (nonatomic, strong, readonly)NSString *street;
@property (nonatomic, strong, readonly)NSString *detailAddress;
@property (nonatomic, assign, readonly)CLLocationCoordinate2D coordinate2D;
@property (nonatomic, strong)NSDate *locateDate;
@property (nonatomic, strong)void(^AuthorizationBlock)(void);

+ (instancetype)defaultManager;
- (void)requestLocationInSlience;
- (void)requestLocationInfo:(void(^)(NSDictionary *, NSError *))locationInfo maxToleranceTime:(NSTimeInterval)tolerance;

- (double)distanceFromStartLatitude:(double)startLatitude startLongitude:(double)startLongitude endLatitude:(double)endLatitude endLongitude:(double)endLongitude;
@end

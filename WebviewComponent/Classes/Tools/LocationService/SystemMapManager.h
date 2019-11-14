//
//  SystemMapManager.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/11/23.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemMapManager : NSObject

+ (void)openMapView;

+ (void)openMapWithCenterLatitude:(double)centerLatitude centerLongitude:(double)centerLongitude;


+ (void)mapNavigationFromStartLatitude:(double)startLatitude startLongitude:(double)startLongitude toEndLatitude:(double)endLatitude endLongitude:(double)endLongitude;

+ (void)mapNavigationToEndLatitude:(double)endLatitude endLongitude:(double)endLongitude;

@end

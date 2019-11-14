//
//  SystemMapManager.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/11/23.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SystemMapManager.h"

@implementation SystemMapManager

+ (void)openMapWithCenterLatitude:(double)centerLatitude centerLongitude:(double)centerLongitude {
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate2D addressDictionary:nil]];
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsMapCenterKey:[NSValue valueWithMKCoordinate:coordinate2D], MKLaunchOptionsMapSpanKey:[NSValue valueWithMKCoordinateSpan:span]}];

}

+ (void)openMapView {
    
    MKMapItem *current = [MKMapItem mapItemForCurrentLocation];
    [current openInMapsWithLaunchOptions:nil];
}

+ (void)mapNavigationFromStartLatitude:(double)startLatitude startLongitude:(double)startLongitude toEndLatitude:(double)endLatitude endLongitude:(double)endLongitude {
    CLLocationCoordinate2D coordinate2D_from = CLLocationCoordinate2DMake(startLatitude, startLongitude);
    CLLocationCoordinate2D coordinate2D_to = CLLocationCoordinate2DMake(endLatitude, endLongitude);

    MKMapItem *mapItem_from = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate2D_from addressDictionary:nil]];
    MKMapItem *mapItem_to = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate2D_to addressDictionary:nil]];
    [MKMapItem openMapsWithItems:@[mapItem_from, mapItem_to] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDefault, MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard), MKLaunchOptionsShowsTrafficKey:@(YES)}];
}

+ (void)mapNavigationToEndLatitude:(double)endLatitude endLongitude:(double)endLongitude {
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(endLatitude, endLongitude);
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate2D addressDictionary:nil]];
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDefault, MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard), MKLaunchOptionsShowsTrafficKey:@(YES)}];
}

@end

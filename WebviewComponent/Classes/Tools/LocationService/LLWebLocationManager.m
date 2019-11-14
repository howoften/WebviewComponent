//
//  LocationManager.m
//  SJTransport
//
//  Created by Liu Jiang on 2017/8/10.
//  Copyright © 2017年 jiang liu. All rights reserved.
//

#import "LLWebLocationManager.h"

@interface LLWebLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)CLGeocoder *geocoder;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate2D;
@property (nonatomic, assign)BOOL skipForClAuth;
@property (nonatomic, strong)NSMutableDictionary *taskTable;
//@property (nonatomic, strong)NSMutableArray *notifyErrorTasks;
@property (nonatomic, assign)CLAuthorizationStatus authState;
@end

static BOOL didLocate = NO;

@implementation LLWebLocationManager
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        if ([CLLocationManager locationServicesEnabled]) {
            if ([NSThread currentThread] != [NSThread mainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _locationManager = [[CLLocationManager alloc] init];
                    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
                        [_locationManager requestWhenInUseAuthorization];
                    }
                    _locationManager.delegate = self;
                    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                    _locationManager.distanceFilter = 100;
                });
            }else {
                _locationManager = [[CLLocationManager alloc] init];
                if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
                    [_locationManager requestWhenInUseAuthorization];
                }
                _locationManager.delegate = self;
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                _locationManager.distanceFilter = 100;
            }
        }
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}
static LLWebLocationManager *_manager = nil;

+ (instancetype)defaultManager {
    return [[LLWebLocationManager alloc] init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:NULL];
        _manager.coordinate2D = kCLLocationCoordinate2DInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:_manager selector:@selector(checkLocationAuthState) name:UIApplicationWillEnterForegroundNotification object:nil];
        _manager.locateDate = [NSDate date];
        _manager.taskTable = [NSMutableDictionary dictionaryWithCapacity:0];
//        _manager.notifyErrorTasks = [NSMutableArray array];
        
    });
    return _manager;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) && self.authState != kCLAuthorizationStatusAuthorizedWhenInUse && self.authState != kCLAuthorizationStatusAuthorizedAlways) {
        NSDictionary *tasks_copy = [self.taskTable copy];
        [self.taskTable removeAllObjects];
        [tasks_copy enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            float tolerance = [[key componentsSeparatedByString:@"-"].lastObject floatValue];
            [self requestLocationInfo:obj maxToleranceTime:tolerance];
        }];
        
        [_locationManager startUpdatingLocation];
    }
    self.authState = status;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    didLocate = NO;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ( [[UIApplication sharedApplication] canOpenURL: url] ) {
                _skipForClAuth = YES;
                NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
       
    }
    
    [self notifyLocateResult:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.firstObject;
    //获取经纬度的 结构体
    self.coordinate2D = location.coordinate;
    [self.locationManager stopUpdatingLocation];
    [self getAddressWithCoordinate:self.coordinate2D];
    
    _locateDate = [NSDate date];
}
#pragma mark -- 获取经纬度
//反向地理编码, 通过经纬度获取地理位置
- (void)getAddressWithCoordinate:(CLLocationCoordinate2D)coordinate {
    //先创建CLLocation位置对象
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0)
        {
            didLocate = YES;
            //取出地标
            CLPlacemark *placemark = [placemarks firstObject];
            _coordinate2D = placemark.location.coordinate;
            //获取的位置都在字典中
            if (placemark.locality) {
                _city = placemark.locality;
            }else {
                _city = placemark.administrativeArea;
            }
            _city = placemark.addressDictionary[@"City"];
            _country = placemark.addressDictionary[@"Country"];
            if (placemark.addressDictionary[@"State"]) {
                _province = placemark.addressDictionary[@"State"];
            }else {
                _province = placemark.addressDictionary[@"City"];
            }
            _region = placemark.addressDictionary[@"SubLocality"];
            _street = placemark.addressDictionary[@"Street"];
            if ([_city isEqualToString:_province]) {
                _detailAddress = [NSString stringWithFormat:@"%@%@%@", _city?_city:@"", _region?_region:@"", _street?_street:@""];
            }else {
                _detailAddress = [NSString stringWithFormat:@"%@%@%@%@", _country, _city?_city:@"", _region?_region:@"", _street?_street:@""];
                
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(execAllTasks) object:nil];
            [self execAllTasks];
        }else if (error) {
            NSLog(@"error occurred %@", error);
        }
    }];
}
- (void)requestLocationInSlience {
    
    CLLocationManager *m = [self locationManager];
    [m startUpdatingLocation];
}

- (void)requestLocationInfo:(void(^)(NSDictionary *, NSError *))locationInfo maxToleranceTime:(NSTimeInterval)tolerance {
    [self requestLocationInSlience];
    if (locationInfo) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self performSelector:@selector(execAllTasks) withObject:nil afterDelay:tolerance];
        }
        NSString *key = [NSString stringWithFormat:@"%p-%f", locationInfo, tolerance];
        [self.taskTable setObject:locationInfo forKey:key];
        if (![CLLocationManager locationServicesEnabled]) {
            [self notifyLocateResult:[NSError errorWithDomain:@"com.liangla.locationService" code:-4000 userInfo:[NSDictionary dictionaryWithObject:@"定位服务关闭或gps故障" forKey:NSLocalizedDescriptionKey]]];
        }
    }
}

- (void)assembData:(void(^)(NSDictionary *))locationInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
    [info setObject:self.locateDate forKey:@"locateDate"];
    if (didLocate) {
        [info setObject:self.country?self.country:@"" forKey:@"country"];
        [info setObject:self.province?self.province:@"" forKey:@"province"];
        [info setObject:self.city?self.city:@"" forKey:@"city"];
        [info setObject:self.region?self.region:@"" forKey:@"region"];
        [info setObject:self.street?self.street:@"" forKey:@"street"];
        [info setObject:self.detailAddress?self.detailAddress:@"" forKey:@"detailAddress"];
        [info setObject:[NSString stringWithFormat:@"%f", self.coordinate2D.longitude] forKey:@"longitude"];
        [info setObject:[NSString stringWithFormat:@"%f", self.coordinate2D.latitude] forKey:@"latitude"];
    }
    if (locationInfo) {
        locationInfo(info);
    }
    NSDictionary *taskTable_copy = [self.taskTable copy];
    [taskTable_copy enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:locationInfo]) {
            [self.taskTable removeObjectForKey:key];
        }
    }];
}
- (double)distanceFromStartLatitude:(double)startLatitude startLongitude:(double)startLongitude endLatitude:(double)endLatitude endLongitude:(double)endLongitude {
    //第一个坐标
    CLLocation *start = [[CLLocation alloc] initWithLatitude:startLatitude longitude:startLongitude];
    //第二个坐标
    CLLocation *end = [[CLLocation alloc] initWithLatitude:endLatitude longitude:endLongitude];
    // 计算距离 (m)
    CLLocationDistance meters=[start distanceFromLocation:end];
    
    return meters;
}
- (void)checkLocationAuthState {
    
    if (_skipForClAuth == YES) {
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) && self.authState != kCLAuthorizationStatusAuthorizedWhenInUse && self.authState != kCLAuthorizationStatusAuthorizedAlways) {
            [self requestLocationInSlience];
        }
        _skipForClAuth = NO;
    }
}

- (void)execAllTasks {
    [self.taskTable enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:0];
        [info setObject:self.locateDate forKey:@"locateDate"];
        if (didLocate) {
            [info setObject:self.country?self.country:@"" forKey:@"country"];
            [info setObject:self.province?self.province:@"" forKey:@"province"];
            [info setObject:self.city?self.city:@"" forKey:@"city"];
            [info setObject:self.region?self.region:@"" forKey:@"region"];
            [info setObject:self.street?self.street:@"" forKey:@"street"];
            [info setObject:self.detailAddress?self.detailAddress:@"" forKey:@"detailAddress"];
            [info setObject:[NSString stringWithFormat:@"%f", self.coordinate2D.longitude] forKey:@"longitude"];
            [info setObject:[NSString stringWithFormat:@"%f", self.coordinate2D.latitude] forKey:@"latitude"];
        }
        ((void(^)(NSDictionary *, NSError *))obj)(info, nil);
    }];
    [self.taskTable removeAllObjects];
    
}

- (void)notifyLocateResult:(NSError *)error {
    NSDictionary *tempDic = [self.taskTable copy];
    [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ((void(^)(NSDictionary *, NSError *))obj)(nil, error);
    }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
@end

//
//  BusStop.h
//  GetOnThatBus
//
//  Created by Amaeya Kalke on 10/14/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BusStop : NSObject
@property NSString *name;
@property NSString *addressURL;
@property MKPointAnnotation *busStopPoint;
@property NSString *routes;
@property NSString *intermodal;
@property CLLocationCoordinate2D coord;

@end

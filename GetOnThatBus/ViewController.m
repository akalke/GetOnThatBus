//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Amaeya Kalke on 10/14/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "BusStop.h"
#import "StopDetailViewController.h"

@interface ViewController () <MKMapViewDelegate>
@property NSArray *stopsArray;
@property BusStop *busStop;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *busStopLocationsArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self; //anytime you have a delegate SET THE DELEGATE VIEW
    self.busStop = [[BusStop alloc] init];
    [self loadJSONData];
}

-(void)addBusStopsFromData{
    self.busStopLocationsArray = [[NSMutableArray alloc] init];

    for(NSDictionary *stops in self.stopsArray){

        //Store lat/long coordinates from stops dictionary of each stop
        CLLocationCoordinate2D coord;

        coord.latitude = [[stops objectForKey:@"latitude" ] doubleValue];
        coord.longitude = [[stops objectForKey:@"longitude"] doubleValue];

        if (40 < coord.latitude && coord.latitude < 43 && -89 < coord.longitude && coord.longitude < -86) {

            //Create discrete bus stop
            self.busStop.busStopPoint = [[MKPointAnnotation alloc] init];
            self.busStop.busStopPoint.coordinate = coord;
            self.busStop.busStopPoint.title = [stops objectForKey: @"cta_stop_name"];
            self.busStop.busStopPoint.subtitle = [stops objectForKey: @"routes"];

            //Add bus stop locations (annotations)
            [self.mapView addAnnotation:self.busStop.busStopPoint];
        }
        //Store bus stop locations into an array
        [self.busStopLocationsArray addObject:self.busStop.busStopPoint];
    }
}


-(void)loadJSONData{
    //Pull in stop data from JSON response at known URL - including stop name, lat, long, position, address URL, stop id, direction, routes, and ward
    NSURL *url = [NSURL URLWithString: @"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        //Confirm JSON response
        //NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"Stop Data: %@", jsonString);

        NSError *jsonError = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error: &jsonError];
        self.stopsArray = [jsonDictionary objectForKey:@"row"];
        [self addBusStopsFromData];

        //NSLog(@"Connection error: %@", connectionError);
        //NSLog(@"JSON Error: %@", jsonError);
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //Adjust pin attributes e.g. callouts, custom pin images, disclosure buttons, etc.
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];

    //Update pin images if metra or pace connections avaialable at station
    //Loop through to match bus stop spot and then inter_modal type
    for(NSDictionary *stops in self.stopsArray){
        if([[stops objectForKey:@"cta_stop_name"] isEqualToString:annotation.title]){
            if([[stops objectForKey:@"inter_modal"] isEqualToString:@"Metra"]){
                pin.pinColor = MKPinAnnotationColorGreen;
            }
            else if([[stops objectForKey:@"inter_modal"] isEqualToString:@"Pace"]){
                pin.pinColor = MKPinAnnotationColorPurple;
            }
        }
    }

    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //pin.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    //Store max and min coordinates - max.lat, min.lat, max.long, min.long. Initialize to first values in location array
    CLLocationCoordinate2D max = [[self.busStopLocationsArray objectAtIndex:0] coordinate];
    CLLocationCoordinate2D min = [[self.busStopLocationsArray objectAtIndex:0] coordinate];

    for(MKPointAnnotation *point in self.busStopLocationsArray){ //search for objects of type MKPoint in location array (array stores points location)

        //Do comparisons within array to find max/min bounds
        if(point.coordinate.latitude >= max.latitude){ //Max latitude
            max.latitude = point.coordinate.latitude ;
        }
        if(point.coordinate.latitude  < min.latitude){ //Min latitude
            min.latitude = point.coordinate.latitude ;
        }
        if(point.coordinate.longitude >= max.longitude){ //Max long
            max.longitude = point.coordinate.longitude ;
        }
        if(point.coordinate.longitude < min.longitude){ //min long
            min.longitude = point.coordinate.longitude ;
        }

    }
    //Define span --> vert and horizontal distances in region
    MKCoordinateSpan span;
    //NSLog(@"Max Lat: %f, Min Lat: %f, Max Long: %f, Min Long:%f", max.latitude, min.latitude, max.longitude, min.longitude);
    span.latitudeDelta = max.latitude - min.latitude;
    span.longitudeDelta = max.longitude - min.longitude;
    //NSLog(@"Lat Delta: %f, Long Delta: %f", span.latitudeDelta, span.longitudeDelta);

    //Define region center --> mid lat and mid long
    MKCoordinateRegion region;
    region.center.latitude = ((max.latitude + min.latitude)/2);
    region.center.longitude = ((max.longitude + min.longitude)/2);
    //NSLog(@"Region Center Lat: %f, Region Center Long: %f", region.center.latitude, region.center.longitude);


    for(NSDictionary *stops in self.stopsArray) {
        if([self.busStop.busStopPoint.title isEqualToString:[stops objectForKey:@"cta_stop_name"]]){
            self.busStop.name = [stops objectForKey: @"cta_stop_name"];
            //self.busStop.coord.latitude = [stops objectForKey:@"latitude"];
        }
    }

    [self.mapView setRegion:region animated:YES];
    [self performSegueWithIdentifier:@"mapDetailSegue" sender:self];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"mapDetailSegue"]){
        UINavigationController * navigationController = segue.destinationViewController;
        StopDetailViewController *stopDetailVC = (StopDetailViewController *) navigationController;
        stopDetailVC.stopName = @"Moo";
    }
}


@end

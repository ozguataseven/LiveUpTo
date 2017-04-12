//
//  ViewController.h
//  Liveupto
//
//  Created by ihsan on 5.12.2016.
//  Copyright © 2016 ihsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface MainViewController : UIViewController <CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *currentLocation;
@property(nonatomic) double currentLat;
@property(nonatomic) double currentLon;

@property(nonatomic, strong) GMSCameraPosition *camera;
@property(nonatomic, strong) GMSMapView *mapView;
@property(nonatomic, strong) GMSPolyline *polyline;
@property(nonatomic, strong) GMSMarker *startMarker;
@property(nonatomic, strong) GMSMarker *endMarker;
@property(nonatomic, strong) GMSMarker *selectedMarker;
@property(nonatomic, strong) GMSMarker *markerSelectedByMe;

@end

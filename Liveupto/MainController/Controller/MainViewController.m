//
//  ViewController.m
//  Liveupto
//
//  Created by ihsan on 5.12.2016.
//  Copyright © 2016 ihsan. All rights reserved.
//

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "MainViewController+Server.h"

@interface MainViewController () <GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewMap;
@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPhoneViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDestinationViewBottom;

@property (weak, nonatomic) IBOutlet UILabel *lblTaxiStopName;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UIButton *btnTaxiStop;
@property (weak, nonatomic) IBOutlet UILabel *lblStartAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblEndAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;

@property (nonatomic) BOOL isAlreadyHavePolyline;
@property (nonatomic) BOOL isAddedByMe;

@end

@implementation MainViewController{
    
}

#pragma mark - View LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self loadGMapKit];
    
    self.isAlreadyHavePolyline = NO;
}

#pragma mark - Setup View -

-(void)loadGMapKit
{
    self.camera = [GMSCameraPosition cameraWithLatitude:39.765322
                                              longitude:30.4747748
                                                   zoom:15];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewMap.frame.size.width, self.viewMap.frame.size.height) camera:self.camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.delegate = self;
    
    [self.viewMap addSubview:self.mapView];
}

-(void)showNearestStops:(NSDictionary *)taxiStopData{
    
    if (!self.isAlreadyHavePolyline)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.cnsPhoneViewBottom.constant = 0.0f;
            self.lblTaxiStopName.text = taxiStopData[@"name"];
            [self.btnTaxiStop setTitle:taxiStopData[@"phoneNumber"] forState:UIControlStateNormal];
            self.lblDistance.text = [NSString stringWithFormat:@"%@ km",taxiStopData[@"coordinate"]];
            
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)setDistaneView:(NSDictionary *)responseData{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.lblStartAddress.text = responseData[@"startAddress"];
        self.lblEndAddress.text = responseData[@"endAddress"];
        
        float distance = [responseData[@"distance"] floatValue];
        CGFloat distance_down = floorf(distance) / 1000;
        
        NSInteger duration = [responseData[@"duration"] intValue];
        
        self.lblDuration.text = [NSString stringWithFormat:@"%.02f km, %li dakika", distance_down, (long)duration/60];
        
        float price = (distance_down * 2.10) +3.45;
        self.lblPrice.text = [NSString stringWithFormat:@"%.02f ₺",price];
        
        NSString *mutablePath = [responseData[@"routes"] firstObject];
        
        GMSMutablePath *path = nil;
        path = [GMSMutablePath pathFromEncodedPath:mutablePath];
        
        self.polyline = [GMSPolyline polylineWithPath:path];
        self.polyline.strokeColor = [UIColor redColor];
        self.polyline.strokeWidth = 2.f;
        self.polyline.map = self.mapView;
        
        self.cnsDestinationViewBottom.constant = 0;
        
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Button Action -

- (IBAction)actionRefresh:(UIButton *)sender {
 
    self.startMarker.map = nil;
    self.endMarker.map = nil;
    self.polyline.map = nil;
    self.markerSelectedByMe.map = nil;
    self.isAddedByMe = NO;
    self.isAlreadyHavePolyline = NO;
    self.cnsDestinationViewBottom.constant = -126.0f;
}

- (IBAction)onLaunchClicked:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (IBAction)actionCallTaxiStop:(UIButton *)sender {
    
    if(!self.selectedMarker.snippet)
        return;
    
    if(self.selectedMarker){
        NSString *phoneNumber = [self.selectedMarker.snippet stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]];
        if([[UIApplication sharedApplication] canOpenURL:phoneURL]){
            [[UIApplication sharedApplication] openURL:phoneURL];
        }
    }
}

#pragma mark - GM MapView Delegate -

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    self.isAddedByMe = YES;
    
    self.cnsDestinationViewBottom.constant = -126.0f;
    
    self.markerSelectedByMe.map = nil;
    self.polyline.map = nil;
    self.startMarker.map = nil;
    self.endMarker.map = nil;
    
    self.markerSelectedByMe = [GMSMarker markerWithPosition:coordinate];
    
    self.markerSelectedByMe.title = @"Başlangıç noktası";
    self.markerSelectedByMe.appearAnimation = kGMSMarkerAnimationPop;
    self.markerSelectedByMe.map = self.mapView;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    if(self.selectedMarker){
        self.selectedMarker = nil;
        [UIView animateWithDuration:0.3 animations:^{
            self.cnsPhoneViewBottom.constant = -116.0f;
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    if(self.selectedMarker){
        NSString *phoneNumber = [self.selectedMarker.snippet stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]];
        if([[UIApplication sharedApplication] canOpenURL:phoneURL]){
            [[UIApplication sharedApplication] openURL:phoneURL];
        }
    }    
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    [self deleteAllProperties];
    
    if(marker)
    {
        if (!self.isAlreadyHavePolyline && ![marker.title isEqualToString:@"Başlangıç noktası"])
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                self.cnsPhoneViewBottom.constant = 0.0f;
                self.lblTaxiStopName.text = marker.title;
                [self.btnTaxiStop setTitle:marker.snippet forState:UIControlStateNormal];
                self.lblDistance.text = [NSString stringWithFormat:@"%@ km",[self calculateDistanceWithDestinationLat:marker.position.latitude destLon:marker.position.longitude]];
                
                self.selectedMarker = marker;
                [self.view layoutIfNeeded];
            }];
        }
    }
    
    return NO;
}

#pragma mark - GM Autocmplete DataSource -

- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self getPlaceDetailWithCurrentLat:self.markerSelectedByMe ? self.markerSelectedByMe.position.latitude : self.currentLat
                                currentLon:self.markerSelectedByMe ? self.markerSelectedByMe.position.longitude : self.currentLon
                            destinationLat:place.coordinate.latitude
                            destinationLon:place.coordinate.longitude
                                   success:^(NSDictionary *responseData) {
                                       
                                       self.isAlreadyHavePolyline = YES;
                                       
                                       [self deleteAllProperties];
                                       
                                       if (self.markerSelectedByMe) {
                                           self.markerSelectedByMe.title = responseData[@"startAddress"];
                                       }
                                       else
                                       {
                                           self.startMarker = [[GMSMarker alloc] init];
                                           self.startMarker.position = CLLocationCoordinate2DMake(self.currentLat, self.currentLon);
                                           self.startMarker.title = responseData[@"startAddress"];
                                           self.startMarker.map = self.mapView;
                                       }
                                       
                                       self.endMarker = [[GMSMarker alloc] init];
                                       self.endMarker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                                       self.endMarker.title = responseData[@"endAddress"];
                                       self.endMarker.appearAnimation = kGMSMarkerAnimationPop;
                                       

                                       self.endMarker.map = self.mapView;
                                       
                                       [self setDistaneView:responseData];
                                       
                                   } failure:^{
                                       
                                   }];
    }];
    
    self.viewMap= self.mapView;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Location Manager -

- (void) startLocationManager
{
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.currentLocation = (CLLocation *)[locations lastObject];
    
    self.currentLat = self.currentLocation.coordinate.latitude;
    self.currentLon = self.currentLocation.coordinate.longitude;
    
    self.camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                              longitude:self.currentLocation.coordinate.longitude
                                                   zoom:15];
    
    [self.mapView animateToCameraPosition:self.camera];
    
    [self.locationManager stopUpdatingLocation];
    
    [self loadTaxiStops:[self getStops]];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            [self startLocationManager];
            
            break;
        case kCLAuthorizationStatusDenied:
            
            [self locationServicesGetError:[NSError errorWithDomain:@"com.location.error" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Lütfen konum servislerine izin veriniz"}]];
            
            break;
        case kCLAuthorizationStatusNotDetermined:
            
            [self.locationManager requestWhenInUseAuthorization];
            
            break;
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationServicesGetError:( NSError * )error {
    
    if ( [error.domain isEqualToString:@"com.location.error"] ) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:@"Kapat" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:close];
        
        UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Ayarlar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [alert addAction:settings];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Helpers -

-(NSArray *) getStops {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"taxiStops" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return jsonData;
}

-(void)loadTaxiStops:(NSArray *)taxiStops{
    
    NSMutableArray *sortedData = [NSMutableArray new];
    
    [taxiStops enumerateObjectsUsingBlock:^(NSDictionary *taxiStop, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *components = [taxiStop[@"coordinate"] componentsSeparatedByString:@", "];
        
        double latitude = [components[0] doubleValue];
        double longitude = [components[1] doubleValue];
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.title = taxiStop[@"name"];
        marker.snippet = taxiStop[@"phoneNumber"];
        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = self.mapView;
        
        NSString *str = [self calculateDistanceWithDestinationLat:latitude destLon:longitude];
        [sortedData addObject:@{@"coordinate" : str,
                                @"name" : taxiStop[@"name"],
                                @"phoneNumber" : taxiStop[@"phoneNumber"]}];
    }];
    
    NSSortDescriptor * sd = [NSSortDescriptor sortDescriptorWithKey:@"coordinate" ascending:YES];
    sortedData = [sortedData sortedArrayUsingDescriptors:@[sd]].mutableCopy;
    
    [self showNearestStops:[sortedData firstObject]];
}

-(void) deleteAllProperties
{
    if (self.isAlreadyHavePolyline) {
        self.polyline.map = nil;
        self.startMarker.map = nil;
        self.endMarker.map = nil;
        self.isAlreadyHavePolyline = NO;
    }
}

-(NSString *)calculateDistanceWithDestinationLat:(CLLocationDegrees)destLat destLon:(CLLocationDegrees)destLon {
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:self.currentLat longitude:self.currentLon];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destLat longitude:destLon];
    CLLocationDistance distance = [currentLocation distanceFromLocation:destinationLocation];
    CLLocationDistance kilometers = distance / 1000;
    
    NSString *distanceString = [[NSString alloc] initWithFormat: @"%f", kilometers];
    float totalDistance = [distanceString floatValue];
    CGFloat rounded_down = floorf(totalDistance * 100) / 100;
    distanceString = [NSString stringWithFormat:@"%.02f", rounded_down];
    
    return distanceString;
}

@end

//
//  MainViewController+Server.m
//  Liveupto
//
//  Created by ihsan on 5.12.2016.
//  Copyright © 2016 ihsan. All rights reserved.
//

#import "MainViewController+Server.h"
#import "AFManager.h"

@implementation MainViewController (Server)

-(void)getPlaceDetailWithCurrentLat:(double)currentlat currentLon:(double)currentLon destinationLat:(double)destinationLat destinationLon:(double)destinationLon success:(void (^)(NSDictionary *))success failure:(void (^)())failure {
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           currentlat,
                           currentLon,
                           destinationLat,
                           destinationLon,
                           @"AIzaSyC_mvKbKEzMTBwggGA_ZUV16ZFe3HBImLc"];
    
    [[AFManager sharedManager] GET:urlString parameters:nil success:^(NSHTTPURLResponse *urlResponse, id response) {
        
        if(response){
            
            if([response[@"status"] isEqualToString:@"OK"]){
                
                NSMutableArray *routesData = [NSMutableArray new];
                routesData = response[@"routes"];
                
                NSMutableDictionary *responseData = [NSMutableDictionary new];
                
                [routesData enumerateObjectsUsingBlock:^(NSDictionary *route, NSUInteger idx, BOOL * _Nonnull stop)
                {
                    NSMutableArray *polylineData = [NSMutableArray new];
                    [polylineData addObject:[route[@"overview_polyline"] objectForKey:@"points"]];
                    
                    [route[@"legs"] enumerateObjectsUsingBlock:^(NSDictionary *leg, NSUInteger idx2, BOOL * _Nonnull stop2) {
                        
                        [responseData setValue:leg[@"start_address"] forKey:@"startAddress"];
                        [responseData setValue:leg[@"end_address"] forKey:@"endAddress"];
                        
                        [responseData setValue:[leg[@"duration"] objectForKey:@"value"] forKey:@"duration"];
                        [responseData setValue:[leg[@"distance"] objectForKey:@"value"] forKey:@"distance"];
                        
                    }];
                    
                    [responseData setValue:polylineData forKey:@"routes"];
                    
                }];

                success(responseData);
            }
            else{
                failure();
            }
        }
        
    } failure:^(NSError *error) {
        failure();
    }];
}

@end

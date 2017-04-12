//
//  MainViewController+Server.h
//  Liveupto
//
//  Created by ihsan on 18/01/2017.
//  Copyright © 2017 ihsan. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController (Server)

- ( void )getPlaceDetailWithCurrentLat:(double)curentlat
                            currentLon:(double)currentLon
                        destinationLat:(double)destinationLat
                        destinationLon:(double)destinationLon
                               success:( void (^) (NSDictionary *) )success
                              failure:( void (^) () )failure;


@end

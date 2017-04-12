//
//  AFManager.h
//  Liveupto
//
//  Created by ihsan on 05/01/2017.
//  Copyright © 2017 ihsan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFURLSessionManager.h"

@interface AFManager : NSObject

+ ( AFManager * )sharedManager;

-(void) GET:(NSString *)path
 parameters:(NSDictionary *)parameters
    success:( void (^) (NSHTTPURLResponse *, id) )success
    failure:( void (^) (NSError *error) )failure;

-(void) POST:(NSString *)path
 parameters:(NSDictionary *)parameters
    success:( void (^) (NSHTTPURLResponse *, id) )success
    failure:( void (^) (NSError *error) )failure;

-(void)stopEverything;

@end

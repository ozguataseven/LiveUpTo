//
//  AFManager.m
//  Liveupto
//
//  Created by ihsan on 5.12.2016.
//  Copyright © 2017 ihsan. All rights reserved.
//

#import "AFManager.h"
#import "AFNetworkReachabilityManager.h"

#define TIMEOUT_INTERVAL 20

@interface AFManager ()

@property(nonatomic ,strong) AFHTTPSessionManager *sessionManager;

@end

@implementation AFManager

+(AFManager *)sharedManager {
    static AFManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

-(void)GET:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSHTTPURLResponse *, id))success failure:(void (^)(NSError *))failure{
    
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = TIMEOUT_INTERVAL;
    
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    [serializer setRemovesKeysWithNullValues:YES];
    [self.sessionManager setResponseSerializer:serializer];
    
    [self.sessionManager GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success((NSHTTPURLResponse *)task.response, responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}

-(void)POST:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSHTTPURLResponse *, id))success failure:(void (^)(NSError *))failure {
    
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = TIMEOUT_INTERVAL;
    
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    [serializer setRemovesKeysWithNullValues:YES];
    [self.sessionManager setResponseSerializer:serializer];
    
    [self.sessionManager POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success((NSHTTPURLResponse *)task.response, responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}

-(void)stopEverything {
    
    [self.sessionManager.operationQueue cancelAllOperations];
}

-(BOOL)isReachable {
    
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

@end

//
//  Services.m
//  EarthquakeMonitor_ObjC
//
//  Created by Heberto on 02/03/15.
//  Copyright (c) 2015 MovieClip. All rights reserved.
//

#import "Services.h"


@implementation Services
@synthesize delegate = _delegate;

-(void) LoadFeed{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_delegate) {
            [_delegate onFeedLoaded:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_delegate) {
            [_delegate onFeedLoadedError:error.description.description];
        }
    }];
    [operation start];
}

@end

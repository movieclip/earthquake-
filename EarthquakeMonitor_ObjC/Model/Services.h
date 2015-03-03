//
//  Services.h
//  EarthquakeMonitor_ObjC
//
//  Created by Heberto on 02/03/15.
//  Copyright (c) 2015 MovieClip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@class Services;
@protocol ServicesDelegate <NSObject>
@optional
-(void) onFeedLoaded:(NSDictionary *) result;
-(void) onFeedLoadedError:(NSString *) message;
@end

@interface Services : NSObject{
    __weak id <ServicesDelegate> _delegate;
}

@property (nonatomic,weak) id <ServicesDelegate> delegate;

-(void) LoadFeed;

@end

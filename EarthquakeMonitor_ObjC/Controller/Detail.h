//
//  Detail.h
//  EarthquakeMonitor_ObjC
//
//  Created by Heberto on 02/03/15.
//  Copyright (c) 2015 MovieClip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Detail : UIViewController <MKMapViewDelegate>{
    __weak IBOutlet UILabel *time_lbl;
    __weak IBOutlet UILabel *magnitude_lbl;
    __weak IBOutlet UILabel *place_lbl;
    __weak IBOutlet MKMapView *map;
    
    double lat;
    double lon;
    BOOL   first_time;
    MKPinAnnotationView *pin_view;
    MKCircleView *depth_area;
}

@property (nonatomic, strong) NSDictionary *Data;

@end

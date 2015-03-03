//
//  Detail.m
//  EarthquakeMonitor_ObjC
//
//  Created by Heberto on 02/03/15.
//  Copyright (c) 2015 MovieClip. All rights reserved.
//

#import "Detail.h"

@interface Detail ()

@end

@implementation Detail
@synthesize Data = _data;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [place_lbl setText:[_data objectForKey:@"place"]];
    
    [magnitude_lbl setText:[NSString stringWithFormat:@"%0.2f",[[_data objectForKey:@"mag"] floatValue]]];
    [magnitude_lbl setTextColor:[_data objectForKey:@"color"]];
    
    double timestamp = ([[_data objectForKey:@"time"] doubleValue])/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE, MMMM dd yyyy -- HH:mm:ss"];
    [time_lbl setText:[format stringFromDate:date]];
    
    lat = [[_data objectForKey:@"lat"] doubleValue];
    lon = [[_data objectForKey:@"lon"] doubleValue];
    
    first_time = YES;
}

-(void)dealloc{
    depth_area = nil;
    pin_view = nil;
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    if(first_time){
        first_time = NO;

        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
        MKCoordinateSpan span = MKCoordinateSpanMake(0.5, 0.5);
        MKCoordinateRegion region = {coord,span};
    
        [map setRegion:[map regionThatFits:region] animated:YES];
        
        float meters = ([[_data objectForKey:@"depth"] floatValue] * 1000);
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:meters];
        [map addOverlay:circle];
        
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = coord;
        pin.title = @"Epicenter";
        [map addAnnotation:pin];
        pin = nil;
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    pin_view = [[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation reuseIdentifier:@"pin"];
    pin_view.pinColor = [self getPinColorForMag:[[_data objectForKey:@"mag"] floatValue]];
    return pin_view;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKCircle class]]){
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        renderer.strokeColor = [_data objectForKey:@"color"];
        renderer.lineWidth = 1;
        renderer.fillColor = [[_data objectForKey:@"color"] colorWithAlphaComponent:0.3f];
        return renderer;
    }
    return nil;
}

-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    NSLog(@"Error on loading map");
}

-(MKPinAnnotationColor) getPinColorForMag:(float) mag{
    if (mag >= 0.0 && mag <= 0.9) {
        return MKPinAnnotationColorGreen;
    }else if(mag >= 9.0 && mag <= 9.9 ){
        return MKPinAnnotationColorRed;
    }else{
        return MKPinAnnotationColorPurple;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  Summary.h
//  EarthquakeMonitor_ObjC
//
//  Created by Heberto on 02/03/15.
//  Copyright (c) 2015 MovieClip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Services.h"

@interface Summary : UITableViewController <ServicesDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    NSArray                 *_features;
    UIActivityIndicatorView *loading_aiv;
    UIBarButtonItem         *loading_bbi;
    UIBarButtonItem         *reload_bbi;
    IBOutlet UITableView    *summary_tv;
    
}

@end

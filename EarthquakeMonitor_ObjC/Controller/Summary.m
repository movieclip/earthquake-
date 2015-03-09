//
//  Summary.m
//  EarthquakeMonitor_ObjC
//
//  Created by Heberto on 02/03/15.
//  Copyright (c) 2015 MovieClip. All rights reserved.
//

#import "Summary.h"
#import "Services.h"
#import "Detail.h"

@interface Summary ()

@end

@implementation Summary

- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitUI];
    [self Reload];
}

-(void) InitUI{
    [self setTitle:@""];
    
    loading_aiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    loading_bbi = [[UIBarButtonItem alloc] initWithCustomView:loading_aiv];
    
    UIButton *reload_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    reload_btn.frame = CGRectMake(0, 0, 20, 20);
    [reload_btn setBackgroundImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [reload_btn addTarget:self action:@selector(Reload) forControlEvents:UIControlEventTouchUpInside];
    reload_bbi = [[UIBarButtonItem alloc] initWithCustomView:reload_btn];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void) Reload{
    [self navigationItem].rightBarButtonItem = loading_bbi;
    [loading_aiv startAnimating];
    
    Services *service = [[Services alloc] init];
    service.delegate = self;
    [service LoadFeed];
    service = nil;
}

-(void)onFeedLoaded:(NSDictionary *)result{
    NSLog(@"Show service result");
    [self navigationItem].rightBarButtonItem = reload_bbi;
    [self DisplyaData:result];
    [self SaveCache:result];
}

-(void)onFeedLoadedError:(NSString *)message{
    [self navigationItem].rightBarButtonItem = reload_bbi;
    NSDictionary *cache = [self OpenCache];
    if (cache) {
        NSLog(@"Show cache");
        [self DisplyaData:cache];
    }else{
        NSLog(@"No cache saved");
    }
}

-(void) DisplyaData:(NSDictionary *) result{
    NSDictionary *metadata = [result objectForKey:@"metadata"];
    [self setTitle:[metadata objectForKey:@"title"]];
    _features = [result objectForKey:@"features"];
    [summary_tv reloadData];
}

-(void) SaveCache:(NSDictionary *)data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs_directory = [paths objectAtIndex:0];
    NSString *file_path = [docs_directory stringByAppendingPathComponent:@"summary.plist"];
    
    NSMutableDictionary *data_cache = [[NSMutableDictionary alloc] init];
    [data_cache setObject:(NSDictionary *)[data objectForKey:@"metadata"] forKey:@"metadata"];

    NSMutableArray *features = [[NSMutableArray alloc] init];
    for(NSDictionary *dic in [data objectForKey:@"features"]){
        NSMutableDictionary *feature = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *tmp_properties = [[NSMutableDictionary alloc] init];
        NSDictionary    *properties     = [dic objectForKey:@"properties"];
        NSDictionary    *geometry       = [dic objectForKey:@"geometry"];
        
        [tmp_properties setObject:[properties objectForKey:@"place"] forKey:@"place"];
        [tmp_properties setObject:[properties objectForKey:@"mag"] forKey:@"mag"];
        [tmp_properties setObject:[properties objectForKey:@"time"] forKey:@"time"];
        
        [feature setObject:tmp_properties forKey:@"properties"];
        [feature setObject:geometry forKey:@"geometry"];
        [features addObject:feature];
        
        feature = nil;
        tmp_properties = nil;
    }
    
    [data_cache setObject:features forKey:@"features"];
    [data_cache writeToFile:file_path atomically:YES];
    
    data_cache = nil;
}

-(NSDictionary *) OpenCache{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs_directory = [paths objectAtIndex:0];
    NSString *file_path = [docs_directory stringByAppendingPathComponent:@"summary.plist"];
    return [NSDictionary dictionaryWithContentsOfFile:file_path];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_features count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *info = [_features objectAtIndex:indexPath.row];
    NSDictionary *properties = [info objectForKey:@"properties"];
    float mag = [[properties objectForKey:@"mag"] floatValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%0.2f", mag];
    cell.detailTextLabel.text = [properties objectForKey:@"place"];
    [cell.textLabel setTextColor:[self getColorForMag:mag]];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *data       = [[NSMutableDictionary alloc] init];
    NSDictionary    *info           = [_features objectAtIndex:indexPath.row];
    NSDictionary    *properties     = [info objectForKey:@"properties"];
    NSDictionary    *geometry       = [info objectForKey:@"geometry"];
    NSArray         *coordinates    = [geometry objectForKey:@"coordinates"];
    float           mag             = [[properties objectForKey:@"mag"] floatValue];
    
    [data setObject:[properties objectForKey:@"place"] forKey:@"place"];
    [data setObject:[properties objectForKey:@"mag"] forKey:@"mag"];
    [data setObject:[properties objectForKey:@"time"] forKey:@"time"];
    [data setObject:[coordinates objectAtIndex:1] forKey:@"lat"];
    [data setObject:[coordinates objectAtIndex:0] forKey:@"lon"];
    [data setObject:[coordinates objectAtIndex:2] forKey:@"depth"];
    [data setObject:[self getColorForMag:mag] forKey:@"color"];
    
    Detail *view = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    view.Data = data;
    [self.navigationController pushViewController:view animated:YES];
    view = nil;
    data = nil;
}

-(UIColor *) getColorForMag:(float) mag{
    if (mag >= 0.0 && mag <= 0.9) {
        return [UIColor colorWithRed:(8/255.0) green:(138/255.0) blue:(41/255.0) alpha:1.0];
    }else if(mag >= 9.0 && mag <= 9.9 ){
        return [UIColor colorWithRed:(180/255.0) green:(4/255.0) blue:(4/255.0) alpha:1.0];
    }else{
        return [UIColor colorWithRed:(56/255.0) green:(11/255.0) blue:(97/255.0) alpha:1.0];
    }
}

@end

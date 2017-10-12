//
//  ViewController.m
//  iOS-path-smooth
//
//  Created by shaobin on 2017/10/12.
//  Copyright © 2017年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "MASmoothPathTool.h"

@interface ViewController () <MAMapViewDelegate>

@property (nonatomic, strong) NSArray<MALonLatPoint*> *origTracePoints;
@property (nonatomic, strong) NSArray<MALonLatPoint*> *smoothedTracePoints;

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPolyline *origTrace;
@property (nonatomic, strong) MAPolyline *smoothedTrace;

@property (nonatomic, strong) UISwitch *origTraceSwitch;
@property (nonatomic, strong) UISwitch *smoothedTraceSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initPolylines];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.origTraceSwitch = [[UISwitch alloc] init];
    self.smoothedTraceSwitch = [[UISwitch alloc] init];
    self.origTraceSwitch.center = CGPointMake(15 + self.origTraceSwitch.bounds.size.width / 2, self.view.bounds.size.height - 90);
    self.smoothedTraceSwitch.center = CGPointMake(self.origTraceSwitch.center.x, self.origTraceSwitch.center.y + self.origTraceSwitch.bounds.size.height + 5);
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.origTraceSwitch.frame) + 5, self.origTraceSwitch.frame.origin.y, 100, CGRectGetHeight(self.origTraceSwitch.bounds))];
    label1.text = @"原始轨迹";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.smoothedTraceSwitch.frame) + 5, self.smoothedTraceSwitch.frame.origin.y, 100, CGRectGetHeight(self.smoothedTraceSwitch.bounds))];
    label2.text = @"平滑轨迹";
    
    [self.view addSubview:label1];
    [self.view addSubview:self.origTraceSwitch];
    [self.view addSubview:label2];
    [self.view addSubview:self.smoothedTraceSwitch];
    
    //
    [self.origTraceSwitch addTarget:self action:@selector(onOrig:) forControlEvents:UIControlEventValueChanged];
    [self.smoothedTraceSwitch addTarget:self action:@selector(onSmoothed:) forControlEvents:UIControlEventValueChanged];
    
    [self.origTraceSwitch setOn:YES];
    [self.mapView removeOverlay:self.origTrace];
    [self.mapView addOverlay:self.origTrace];
    
    [self.mapView showOverlays:@[self.origTrace] animated:NO];
}

- (void)initPolylines {
    [self loadTracePoints];
    
    if(self.origTracePoints.count == 0) {
        return;
    }
    
    [self initOriginalTrace];
    
    [self initSmoothedTrace];
}

- (void)initOriginalTrace {
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * self.origTracePoints.count);
    if(!pCoords) {
        return;
    }
    
    for(int i = 0; i < self.origTracePoints.count; ++i) {
        MALonLatPoint *p = [self.origTracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.lat;
        pCur->longitude = p.lon;
    }
    
    self.origTrace = [MAPolyline polylineWithCoordinates:pCoords count:self.origTracePoints.count];
    if(pCoords) {
        free(pCoords);
    }
}

- (void)initSmoothedTrace {
    MASmoothPathTool *tool = [[MASmoothPathTool alloc] init];
    tool.intensity = 3;
    tool.threshHold = 0.3;
    tool.noiseThreshhold = 10;
    self.smoothedTracePoints = [tool pathOptimize:self.origTracePoints];
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * self.smoothedTracePoints.count);
    if(!pCoords) {
        return;
    }

    for(int i = 0; i < self.smoothedTracePoints.count; ++i) {
        MALonLatPoint *p = [self.smoothedTracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.lat;
        pCur->longitude = p.lon;
    }

    self.smoothedTrace = [MAPolyline polylineWithCoordinates:pCoords count:self.smoothedTracePoints.count];
    if(pCoords) {
        free(pCoords);
    }
}

- (void)loadTracePoints {
    NSString *filePath = [NSString stringWithFormat:@"%@/AMapTrace2.txt", [[NSBundle mainBundle] bundlePath]];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *str = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    NSMutableArray *results = [NSMutableArray array];
    for(NSString *oneLine in arr) {
        NSArray *items = [oneLine componentsSeparatedByString:@","];
        
        if(items.count == 3) {
            NSString *lat = [items objectAtIndex:1];
            NSString *lon = [items objectAtIndex:2];
            MALonLatPoint *point = [[MALonLatPoint alloc] init];
            point.lat = [lat doubleValue];
            point.lon = [lon doubleValue];
            [results addObject:point];
        }
    }
    
    self.origTracePoints = results;
}

- (void)onOrig:(UISwitch *)sender
{
    if(sender.isOn) {
        if([self.mapView.overlays containsObject:self.smoothedTrace]) {
            [self.mapView insertOverlay:self.origTrace belowOverlay:self.smoothedTrace];
        } else {
            [self.mapView addOverlay:self.origTrace];
        }
    } else {
        [self.mapView removeOverlay:self.origTrace];
    }
}

- (void)onSmoothed:(UISwitch *)sender
{
    if(sender.isOn) {
        [self.mapView addOverlay:self.smoothedTrace];
    } else {
        [self.mapView removeOverlay:self.smoothedTrace];
    }
}

#pragma <MAMapViewDelegate>
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if (overlay == self.origTrace)
    {
        MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:self.origTrace];
        
        polylineRenderer.lineWidth = 4.f;
        polylineRenderer.strokeColor = [UIColor greenColor];
        
        return polylineRenderer;
        
    } else if (overlay == self.smoothedTrace) {
        MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:self.smoothedTrace];
        
        polylineRenderer.lineWidth = 4.f;
        polylineRenderer.strokeColor = [UIColor colorWithRed:1.0 green:(int)0xc1/255.0 blue:0x25/255.0 alpha:1.0];
        
        return polylineRenderer;
        
    }
    
    return nil;
}

@end

//
//  ViewController.swift
//  iOS-patch-smooth-swift
//
//  Created by hanxiaoming on 2017/10/18.
//  Copyright © 2017年 autonavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MAMapViewDelegate {

    var origTracePoints: Array<MALonLatPoint> = Array()
    var smoothedTracePoints: Array<MALonLatPoint> = Array()
    
    var mapView: MAMapView!
    var origTrace: MAPolyline?
    var smoothedTrace: MAPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initPolylines()
        
        self.mapView = MAMapView(frame: self.view.bounds)
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        
        let origSwitch = UISwitch()
        let smoothSwitch = UISwitch()
        origSwitch.center = CGPoint(x: 15 + origSwitch.bounds.width / 2.0, y: self.view.bounds.height - 90)
        
        smoothSwitch.center = CGPoint(x: origSwitch.center.x, y: origSwitch.center.y + origSwitch.bounds.height + 5)

        let label1 = UILabel()
        label1.text = "原始轨迹"
        label1.sizeToFit()
        label1.center = CGPoint(x: origSwitch.frame.maxX + label1.bounds.width / 2.0 + 5, y: origSwitch.center.y)
        
        let label2 = UILabel()
        label2.text = "平滑轨迹"
        label2.sizeToFit()
        label2.center = CGPoint(x: smoothSwitch.frame.maxX + label2.bounds.width / 2.0 + 5, y: smoothSwitch.center.y)
        
        self.view.addSubview(origSwitch)
        self.view.addSubview(smoothSwitch)
        self.view.addSubview(label1)
        self.view.addSubview(label2)

        //
        origSwitch.addTarget(self, action: #selector(self.onOrig(sender:)), for: UIControlEvents.valueChanged)
        smoothSwitch.addTarget(self, action: #selector(self.onSmoothed(sender:)), for: UIControlEvents.valueChanged)
        
        origSwitch.isOn = true
        
        self.mapView.add(self.origTrace)
        self.mapView.showOverlays([self.origTrace!], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTracePoints() {
        
        let filePath = Bundle.main.path(forResource: "AMapTrace2", ofType: "txt")
        let fileStr = try! String.init(contentsOf: URL.init(fileURLWithPath: filePath!))
        let arr = fileStr.components(separatedBy: "\n")
        self.origTracePoints.removeAll()
        
        for oneLine in arr {
            let items = oneLine .components(separatedBy: ",")
            if items.count == 3 {
                let point = MALonLatPoint()
                point.lat = Double(items[1]) ?? 0
                point.lon = Double(items[2]) ?? 0
                
                self.origTracePoints.append(point)
            }
        }
    }
  
    func initPolylines() {
        loadTracePoints()
        
        initOriginalTrace()
        initSmoothedTrace()
    }
    
    func initOriginalTrace() {
        var pCoords:[CLLocationCoordinate2D] = Array()
        for onePoint in self.origTracePoints {
            let cor = CLLocationCoordinate2D(latitude: onePoint.lat, longitude: onePoint.lon)
            pCoords.append(cor)
        }
        self.origTrace = MAPolyline.init(coordinates: &pCoords, count: UInt(pCoords.count))
    }
    
    func initSmoothedTrace() {
        
        let tool = MASmoothPathTool()
        tool.intensity = 3
        tool.threshHold = 0.3
        tool.noiseThreshhold = 10
        
        self.smoothedTracePoints = tool.pathOptimize(self.origTracePoints)
        
        var pCoords:[CLLocationCoordinate2D] = Array()
        for onePoint in self.smoothedTracePoints {
            let cor = CLLocationCoordinate2D(latitude: onePoint.lat, longitude: onePoint.lon)
            pCoords.append(cor)
        }
        self.smoothedTrace = MAPolyline.init(coordinates: &pCoords, count: UInt(pCoords.count))
    }
    
    @objc func onOrig(sender: UISwitch) {
        if sender.isOn {
            
            let hasSmoothedTrace = self.mapView.overlays.contains(where: { (overlay) -> Bool in
                if overlay as! MAOverlay === self.smoothedTrace! as MAOverlay {
                    return true
                }
                else {
                    return false
                }
            })
            
            if hasSmoothedTrace {
                self.mapView.insert(self.origTrace, below: self.smoothedTrace)
            }
            else {
                self.mapView.add(self.origTrace)
            }
        }
        else {
            self.mapView.remove(self.origTrace)
        }
    }
    
    @objc func onSmoothed(sender: UISwitch) {
        if sender.isOn {
            self.mapView.add(self.smoothedTrace)
        }
        else {
            self.mapView.remove(self.smoothedTrace)
        }
    }
    
    //MARK: map delegate
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay === self.origTrace {
            let renderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline!)
            renderer!.lineWidth = 4
            renderer!.strokeColor = UIColor.green
            
            return renderer
        }
        else if overlay === self.smoothedTrace {
            let renderer = MAPolylineRenderer.init(polyline: overlay as! MAPolyline!)
            renderer!.lineWidth = 4
            renderer!.strokeColor = UIColor.red
            
            return renderer
        }
        return nil
    }

//    - (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
//    {
//    if (overlay == self.origTrace)
//    {
//    MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:self.origTrace];
//
//    polylineRenderer.lineWidth = 4.f;
//    polylineRenderer.strokeColor = [UIColor greenColor];
//
//    return polylineRenderer;
//
//    } else if (overlay == self.smoothedTrace) {
//    MAPolylineRenderer * polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:self.smoothedTrace];
//
//    polylineRenderer.lineWidth = 4.f;
//    polylineRenderer.strokeColor = [UIColor colorWithRed:1.0 green:(int)0xc1/255.0 blue:0x25/255.0 alpha:1.0];
//
//    return polylineRenderer;
//
//    }
//
//    return nil;
//    }

}




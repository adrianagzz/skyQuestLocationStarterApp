//
//  ViewController.swift
//  locationTest
//
//  Created by Adriana González on 8/24/16.
//  Copyright © 2016 Adriana Gonzalez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MessageUI

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UpdateDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lblRangerCoords: UILabel!
    @IBOutlet weak var lblBalloonCoords: UILabel!
    
    @IBOutlet weak var sendLocationBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    // firstTimer flags
    var firstLoadUserLocation = true
    var firstLoadRanger = true
    var firstLoadBalloon = true

    // annotations
    let annotationRanger = CustomAnnotation()
    let annotationBalloon = CustomAnnotation()
    
    // timers
    var timerRanger : Timer!
    var timerBallon : Timer!
    var timerSendLocation : Timer!

    //timestamps
    var rangerTimestamp: Date!
    var balloonTimestamp: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotationRanger.title = "Ranger"
        annotationRanger.imageName = "worker2-icon"
        
        annotationBalloon.title = "Balloon"
        annotationBalloon.imageName = "balloon-icon"

        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        map.delegate = self
        
        if Singleton.sharedInstance.asRanger == true {
            timerSendLocation = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.sendLocation), userInfo: nil, repeats: true)
            
            sendLocationBtn.setTitle("SEND MY LOCATION", for: UIControlState())

        }else{
            getRangerPosition()
            timerRanger = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.getRangerPosition), userInfo: nil, repeats: true)
            
            sendLocationBtn.setTitle("SEND BALLOON LOCATION", for: UIControlState())

        }
        
        getBallonPosition()
        timerBallon = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.getBallonPosition), userInfo: nil, repeats: true)
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if Singleton.sharedInstance.asRanger == true  {
            currentLocation = locations.last! as CLLocation
            
            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            self.map.addAnnotation(self.annotationRanger)
            self.annotationRanger.coordinate = center
            
            lblRangerCoords.text = "\(center.latitude)\n\(center.longitude)"

        }

        
//        if firstLoadUserLocation {
//            currentLocation = locations.last! as CLLocation
//            
//            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            
//            self.map.setRegion(region, animated: true)
//            self.map.addAnnotation(self.annotationRanger)
//            self.annotationRanger.coordinate = center
//            
//            lblRangerCoords.text = "\(center.latitude), \(center.longitude)"
//            
//            firstLoadUserLocation = false
//        }
       
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        let cpa = annotation as! CustomAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    func zoomToFitMapAnnotations(_ aMapView: MKMapView) {
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in map.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = aMapView.regionThatFits(region)
        map.setRegion(region, animated: true)
    }
    
    func sendLocation() {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        print("lat: \(currentLocation.coordinate.latitude) long:\(currentLocation.coordinate.longitude) timestamp:\(date)")
        
        let headers = [
            "Phant-Private-Key":"\(RANGER_PRIVATE_KEY)"
        ]
        
        let parameters = [
            "latitude": "\(currentLocation.coordinate.latitude)",
            "longitude": "\(currentLocation.coordinate.longitude)",
            "timestamp": "\(date)"
        ]
        
        Alamofire.request("\(RANGER_INPUT_URL).json", method: .post, parameters: parameters, headers: headers).responseJSON{ response in
            print(response.description)
        }
    }

    @IBAction func sendLocationSMS(_ sender: AnyObject) {
        
        var stringToSend = ""
        
        if Singleton.sharedInstance.asRanger == true{
            stringToSend = "\(currentLocation.coordinate.latitude)/\(currentLocation.coordinate.longitude)"

        }else{
            stringToSend = "\(annotationBalloon.coordinate.latitude)/\(annotationBalloon.coordinate.longitude)"
        }
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = stringToSend;
        messageVC.recipients = ["8180246720"]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        
    }
    
    func getRangerPosition(){
        Alamofire.request("\(RANGER_OUTPUT_URL).json", method: .get).responseJSON{ response in

            if let value = response.result.value{
                if let data = JSON(value).array{
                    
                    let lastEntry = data[0]
                    let timestamp = lastEntry["timestamp"].stringValue
                    let timeArr = timestamp.characters.split{$0 == "."}.map(String.init)
                    let newTS = timeArr[0]

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")


                    let latitude = lastEntry["latitude"].doubleValue
                    let longitude = lastEntry["longitude"].doubleValue
                    let lastDate = dateFormatter.date(from: newTS)

                    let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                   
                    if self.firstLoadRanger{
                        self.map.addAnnotation(self.annotationRanger)
                        self.firstLoadRanger = false
                        self.rangerTimestamp = lastDate!
                        self.annotationRanger.coordinate = location
                        self.zoomToFitMapAnnotations(self.map)
                        self.lblRangerCoords.text = "\(location.latitude)\n\(location.longitude)"


                    }else{
                        
                        if self.rangerTimestamp.compare(lastDate!) == ComparisonResult.orderedAscending{
                            print("Ranger: sparkfun is the most recent")
                            self.rangerTimestamp = lastDate!
                            self.annotationRanger.coordinate = location
                            self.lblRangerCoords.text = "\(location.latitude)\n\(location.longitude)"


                        }else if self.rangerTimestamp.compare(lastDate!) == ComparisonResult.orderedDescending{
                            print("Ranger: sparkfun is behind")
                        }else{
                            print("Ranger: same")
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    func getBallonPosition(){
        Alamofire.request("\(BALLOON_OUTPUT_URL).json", method: .get).responseJSON{ response in
            if let value = response.result.value{
                if let data = JSON(value).array{
                    
                    let lastEntry = data[0]
                    let timestamp = lastEntry["timestamp"].stringValue
                    let timeArr = timestamp.characters.split{$0 == "."}.map(String.init)
                    let newTS = timeArr[0]
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    
                    let latitude = lastEntry["lat"].doubleValue
                    let longitude = lastEntry["lon"].doubleValue
                    let lastDate = dateFormatter.date(from: newTS)
                    
                    let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    if self.firstLoadBalloon{
                        self.map.addAnnotation(self.annotationBalloon)
                        self.firstLoadBalloon = false
                        self.balloonTimestamp = lastDate!
                        self.annotationBalloon.coordinate = location
                        self.zoomToFitMapAnnotations(self.map)
                        self.lblBalloonCoords.text = "\(location.latitude)\n\(location.longitude)"


                    }else{
                        
                        if self.balloonTimestamp.compare(lastDate!) == ComparisonResult.orderedAscending{
                            print("Ballon: sparkfun is the most recent")
                            self.balloonTimestamp = lastDate!
                            self.annotationBalloon.coordinate = location
                            self.lblBalloonCoords.text = "\(location.latitude)\n\(location.longitude)"

                            
                        }else if self.balloonTimestamp.compare(lastDate!) == ComparisonResult.orderedDescending{
                            print("Ballon: sparkfun is behind")
                        }else{
                            print("Ballon: same")
                        }
                        
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController2 = segue.destination as? SettingsVC {
            viewController2.delegate = self
        }
    }
    
    func updateRangerLocation(_ location: CLLocationCoordinate2D) {
        self.annotationRanger.coordinate = location
        let newTS = Date()
        print("date sent \(newTS)")
        self.rangerTimestamp = newTS
        lblRangerCoords.text = "\(location.latitude)\n\(location.longitude)"


    }
    
    func updateBalloonLocation(_ location: CLLocationCoordinate2D) {
        self.annotationBalloon.coordinate = location
        let newTS = Date()
        print("date sent \(newTS)")
        self.balloonTimestamp = newTS
        lblBalloonCoords.text = "\(location.latitude)\n\(location.longitude)"

    }
    
    @IBAction func fitLocationPressed(_ sender: AnyObject) {
        zoomToFitMapAnnotations(map)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult){
        
        switch (result) {
            
        case MessageComposeResult.cancelled:
            break
            
        case MessageComposeResult.failed:
            
            break
            
        case MessageComposeResult.sent:
            
            break
            
        }
        
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
    
}


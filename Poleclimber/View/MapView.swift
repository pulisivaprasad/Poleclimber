//
//  MapView.swift
//  Poleclimber
//
//  Created by Sivaprasad on 29/06/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapView: UIView, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var feedbackObj:Feedback?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var centerCoor = CLLocationCoordinate2D()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
            
    }
    
    func setMapViewFrame() {
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        let dbLat = Double(feedbackObj?.latitude ?? "")  // Convert String to double
        let dbLong = Double(feedbackObj?.longitude ?? "")
        centerCoor = CLLocationCoordinate2D(latitude: dbLat!, longitude: dbLong! )
        
       // if let coor = centerCoor {
            mapView.setCenter(centerCoor, animated: true)
        //}

         addAnnotation()
    }
    
    func openMapForPlace() {

        let dbLat = Double(feedbackObj?.latitude ?? "")  // Convert String to double
        let dbLong = Double(feedbackObj?.longitude ?? "")
        
        let latitude:CLLocationDegrees =  dbLat!
        let longitude:CLLocationDegrees =  dbLong!

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        //mapItem.name = "\(self.venueName)"
        mapItem.openInMaps(launchOptions: options)

    }
    
    func addAnnotation(){

            let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoor

        annotation.title = feedbackObj?.gpsLocation
        let viewRegion = MKCoordinateRegion(center: centerCoor, latitudinalMeters: 1000, longitudinalMeters: 1000)
               self.mapView.setRegion(viewRegion, animated: false)
            //annotation.subtitle = "Some Subtitle"
            self.mapView.addAnnotation(annotation)
    }
    
    

}



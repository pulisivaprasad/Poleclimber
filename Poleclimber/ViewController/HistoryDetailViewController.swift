//
//  HistoryDetailViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 02/06/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import MapKit

class HistoryDetailViewController: UIViewController {

    @IBOutlet weak var updateddate: UILabel!
    @IBOutlet weak var feedbackReason: UILabel!
    @IBOutlet weak var exchangeArea: UILabel!
    @IBOutlet weak var dpNumber: UILabel!
    @IBOutlet weak var cpNumber: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var latAndLong: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tipTypeImg: UIImageView!
    @IBOutlet weak var mlProcessImg: UIImageView!

    var feedbackObj:Feedback?
    
    @IBOutlet weak var mapSubView: MapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "History Details"
        
        if let imagename = feedbackObj?.image {
             let image = self.loadeImage(name: imagename)
            imageView.image = image
        }
        
        updateddate.text = feedbackObj?.date
        if feedbackObj?.reason != "NA"{
            feedbackReason.text = feedbackObj?.reason
        }
        exchangeArea.text = "Exchange Area: " + (feedbackObj?.exchangeArea ?? "")
        dpNumber.text = "DP Number: " + (feedbackObj?.dpnumber ?? "")
        cpNumber.text = "CP Number: " + (feedbackObj?.cpnumber ?? "")
        address.text = "Address: " + feedbackObj!.gpsLocation!
        latAndLong.text = "Latitude: \(feedbackObj?.latitude ?? ""), Longitude: \(feedbackObj?.longitude ?? "")"
        
        
        
        if feedbackObj?.userResult == "Ok" {
            tipTypeImg.image = UIImage(named: "like")
        }else if feedbackObj?.userResult == "Disagree" {
            tipTypeImg.image = UIImage(named: "disLike")
        }
        else{
            tipTypeImg.image = UIImage(named: "rejecetd")
        }
        
        if feedbackObj?.mlModelProcessingLocation == "iPhone" {
            mlProcessImg.image = UIImage(named: "iPhone")
        }
        else{
            mlProcessImg.image = UIImage(named: "clouds")
        }
        
        
        mapSubView.frame = CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height - 60)
        //mapSubView.mapView.delegate = self
        mapSubView.feedbackObj = feedbackObj
        self.view.addSubview(mapSubView)
        mapSubView.isHidden = true
       // mapSubView.openMapForPlace()
        mapSubView.setMapViewFrame()
    }
    
    private func loadeImage(name: String) -> UIImage? {
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                                        in: .userDomainMask,
                                                                        appropriateFor:nil,
                                                                        create:false)
                        else {
                            // May never happen
                            print ("No Document directory Error")
                            return nil
                        }

        // Construct your Path from device Documents Directory
        var imagesDirectory = documentsDirectory

        // Add your file name to path
        imagesDirectory.appendPathComponent(name)

        // Create your UIImage?
        let result = UIImage(contentsOfFile: imagesDirectory.path)
        
        return result
    }
    
    @IBAction func segmentConAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            
            UIView.transition(
            with: mapSubView,
            duration: 1,
            options: .transitionFlipFromLeft,
            animations: {
                self.mapSubView.isHidden = true
            })
        }
        else{
            UIView.transition(
            with: mapSubView,
            duration: 1,
            options: .transitionFlipFromLeft,
            animations: {
                self.mapSubView.isHidden = false
            })
        }

    }
}


//extension HistoryDetailViewController: MKMapViewDelegate{
//
//func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//    guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
//
//    let reuseId = "pin"
//    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//
//    if pinView == nil {
//        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//        pinView!.canShowCallout = true
//        pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
//        pinView!.pinTintColor = UIColor.black
//    }
//    else {
//        pinView!.annotation = annotation
//    }
//    return pinView
//}
//
//func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//    print("tapped on pin ")
//}
//
//func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//    if control == view.rightCalloutAccessoryView {
//        if let doSomething = view.annotation?.title! {
//           print("do something")
//        }
//    }
//  }
//}

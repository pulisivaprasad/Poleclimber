//
//  Feedback+CoreDataProperties.swift
//  Poleclimber
//
//  Created by Chandra Sekhar Ravi on 10/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//
//

import Foundation
import CoreData


extension Feedback {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feedback> {
        return NSFetchRequest<Feedback>(entityName: "Feedback")
    }

    @NSManaged public var reason: String?
    @NSManaged public var poleTesterID: String?
    @NSManaged public var image: String?
    @NSManaged public var poleID: String?
    @NSManaged public var date: String?
    @NSManaged public var originalImg: String?
    @NSManaged public var exchangeArea: String?
    @NSManaged public var dpnumber: String?
    @NSManaged public var cpnumber: String?
    @NSManaged public var gpsLocation: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var imgID: String?    
    
    @NSManaged public var detections: String?
    @NSManaged public var detectedClasses: String?
    @NSManaged public var id: String?
    @NSManaged public var detectionTime: String?
    @NSManaged public var imageName: String?
    @NSManaged public var requestMethod: String?
    @NSManaged public var timeStamp: String?
    @NSManaged public var mlResult: String?
    @NSManaged public var userResult: String?
    @NSManaged public var mlModelProcessingLocation: String?



}

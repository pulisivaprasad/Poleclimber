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

    @NSManaged public var tipStatus: String?
    @NSManaged public var reason: String?
    @NSManaged public var poleTesterID: String?
    @NSManaged public var image: String?
    @NSManaged public var poleID: String?
    @NSManaged public var date: String?
    @NSManaged public var userAcceptance: String?

}

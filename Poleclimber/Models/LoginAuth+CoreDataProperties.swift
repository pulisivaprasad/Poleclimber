//
//  LoginAuth+CoreDataProperties.swift
//  Poleclimber
//
//  Created by Babu on 10/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//
//

import Foundation
import CoreData


extension LoginAuth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoginAuth> {
        return NSFetchRequest<LoginAuth>(entityName: "LoginAuth")
    }

    @NSManaged public var username: String?
    @NSManaged public var password: String?

}

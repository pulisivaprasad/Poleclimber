//
//  UserModel.swift
//  Agharia
//
//  Created by sivaprasad reddy on 18/11/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation

public class UserModel {
    public var last_name: String?
    public var first_name: String?
    public var email: String?
    public var user_id: String?
    public var profile_url: String?
   
    public class func modelsFromDictionaryArray(array:NSArray) -> [UserModel] {
        
        var models:[UserModel] = []
        for item in array
        {
            models.append(UserModel(dictionary: item as! [String: AnyObject])!)
        }
        return models
    }

    public required init?(dictionary: [String: Any]) {
        email = dictionary["email"] as? String
        user_id = dictionary["user_id"] as? String
        profile_url = dictionary["profile_url"] as? String
        first_name = dictionary["first_name"] as? String
        last_name = dictionary["last_name"] as? String
    }
}

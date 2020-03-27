//
//  PWebService.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 26/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import Alamofire

class PWebService: NSObject {
    
static let sharedWebService = PWebService()
typealias CompletionHandler = (_ status:String, _ response : [String:AnyObject]?, _ message:String?) -> ()

    func callWebAPIWith(httpMethod: String,
                          apiName: String,
                          parameters: [String: AnyObject],
                          uploadImage: UIImage? = nil,
                          completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> ()) {
          
          let urlStr = NSString(format:"%@%@",kBaseUrl, apiName) as String
          guard let url = URL(string: urlStr) else {
              completion(nil, nil)
              return
          }
          
        AF.request(url, method: .post, parameters: parameters)
                     .validate()
                     .responseJSON { response in
                        switch response.result {
                           case .success(let value):
                            completion(value as AnyObject?, nil)
                           case .failure(let error):
                            completion(nil, error as NSError)
                        }
                  
          }
          
      }
}

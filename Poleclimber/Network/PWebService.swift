//
//  PWebService.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 26/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import Alamofire

enum APIType : String {
case signUpAccount              = "SIGN_UP"
case signInAccount              = "SIGN_IN"
}

let kUSERS_T                        = "USERS"

class PWebService: NSObject {
    
static let sharedWebService = PWebService()
    
typealias CompletionHandler = (_ status:Int, _ response : [String:AnyObject]?, _ message:String?) -> ()
typealias CompletionHandlerWithAnyObject = (_ status: Int, _ response: AnyObject?, _ message: String?) -> Void

    var currentUser = UserModel(dictionary: [String: Any]())

    func callWebAPIWith(httpMethod: String,
                          apiName: String,
                          parameters: [String: AnyObject],
                          uploadImage: UIImage? = nil,
                          completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> ()) {
          
          let urlStr = NSString(format:"%@",kBaseUrl) as String
          guard let url = URL(string: urlStr) else {
              completion(nil, nil)
              return
          }
          
//        AF.request(url, method: .post, parameters: parameters)
//                     .validate()
//                     .responseJSON { response in
//                        switch response.result {
//                           case .success(let value):
//                            completion(value as AnyObject?, nil)
//                           case .failure(let error):
//                            completion(nil, error as NSError)
//                        }
//
//          }

        
        
//        AF.upload(.POST, URLString: url, multipartFormData: { multipartFormData in
//                   multipartFormData.appendBodyPart(fileURL: imagePathUrl!, name: "photo")
//                   multipartFormData.appendBodyPart(fileURL: videoPathUrl!, name: "video")
//               },
//               encodingCompletion: { encodingResult in
//                   switch encodingResult {
//                   case .Success(let upload, _, _):
//                       upload.responseJSON { request, response, JSON, error in
//
//                         }
//                       }
//                   case .Failure(let encodingError):
//
//                   }
//
//           )
//
        
        let headerS: HTTPHeaders = [
        "Authorization": "Bearer (HelperGlobalVars.shared.access_token)",
        "Content-Type": "application/form-data"
        ]
        
        AF.upload(
         multipartFormData: { multipartFormData in
            multipartFormData.append((uploadImage?.jpegData(compressionQuality: 0.5)!)!, withName: "file" , fileName: "image.png", mimeType: "image/jpg")
         },
         to: url, method: .post , headers: headerS)
         .responseJSON { resp in
          switch resp.result {
            case .success(let value):
                completion(value as AnyObject?, nil)
            case .failure(let error):
                completion(nil, error as NSError)
            }
            
        }
          
      }
}

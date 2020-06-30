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

//let kBaseUrl = "http://c5e20ba7.ngrok.io/detect"


class PWebService: NSObject {
    
static let sharedWebService = PWebService()
    
typealias CompletionHandler = (_ status:Int, _ response : [String:AnyObject]?, _ message:String?) -> ()
typealias CompletionHandlerWithAnyObject = (_ status: Int, _ response: AnyObject?, _ message: String?) -> Void


    func callWebAPIWith(httpMethod: String,
                          apiName: String,
                          fileName: String,
                          parameters: [String: AnyObject],
                          uploadImage: UIImage? = nil,
                          completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> ()) {
          
          let urlStr = NSString(format:"%@",apiName) as String
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
        
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 30
        manager.session.configuration.timeoutIntervalForResource = 30
        

        
//        let configuration = URLSessionConfiguration.default
//          configuration.timeoutIntervalForRequest = 300
//          configuration.httpShouldUsePipelining = true
//        let sessionManger = Session(configuration: configuration, startRequestsImmediately: true)

        manager.upload(
         multipartFormData: { multipartFormData in
            multipartFormData.append((uploadImage?.jpegData(compressionQuality: 0.5)!)!, withName: "file" , fileName: fileName, mimeType: "image/jpg")
         },
         to: url, method: .post , headers: headerS)
         .responseJSON { resp in
          switch resp.result {
            case .success(let value):

                completion( value as AnyObject?, nil)
            case .failure(let error):
                completion(nil, error as NSError)
            }

        }
        
       // guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else {return}
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//        guard let dataResponse = data,
//                  error == nil else {
//                  print(error?.localizedDescription ?? "Response Error")
//                  return }
//            do{
//                //here dataResponse received from a network request
//                let jsonResponse = try JSONSerialization.jsonObject(with:
//                                       dataResponse, options: [])
//                print(jsonResponse) //Response result
//             } catch let parsingError {
//                print("Error", parsingError)
//           }
//        }
//        task.resume()
          
      }
    
    func callWebAPIRequest(httpMethod: String,
                        apiName: String,
                        parameters: [String: String],
                        uploadImage: UIImage? = nil,
                        completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> ()) {
        
        let urlStr = NSString(format:"%@",apiName) as String
        guard let url = URL(string: urlStr) else {
            completion(nil, nil)
            return
        }
        
        let headerS: HTTPHeaders = [
        "Content-Type": "application/json"
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headerS)
            .validate()
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    completion(value as AnyObject?, nil)

                    completion( value as AnyObject?, nil)
                case .failure(let error):
                    completion(nil, error as NSError)
                }
        }
        
//        let jsonData = try? JSONEncoder().encode(parameters)
//        //let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // insert json data to the request
//        request.httpBody = jsonData
//
//                let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let dataResponse = data,
//                          error == nil else {
//                          print(error?.localizedDescription ?? "Response Error")
//                          return }
//                    do{
//                        //here dataResponse received from a network request
//                        let jsonResponse = try JSONSerialization.jsonObject(with:
//                                               dataResponse, options: [])
//                        print(jsonResponse) //Response result
//                     } catch let parsingError {
//                        print("Error", parsingError)
//                   }
//                }
//                task.resume()
        
    }
}


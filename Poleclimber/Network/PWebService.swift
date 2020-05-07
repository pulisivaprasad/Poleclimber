//
//  PWebService.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 26/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseDatabase
import FirebaseStorage


enum APIType : String {
case signUpAccount              = "SIGN_UP"
case signInAccount              = "SIGN_IN"
}

let kUSERS_T                        = "USERS"

class PWebService: NSObject {
    
static let sharedWebService = PWebService()
    
typealias CompletionHandler = (_ status:Int, _ response : [String:AnyObject]?, _ message:String?) -> ()
typealias CompletionHandlerWithAnyObject = (_ status: Int, _ response: AnyObject?, _ message: String?) -> Void

    fileprivate let ref = Database.database().reference()
    var currentUser = UserModel(dictionary: [String: Any]())

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
    
      func webService(apiName:APIType, parameters:[String:AnyObject], completion: @escaping CompletionHandler) {

             
         if apiName.rawValue == APIType.signInAccount.rawValue {
               
               signInAccount(parameters: parameters, completion: completion)
           }
           else if apiName.rawValue == APIType.signUpAccount.rawValue {
                   
                   createAnAccount(parameters: parameters, completion: completion)
               }
             
         }
    
     func signInAccount(parameters:[String:AnyObject], completion: @escaping CompletionHandler) {
       
        let email = parameters[kEmailKey]! as! String
        Auth.auth().signIn(withEmail: email.lowercased(), password: parameters[kPasswordKey]! as! String) { (user, error) in

            if error == nil {

                let userKey = email.stringKey()
                let childName = kUSERS_T
               // self.userKey = userKey
                self.ref.child(childName).child(userKey).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if let userDic = snapshot.value as? [String:AnyObject] {
                        self.currentUser = UserModel(dictionary: userDic as [String: AnyObject])
                    }

                    completion(100, snapshot.value as? [String:AnyObject], "Logged in Successfully")
                })
            } else {
                
                completion(101, nil, error?.localizedDescription)
            }
        }

    }
    
    func createAnAccount(parameters:[String:AnyObject], completion: @escaping CompletionHandler) {
        let childName = kUSERS_T
               let userEmail = parameters[kEmailKey] as! String
               let userKey = userEmail.stringKey()
               
        Auth.auth().createUser(withEmail: parameters[kEmailKey] as! String,
                                     password: parameters[kPasswordKey] as! String) { (user, error) in
                  
                  if error == nil {
                      
                      var parametersTemp = parameters
                      parametersTemp.removeValue(forKey: kPasswordKey)
                    
                      let dataDic = self.postRecord(childName: childName, newEntryKey: userKey, parameters: parametersTemp)
                    
                    _ = self.postRecord(childName: kUSERS_T, newEntryKey: userKey, parameters: parameters)

//                      self.currentUser = LCUser(dictionary: parametersTemp as NSDictionary)
//
//                      let dataDic = self.postRecord(childName: childName, newEntryKey: userKey, parameters: parametersTemp)
                      

                      completion(100, dataDic, "Account created successfully.")
                  }
                  else {
                      completion(101, nil, error?.localizedDescription)
                  }
              }
    }
    
    func postRecord(childName:String, newEntryKey:String, parameters:[String:AnyObject]) -> [String:AnyObject] {
           
           var p = parameters
           p["updated_at"] = [".sv": "timestamp"] as AnyObject
           p["created_at"] = [".sv": "timestamp"] as AnyObject
           
           self.ref.child(childName).child(newEntryKey).setValue(p)
           
           return p
       }
    
    func uploadImage(image: UIImage, imageName: String, folderNamePath: String, completion: @escaping CompletionHandlerWithAnyObject) {
           let storage = Storage.storage()
           let storageRef = storage.reference()

           let data1 = image.jpegData(compressionQuality: 0.8)

           let riversRef = storageRef.child("\(folderNamePath)/\(imageName).png")

           _ = riversRef.putData(data1!, metadata: nil) { metadata, error in
               guard metadata != nil else {
                   completion(101, error as AnyObject, error?.localizedDescription)
                   return
               }
               riversRef.downloadURL { url, _ in
                   completion(100, url as AnyObject, "Groups")
               }
           }
       }
    func updatePost(parameters: [String: AnyObject], rowKey: String, childName: String, completion: @escaping CompletionHandler) {
        var p = parameters
        p.removeValue(forKey: "created_at")
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        ref.child(childName).child(rowKey).updateChildValues(p)

        completion(100, nil, "Your Post Updated Successfully.")
    }
}

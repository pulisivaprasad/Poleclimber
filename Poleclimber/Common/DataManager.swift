//
//  DataManager.swift
//  Poleclimber
//
//  Created by Chandra Sekhar Ravi on 10/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    public static let sharedInstance = DataManager()
    private override init() {}
    
    // Helper func for getting the current context.
    func getContext() -> NSManagedObjectContext? {
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
           return appDelegate.persistentContainer.viewContext
       }
    
    func saveChanges()  {
        let managedObjectContext = getContext()
        if managedObjectContext!.hasChanges {
                 do {
                     try managedObjectContext!.save()
                 } catch let nserror as NSError {
                     print("Unresolved error \(nserror), \(nserror.userInfo)")
                     abort()
                 }
             }
       }
    
    func retrieveSavedFeedback(userID: String) -> [Feedback]? {
        
        let fetchRequest = NSFetchRequest<Feedback>(entityName: "Feedback")
        fetchRequest.predicate = NSPredicate(format: "poleTesterID == %@", userID)
        do {
            
            let fetchedResults = try getContext()!.fetch(fetchRequest)
            return fetchedResults
            
        }catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
        return nil
    }
    
    func updateFeedback(parameters: [String: String], fetchID: String) {
           
           let fetchRequest = NSFetchRequest<Feedback>(entityName: "Feedback")
        fetchRequest.predicate = NSPredicate(format: "date == %@", fetchID)
           do {
               
             let fetchedResults = try getContext()!.fetch(fetchRequest)
             let objectUpdate = fetchedResults[0] as NSManagedObject
            
             objectUpdate.setValue(parameters["date"], forKey: "date")
             objectUpdate.setValue(parameters["image"], forKey: "image")
             objectUpdate.setValue(parameters["originalImg"], forKey: "originalImg")
             objectUpdate.setValue(parameters["tipStatus"], forKey: "tipStatus")
             objectUpdate.setValue(parameters["userAcceptance"], forKey: "userAcceptance")
             objectUpdate.setValue(parameters["reason"], forKey: "reason")

            saveChanges()
               
           }catch let error as NSError {
               // something went wrong, print the error.
               print(error.description)
           }
       }
    
    func deleteFeedback(parameters: [String: String], fetchID: String) {
        
        let fetchRequest = NSFetchRequest<Feedback>(entityName: "Feedback")
     fetchRequest.predicate = NSPredicate(format: "date == %@", fetchID)
        do {
            
          let fetchedResults = try getContext()!.fetch(fetchRequest)
          let objectUpdate = fetchedResults[0] as NSManagedObject
          objectUpdate.setValue(parameters["date"], forKey: "date")
          objectUpdate.setValue(parameters["image"], forKey: "image")
          objectUpdate.setValue(parameters["originalImg"], forKey: "originalImg")
          objectUpdate.setValue(parameters["tipStatus"], forKey: "tipStatus")
          objectUpdate.setValue(parameters["userAcceptance"], forKey: "userAcceptance")
          objectUpdate.setValue(parameters["reason"], forKey: "reason")

         saveChanges()
            
        }catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
    }
    func retrieveLoginData(username:String, password:String) -> Bool? {
         
         let fetchRequest = NSFetchRequest<LoginAuth>(entityName: "LoginAuth")
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username,password)
         do {
             
             let fetchedResults = try getContext()!.fetch(fetchRequest)
            if fetchedResults.count > 0{
                return true
            }else{
                return false
            }
             
         }catch let error as NSError {
             // something went wrong, print the error.
             print(error.description)
         }
         return false
     }

}

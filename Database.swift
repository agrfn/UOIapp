//
//  Database.swift
//  UOIapp
//
//  Created by Andrea Griffin on 4/7/16.
//  Copyright © 2016 Andrea Griffin. All rights reserved.
//

import Foundation
import UIKit

class Database{
    
    func startTask(request: NSMutableURLRequest){
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            
            var jsonResult: NSDictionary = NSDictionary()
            
            do{
                jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
            }catch let error as NSError{
                print(error)
            }
        }
        task.resume()
        sleep(3) //give Amount to communicate with database
    }
    
    //adds table to database with user id as name of the table
    func addNewTable(){
        let myURL = NSURL(string: "http://detentiontracker.com/newUser.php")
        let request = NSMutableURLRequest(URL:myURL!)
        request.HTTPMethod = "POST"
        let bodyData = "UserName=\(NSUserDefaults.standardUserDefaults().objectForKey("UserID")!)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        startTask(request)
    }
    
    // adds new entry to table
    func addNewPerson(newPerson:PersonModel, allPeople:PeopleModel)->Bool{
        if newPerson.Name == ""{
            return false
        }else {
            for (var i = 0; i < allPeople.list.count; i += 1){
                if (newPerson.Name == allPeople.list[i].Name){
                    return false
                }
            }
            let myURL = NSURL(string: "http://detentiontracker.com/new.php")
            let request = NSMutableURLRequest(URL:myURL!)
            request.HTTPMethod = "POST"
            let bodyData = "table=\(NSUserDefaults.standardUserDefaults().objectForKey("UserID")!)&Name=\(newPerson.Name!)&Time=\(newPerson.AmountString!)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            startTask(request)
            return true
        }
    }
    
    func deletePerson(workingPerson:PersonModel){
        let myURL = NSURL(string: "http://detentiontracker.com/delete.php")
        let request = NSMutableURLRequest(URL:myURL!)
        request.HTTPMethod = "POST"
        let bodyData = "Name=\(workingPerson.Name!)&table=\(NSUserDefaults.standardUserDefaults().objectForKey("UserID")!)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        startTask(request)
    }

    func updatePerson(workingPerson:PersonModel){
        let myURL = NSURL(string: "http://detentiontracker.com/edit.php")
        let request = NSMutableURLRequest(URL:myURL!)
        request.HTTPMethod = "POST"
        let bodyData = "Name=\(workingPerson.Name!)&Time=\(workingPerson.AmountString!)&table=\(NSUserDefaults.standardUserDefaults().objectForKey("UserID")!)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        startTask(request)
    }

}
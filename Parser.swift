//
//  Parser.swift
//  UOIapp
//
//  Created by Andrea Griffin on 3/10/16.
//  Copyright © 2016 Andrea Griffin. All rights reserved.
//
//  Citation: Ching, Chris. "How To Make an IPhone App Connect to a MySQL Database." Code With Chris. 4 Mar. 2014. Web. 2 Mar. 2016. <http://codewithchris.com/iphone-app-connect-to-mysql-database/>. 


/*------- The following code was developed with the guidance of Code with Chris see the citation above----------*/

import Foundation

protocol ParserProtocol: class{
    func itemsDownloaded(items: NSArray)
}

class Parser: NSObject, NSURLSessionDataDelegate{
    //properties
    weak var delegate:ParserProtocol!
    var data: NSMutableData = NSMutableData() //responsible for storing incoming bits
    let urlPath: String = "http://detentiontracker.com/read.php?table=\(NSUserDefaults.standardUserDefaults().objectForKey("UserID")!)" //declares url path to connect to
    
    func downloadItems(){
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        //initialize NSURLSession, assign it a task, start data retrieval
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:nil)
        let task = session.dataTaskWithURL(url)
        task.resume()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData){
        self.data.appendData(data);
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?){
        if error != nil{
            print("Failed to download data")
        }else{
            print("Data downloaded")
            self.parseJSON()
        }
    }
    
    func parseJSON(){
    
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.AllowFragments) as! NSArray
        } catch let error as NSError{
            print(error)
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        let People: NSMutableArray = NSMutableArray()
        
        for (var i = 0; i < jsonResult.count; i += 1){

            jsonElement = jsonResult[i] as! NSDictionary
            
            let newPerson = PersonModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let newName = jsonElement["Name"] as? String, let newAmount = jsonElement["Time"] as? String{
                newPerson.Name = newName
                newPerson.AmountString = newAmount
                newPerson.AmountToString()
            }
            
            People.addObject(newPerson)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        self.delegate.itemsDownloaded(People)
        
        })
    }
}
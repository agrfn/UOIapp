//
//  PersonModel.swift
//  UOIapp
//
//  Created by Andrea Griffin on 3/8/16.
//  Copyright © 2016 Andrea Griffin. All rights reserved.
//

import Foundation

class PersonModel: NSObject{
    
    //properties
    var Name:String? //Name (first and last)
    var AmountString:String?
    var Amount: Int?
    
    //empty constructor
    override init(){
        Amount = 0
        AmountString = "0"
    }
    
    init(newName:String, newAmount:Int){
        self.Name = newName
        self.Amount = newAmount
        self.AmountString = "\(newAmount)"
    }
    
    //print object's current state
    override var description: String{
        return "\(Name!) Information\n\tAmount: \t\(Amount!)"
    }
    func printInfo(){
        print(description)
    }
    func printName(){
        print("Name: \(Name)")
    }
    
    func printAmount(){
        print("Amount: \(AmountString)")
    }
    func addAmount(newAmount: Int){
        print("beginning Amount: \(Amount!)")
        let ph = Amount! + newAmount
        print("new Amount \(ph)")
        self.changeAmount(ph)
    }
    func changeAmount(newAmount: Int){
        self.Amount = newAmount
        self.AmountString = String(self.Amount!)
        print("AmountString: \(self.AmountString)")
    }
    func AmountToString(){
        self.Amount = Int(AmountString!)
    }
}

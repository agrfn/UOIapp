//
//  PeopleModel.swift
//  UOIapp
//
//  Created by Andrea Griffin on 3/10/16.
//  Copyright © 2016 Andrea Griffin. All rights reserved.
//

import Foundation

class PeopleModel: NSObject{
    var title:String = "NoTitle"
    var list = [PersonModel]()
    
    override init(){
    }
    
    init(newTitle: String){
        self.title = newTitle
        self.list = []
    }
    
    func clearList(){
        list.removeAll()
    }
    
    func printAllPeopleInfo(){
        print("****** \(title) People *******\n")
        for (var i = 0; i < self.list.count; i += 1){
            list[i].printInfo()
        }
        print("\n*************************")
    }
    
    func byName(value1: PersonModel, value2: PersonModel) -> Bool { //A to Z
        return value1.Name < value2.Name
    }
    
    func byAmount(value1: PersonModel, value2:PersonModel) -> Bool { //highest Amount first
        return value1.Amount > value2.Amount
    }

    func sortByName(){
        list.sortInPlace(byName)
    }
    
    func sortByAmount(){
        list.sortInPlace(byAmount)
    }
    
    
    
}

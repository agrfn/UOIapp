//
//  ViewController.swift
//  UOIapp
//
//  Created by Andrea Griffin on 3/4/16.
//  Copyright © 2016 Andrea Griffin. All rights reserved.
//
//
//  Citation: Ching, Chris. "How To Make an IPhone App Connect to a MySQL Database." Code With Chris. 4 Mar. 2014. Web. 2 Mar. 2016. <http://codewithchris.com/iphone-app-connect-to-mysql-database/>. 

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, ParserProtocol {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var ReviewButton: UIButton! //Change Dues Button
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var DeletePersonButton: UIButton!
    @IBOutlet weak var AddAmountSwitch: UISwitch!
    @IBOutlet weak var SubAmountSwitch: UISwitch!
    @IBOutlet weak var AddNewButton: UIButton! //New Person button
    @IBOutlet weak var PersonListPicker: UIPickerView!
    @IBOutlet weak var AmountSlider: UISlider!
    @IBOutlet weak var AmountLabel: UILabel!
    
    var allPeople = PeopleModel(newTitle: "All") //All people
    var UOIPeople = PeopleModel(newTitle: "UOI") //Only people that owe
    var action:Bool = true //true if adding, false if subtracting
    var PickerRow = 0 //index for list of people
    var workingPerson:PersonModel = PersonModel() //current person picked
    var workingAmount:Int = 0 //current amount of Amount used
    var feedItems: NSArray = NSArray() //holds downloaded items
    var tField: UITextField! //text field used for textfield input in alert
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //For top of main screen
        navigationItem.prompt = "Welcome to UOIapp!"
        navigationItem.title = "Changing dues"
        
        PersonListPicker.delegate = self
        PersonListPicker.dataSource = self
        AmountLabel.adjustsFontSizeToFitWidth = true
        ActivityIndicator.stopAnimating() //when loaded stop animating
        
        //Download table entries from database
        download() //runs itemsDownloaded function
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*--- The following code was developed with the guidance of Code with Chris to read from MySQL database---*/
    func download(){
        ActivityIndicator.startAnimating()
        checkInternet()
        
        let parser = Parser()
        parser.delegate = self
        parser.downloadItems()
    }
    func itemsDownloaded(items: NSArray){
        feedItems = items
        
        //Clears old lists from current running app
        allPeople.clearList()
        UOIPeople.clearList()
        
        //Loads feedItems into appropriate people lists
        for(var i = 0; i < feedItems.count; i += 1){
            let item : PersonModel = feedItems[i] as! PersonModel
            allPeople.list.append(item) //saves all people to application
            if item.AmountString != "0"{UOIPeople.list.append(item)}
        }
        
        //Sorts people lists
        allPeople.sortByName()
        UOIPeople.sortByAmount()
        
        self.PersonListPicker.reloadAllComponents() //updates list picker
        
        // If no entries in table, run noOneSaved() function
        if allPeople.list.count == 0 {
            ActivityIndicator.startAnimating()
            noOneSaved()
        }
        
        // If the last action was false, and there are no longer any people that owe, change action to true
        if UOIPeople.list.count == 0 && action == false{
            actionChosen(true)
        }
        
        // If there are any people in the all list, update the workingPerson
        if allPeople.list.count != 0 {
            updateworkingPerson()
        }
        
        ActivityIndicator.stopAnimating()
    }
    /*--- The code above was developed with the guidance of Code with Chris to read from MySQL database---*/
    
    
    // noOneSaved is run when there are no longer people listed in the table and therefore the user must enter a person to begin using the applcation. noOneSaved runs an alert with a text field input to complete this task
    func noOneSaved(){
        let alertController = UIAlertController(title: "Need to add a person's name to begin.", message: "", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler (alertTextField)
        let addPerAction = UIAlertAction(title: "Submit", style: .Default, handler: haveToaddPerson) //runs haveToaddPerson function when submit is chosen
        alertController.addAction(addPerAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    func haveToaddPerson(alert: UIAlertAction){
        let name = tField.text! as String
        let newPerson = PersonModel(newName: name, newAmount: 0)
        checkInternet()
        let database = Database()
        if !database.addNewPerson(newPerson,allPeople: allPeople){
            noOneSaved()
        }else{
            download()
        }
    }
    
    func actionChosen(choice: Bool){
        if choice { //adding amount
            enableButton(AddNewButton)
            enableButton(DeletePersonButton)
            action = true
            AmountSlider.maximumValue = 100
            
            //Incase action changed programmatically
            SubAmountSwitch.setOn(false, animated: false)
            AddAmountSwitch.setOn(true, animated: false)
        }
        else{ //subtracting amount
            disableButton(AddNewButton)
            disableButton(DeletePersonButton)
            action = false
            
            //Incase action changed programmatically
            SubAmountSwitch.setOn(true, animated: false)
            AddAmountSwitch.setOn(false, animated: false)
            
        }
        self.PersonListPicker.reloadAllComponents()
        PickerRow = 0
        updateworkingPerson()
    }
    
    @IBAction func toggleSwitches(sender: UISwitch) {
        if sender == AddAmountSwitch{
            if AddAmountSwitch.on{
                SubAmountSwitch.setOn(false, animated: false)
                actionChosen(true)
            }
            else if !AddAmountSwitch.on{
                SubAmountSwitch.setOn(true, animated: false)
                disableButton(AddNewButton)
                actionChosen(false)
            }
        }else if sender == SubAmountSwitch{
            if UOIPeople.list.count == 0{
                
                SubAmountSwitch.setOn(false, animated: false)
                let alertController = UIAlertController(title: "No one owes you anything.", message: "", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                presentViewController(alertController, animated: true, completion: nil)
                
            }else{
                if SubAmountSwitch.on{
                    AddAmountSwitch.setOn(false, animated: false)
                    actionChosen(false)
                }
                else if !SubAmountSwitch.on{
                    AddAmountSwitch.setOn(true, animated: false)
                    actionChosen(true)
                }
            }
            
        }
    }
    
    func updateworkingPerson() {
        if action{
            workingPerson = allPeople.list[PickerRow]
        }else{
            workingPerson = UOIPeople.list[PickerRow]
            AmountSlider.maximumValue = Float(workingPerson.Amount!)
        }
    }
    //initial picker view functions
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if action{return (allPeople.list[row].Name)}
        else{return (UOIPeople.list[row].Name! + " " + String(UOIPeople.list[row].Amount!))}
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if action{return (allPeople.list.count)}
        else{return (UOIPeople.list.count)}
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PickerRow = row
        updateworkingPerson()
    }
    
    @IBAction func ButtonPressed(sender: UIButton) {
        ActivityIndicator.startAnimating()
        checkInternet()
        if workingPerson.Name == nil {
            workingPerson = allPeople.list[PickerRow]
        }
        switch sender{
        
        case ReviewButton:
            var actionTitle = ""
            if action{actionTitle = "Add \(workingAmount) to \(workingPerson.Name!)'s dues?"}
            else{actionTitle = "Subtract \(workingAmount) from \(workingPerson.Name!)'s dues?"}
            let alertController = UIAlertController(title: actionTitle, message: "", preferredStyle: .Alert)
            let changeAction = UIAlertAction(title: "Yes, make change", style: .Default, handler: updatePerson)
            let dontChangeAction = UIAlertAction(title: "No! Don't make change!", style: .Default, handler: stopAct)
            alertController.addAction(changeAction)
            alertController.addAction(dontChangeAction)
            presentViewController(alertController, animated: true, completion: nil)
        
        case AddNewButton:
            let alertController = UIAlertController(title: "Person name: ", message: "", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler (alertTextField)
            let addPerAction = UIAlertAction(title: "Submit", style: .Default, handler: addPerson)
            let canAddPerAction = UIAlertAction(title: "Cancel", style: .Default, handler: stopAct)
            alertController.addAction(addPerAction)
            alertController.addAction(canAddPerAction)
            presentViewController(alertController, animated: true, completion: nil)
            
        case DeletePersonButton:
            let alertController = UIAlertController(title: "Delete \(workingPerson.Name!)?", message: "", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "Yes, delete", style: .Default, handler: deletePerson)
            let dontDeleteAction = UIAlertAction(title: "No! Don't delete!", style: .Default, handler: stopAct)
            alertController.addAction(deleteAction)
            alertController.addAction(dontDeleteAction)
            presentViewController(alertController, animated: true, completion: nil)
            
        default: break
        }
    }
    func alertTextField(textField: UITextField){
        textField.placeholder = "Name"
        textField.autocapitalizationType = UITextAutocapitalizationType.Words
        tField = textField
    }
    func stopAct(alert: UIAlertAction){
        ActivityIndicator.stopAnimating()
    }
    func updatePerson(alert: UIAlertAction){
        checkInternet()
        let database = Database()
        var addAmount = 0
        if action{addAmount = workingAmount}
        else{addAmount = workingAmount * (-1)}
        workingPerson.addAmount(addAmount)
        database.updatePerson(workingPerson)
        download()
    }
    @IBAction func AmountChanged(sender: UISlider) {
        sender.setValue((Float)((Int)((sender.value + 0.5) / 1)), animated: false)
        workingAmount = Int(sender.value)
        AmountLabel.text = "Amount: \(String(workingAmount))"
    }
    
    func addPerson(alert: UIAlertAction){
        let name = tField.text! as String
        let newPerson = PersonModel(newName: name, newAmount: 0)
        checkInternet()
        let database = Database()
        if !database.addNewPerson(newPerson,allPeople: allPeople){
            tryAgainText()
        }else{
            download()
        }
    }
    func tryAgainText(){
        let alertController = UIAlertController(title: "Oops! Please enter a name!", message: "*Cannot be a name already in your list.*", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler (alertTextField)
        let addPerAction = UIAlertAction(title: "Submit", style: .Default, handler: addPerson)
        let canAddPerAction = UIAlertAction(title: "Cancel", style: .Default, handler: stopAct)
        alertController.addAction(addPerAction)
        alertController.addAction(canAddPerAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deletePerson(alert: UIAlertAction){
        checkInternet()
        let database = Database()
        database.deletePerson(workingPerson)
        download()
        if PickerRow != 0 {
            PickerRow = PickerRow - 1
        }
    }
    
    func checkInternet(){
        if Reachability.isConnectedToNetwork() {
            print("Internet connection OK")
            ActivityIndicator.stopAnimating()
        } else {
            print("Internet connection FAILED")
            let alertController = UIAlertController(title: "Need to be connected to Wifi.", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: internetCheckLoop)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    func internetCheckLoop(alert: UIAlertAction){
        checkInternet()
    }
    
    func disableButton (sender: UIButton){
        sender.enabled = false
        sender.hidden = true
    }
    func enableButton (sender: UIButton){
        sender.enabled = true
        sender.hidden = false
    }
    
}


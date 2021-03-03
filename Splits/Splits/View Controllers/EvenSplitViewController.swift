//
//  EvenSplitViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class EvenSplitViewController:UIViewController {
    
    @IBOutlet weak var splitNameLabel: UILabel!
    @IBOutlet weak var listOfParticipants: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var buttonPeriod: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    
    //TODO: get number of participants from addContacts vc
    let numberOfParticipants = 2
    var tenthsPlace = false //currently in the tenths place of totalAmount
    var hundredthsPlace = false //currently in the hundreths place of totalAmount
    var stopInput = false //after 2 decimal places, don't update totalAmount label
    var splitGroupId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("splitgroupId:", splitGroupId)
        loadSplitGroupInfo(splitGroupId: splitGroupId)
        
        //inialized labels
        //TODO: get splitName from addContacts vc
        //TODO: get participant names from addContacts vc
        splitNameLabel.text = "Split Name"
        listOfParticipants.text = "List of Participants"
        totalAmountLabel.text = "$"
        
        //initialize button states
        buttonBack.isEnabled = false
        buttonPeriod.isEnabled = true
        
        //initialize states
        tenthsPlace = false
        hundredthsPlace = false
        stopInput = false

    }
    
    @IBAction func previousView(_ sender: UIBarButtonItem) {
        displayView(storyboard: "newSplit", vcName: "addContactsView")
    }
    //TODO: Update split name label from addContact vc
    //TODO: get participant list from addContact vc

    //Update total amount label based on user input
    @IBAction func button1Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "1")
        }
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "2")
        }
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "3")
        }
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "4")
        }
    }
    
    @IBAction func button5Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "5")
        }
    }
    
    @IBAction func button6Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "6")
        }
    }
    
    @IBAction func button7Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "7")
        }
    }
    
    @IBAction func button8Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "8")
        }
    }
    
    @IBAction func button9Pressed(_ sender: Any) {
        if !stopInput{
        updateTotalAmountLabel(buttonName: "9")
    }
}
    
    @IBAction func buttonPeriodPressed(_ sender: Any) {
        buttonPeriod.isEnabled = false
        updateTotalAmountLabel(buttonName: ".")
    }
    
    @IBAction func button0Pressed(_ sender: Any) {
        if !stopInput{
            updateTotalAmountLabel(buttonName: "0")
        }
    }
    
    @IBAction func buttonBackPressed(_ sender: Any) {
        updateTotalAmountLabel(buttonName: "back")
    }
    
    //Calculate even split amount and trigger payment
    //TODO: trigger payment on create split button
    @IBAction func createSplitButton(_ sender: Any) {
        guard var totalAmountString = totalAmountLabel.text else {
            print("no amount inputted")
            return
        }
        
        //remove dollar sign in front of the string
        totalAmountString = String(totalAmountString.dropFirst())
        
        //convert total amount string to double
        let totalAmount = Double(totalAmountString) ?? 0.0
        
        //ERROR: Displays one decimal place for whole numbers. ie: $10.0 instead of $10.00
        let evenSplitAmount = round(totalAmount/Double(numberOfParticipants)*100)/100.0
        print("Participants pay $\(evenSplitAmount) each")
        
        displayView(storyboard: "Main", vcName: "homeView")
    }
    
    func updateTotalAmountLabel(buttonName: String) {
        guard let totalAmount = totalAmountLabel.text else {
            return
        }
        
        //if back button is pressed, remove the last character
        if buttonName == "back" {
            if hundredthsPlace && !stopInput { //removing tenths number
                hundredthsPlace = false
            } else if hundredthsPlace { //removing hundredths number
                stopInput = false
            }
            
            //if removing period, enable period button
            if(totalAmount.last == ".") {
                buttonPeriod.isEnabled = true
                tenthsPlace = false
            }
            
            //remove the last character
            let updatedTotalAmount = totalAmount.dropLast()
            totalAmountLabel.text = String(updatedTotalAmount)
            
            //disable the back button if no amount is inputted
            if updatedTotalAmount == "$" {
                buttonBack.isEnabled = false
            }
        } else {
            //if back button wasn't pressed, add character
            let updatedTotalAmount = totalAmount + buttonName
            totalAmountLabel.text = updatedTotalAmount
            
            //enable back button if disabled
            if !buttonBack.isEnabled {
                buttonBack.isEnabled = true
            }
            
            //if we filled the hundredths place, then stop taking in numbers
            if hundredthsPlace {
                stopInput = true
            }
            
            //if we filled the tenths place, then take in 1 number
            if tenthsPlace {
                hundredthsPlace = true
            }
            
            //if we set a decimal, take in 2 more numbers
            if buttonName == "." {
                tenthsPlace = true
            }
        }
        
        return
    }
    
    func loadSplitGroupInfo(splitGroupId: String) {
        
    }
    
    func displayView(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}





//
//  CreateViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 3/15/21.
//

import UIKit
import VisionKit
import Vision
import FirebaseFunctions

// MARK: -Global Variables
var itemIndexToUserArray:[String] = [String]()

func updateSelectedUser(user:String) {
    itemIndexToUserArray.append(user)
    return
}

func updateSelectedUser(itemIndex: Int, user: String) {
    itemIndexToUserArray[itemIndex] = user
    return
}

func getSelectedUsers() -> [String] {
    return itemIndexToUserArray
}

func deleteSelectedUser(itemIndex: Int) {
    itemIndexToUserArray.remove(at: itemIndex)
    return
}

// MARK: -Create View Controller Class
class CreateViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    // Variables from previous view
    var participants = [String]()
    var participantMap: [String:String] = [:]
    var reverseParticipantMap: [String: String] =  [:]
    var splitName = String()
    var splitUid: String = ""
    var isEqualSplit = true
    var itemToPriceMap: [String: Double] = [:]
    var itemToUserMap: [String: String] = [:]
    var requestedAmount: Double = 0.0

    @IBOutlet weak var pageSwitch: UISegmentedControl!
    
    // MARK: Equal Split View Variables
    @IBOutlet weak var splitNameLabel: UILabel!
    @IBOutlet weak var equalSplitAmount: UILabel!
    @IBOutlet weak var keyPad: UIStackView!
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tempView: UIView!
    
    var tenthsPlace = false //currently in the tenths place of totalAmount
    var hundredthsPlace = false //currently in the hundreths place of totalAmount
    var stopInput = false //after 2 decimal places, don't update totalAmount label
    
    
    // MARK: Itemized Split View and Camera Variables
    @IBOutlet weak var itemTableView: UITableView!
    let receiptContentsIdentifier = "receiptContentsTable"
    var textRecognitionRequest = VNRecognizeTextRequest()
    var tableContents = ReceiptContents()
    @IBOutlet weak var plusButton: UIButton!
    
    static let textHeightThreshold: CGFloat = 0.025 //differentiate big/small labels
    
    //Receipt information
    typealias ReceiptContentField = (price: String, description: String)
    typealias RecieptTableDataSource = (price: String, description: String, user: String)
    struct ReceiptContents {

        var storeName: String?
        var items = [ReceiptContentField]()
    }
    var tableDataSource: [RecieptTableDataSource] = []

    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("splitUid uid: ", splitUid)
        print("participantMap: ", participantMap)
        
        // initialize table
        self.itemTableView.dataSource = self
        self.itemTableView.rowHeight = 100.0
        for (key, values) in participantMap{
            reverseParticipantMap[values] = key
        }
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in

            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    DispatchQueue.main.async {
                        self.addRecognizedText(recognizedText: requestResults)
                    }
                }
            }
        })
        
        // initialize equal split
        splitNameLabel.text = splitName
        equalSplitAmount.text = "$"
        
        // initialize button states
        backButton.isEnabled = false
        periodButton.isEnabled = true
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.isEnabled = false
        plusButton.isHidden = true
        tempView.isHidden = false
        
        // initialize states
        tenthsPlace = false
        hundredthsPlace = false
        stopInput = false
        
        // initialize view settings
        keyPad.isHidden = false
        itemTableView.isHidden = true
        
        // selecter settings
        pageSwitch.setTitleTextAttributes([.foregroundColor : UIColor.systemOrange], for: .normal)
        pageSwitch.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        
        // global variables
        itemIndexToUserArray.removeAll()
        
    }
    
    // MARK: Select Even/Itemized View
    @IBAction func switchedView(_ sender: Any) {
        switch pageSwitch.selectedSegmentIndex {
        case 1: //unequal split
            keyPad.isHidden = true
            itemTableView.isHidden = false
            plusButton.isEnabled = true
            plusButton.isHidden = false
            tempView.isHidden = true
            isEqualSplit = false
        case 0: //equal split
            keyPad.isHidden = false
            itemTableView.isHidden = true
            plusButton.isEnabled = false
            plusButton.isHidden = true
            tempView.isHidden = false
            isEqualSplit = true
        default:
            break
        }
    }
    
    
    // MARK: Equal Split View
    @IBAction func keyButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        // add buttonName to total amount string
        case 1:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "1")
            }
        case 2:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "2")
            }
        case 3:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "3")
            }
        case 4:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "4")
            }
        case 5:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "5")
            }
        case 6:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "6")
            }
        case 7:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "7")
            }
        case 8:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "8")
            }
        case 9:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "9")
            }
        case 0:
            if !stopInput{
                updateTotalAmountLabel(buttonName: "0")
            }
        case 10:
            periodButton.isEnabled = false
            updateTotalAmountLabel(buttonName: ".")
        case 11:
            updateTotalAmountLabel(buttonName: "back")
        default:
            return
        }
    }
    
    // updates total amount label
    func updateTotalAmountLabel(buttonName: String) {
        guard let totalAmount = equalSplitAmount.text else {
            return
        }
        
        // if back button is pressed, remove the last character
        if buttonName == "back" {
            if hundredthsPlace && !stopInput { //removing tenths number
                hundredthsPlace = false
            } else if hundredthsPlace { //removing hundredths number
                stopInput = false
            }
            
            // if removing period, enable period button
            if(totalAmount.last == ".") {
                periodButton.isEnabled = true
                tenthsPlace = false
            }
            
            // remove the last character
            let updatedTotalAmount = totalAmount.dropLast()
            equalSplitAmount.text = String(updatedTotalAmount)
            
            // disable the back button if no amount is inputted
            if updatedTotalAmount == "$" {
                backButton.isEnabled = false
            }
        } else {
            // if back button wasn't pressed, add character
            let updatedTotalAmount = totalAmount + buttonName
            equalSplitAmount.text = updatedTotalAmount
            
            // enable back button if disabled
            if !backButton.isEnabled {
                backButton.isEnabled = true
            }
            
            // if we filled the hundredths place, then stop taking in numbers
            if hundredthsPlace {
                stopInput = true
            }
            
            // if we filled the tenths place, then take in 1 number
            if tenthsPlace {
                hundredthsPlace = true
            }
            
            // if we set a decimal, take in 2 more numbers
            if buttonName == "." {
                tenthsPlace = true
            }
        }
        
        return
    }
    
    // MARK: Itemized Split and Camera View
    // Scan Receipt Button
    @IBAction func scan(_ sender: UIButton) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
        pageSwitch.selectedSegmentIndex = 1
        switchedView(self)
    }
    
    // Display previous vc
    @IBAction func backButtonTapped(_ sender: Any) {
        displayViewController(storyboard: "Create", vcName: "addContactsVC")
    }

    // Add Item Button using popup alerts
    @IBAction func addButtonTapped(_ sender: Any) {
        let addAlert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        addAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input item description here"
        })
        
        addAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input item price here"
            textField.keyboardType = UIKeyboardType.decimalPad
        })

        addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            // unwrap description and price from alert
            if let description = addAlert.textFields?.first?.text {
                if let price = addAlert.textFields?.last?.text {
                    self.tableContents.items.append((price, description))
                }
            }
            
            // get next row num in item table
            self.itemTableView.beginUpdates()
            var itemRowNum:Int = 0
            if self.tableContents.items.count != 0 {
                itemRowNum = self.tableContents.items.count-1
            } else {
                itemRowNum = 0
            }
            
            // update item table
            self.itemTableView.insertRows(at: [IndexPath(row: itemRowNum, section: 0)], with: .automatic)
            updateSelectedUser(user: self.participants[0])
            self.itemTableView.endUpdates()
        }))

        self.present(addAlert, animated: true)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // process the image that was scanned
    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func createSplit(_ sender: UIButton) {
        guard var totalAmountString = equalSplitAmount.text else {
            print("no amount inputted")
            return
        }
        
        //add split creater to participant number
        let numberOfParticipants = participants.count + 1
        
        //remove dollar sign in front of the string
        totalAmountString = String(totalAmountString.dropFirst())
        
        //convert total amount string to double
        let totalAmount = Double(totalAmountString) ?? 0.0
        
        //ERROR: Displays one decimal place for whole numbers. ie: $10.0 instead of $10.00
        let evenSplitAmount = round(totalAmount/Double(numberOfParticipants)*100)/100.0
        print("Participants pay $\(evenSplitAmount) each")
        
        if isEqualSplit {
            requestedAmount = evenSplitAmount
        }
        
        // Creates a transaction for the split
        if isEqualSplit {
            print("IS EQUAL")
            SplitService.createEqualSplit(totalAmount: totalAmount, evenSplitAmount: evenSplitAmount, splitUid: splitUid, recipient: User.current)
                    
            // Format text message
            let totalAmountmessage = String(requestedAmount)
            var isOwed = true
            for x in 0..<participants.count{
                let userphoneNumber = reverseParticipantMap[participants[x]]
                isOwed = true
                let data : [String: String] = [
                    "phoneNumber": String(userphoneNumber ?? ""),
                    "totalAmount": totalAmountmessage,
                    "isEqual": "true",
                    "isOwed": String(isOwed),
                    "yourname": participants[x],
                    "recieverName": User.current.name
                ]
                
                // Send a message to the split participant for amount owed
                Functions.functions().httpsCallable("textStatus").call(data) { (result, error) in
                       if let error = error {
                            // send alert - unable to send message
                            print(error.localizedDescription)
                            return
                        }
                        // sent message here!
                        print("ok")
                }
            }
            
            isOwed = false
            
            // Format split creater message
            let data : [String: String] = [
                "phoneNumber": User.current.phoneNumber,
                "totalAmount": totalAmountmessage,
                "isEqual": "true",
                "isOwed" : String(isOwed),
            ]
            
            // Send a message to the split creater for amount owed
            Functions.functions().httpsCallable("textStatus").call(data) { (result, error) in
                       if let error = error {
                            // send alert - unable to send message
                        print(error.localizedDescription)
                            return
                        }
                        // sent message here!
                        print("ok")
            }
        
        } else {
            print("IS ITEMIZED")
            print("Map: \(itemToPriceMap)")
            print("Map count: \(itemToPriceMap.count)")
            print("Array count: \(itemIndexToUserArray.count)")
            print("ITEM INDEX ARRAY: \(itemIndexToUserArray)")
            print(itemIndexToUserArray)
            
            // calculate total amount per user
            var userTotal: [String: Double] = [String:Double]()
            var userToItems:[String:[String:Double]] = [String:[String:Double]]()
            var itemIndex = 0
            while itemIndex < itemIndexToUserArray.count {
                let itemName = tableContents.items[itemIndex].description
                let user = itemIndexToUserArray[itemIndex]
                if let itemPrice = itemToPriceMap[itemName] {
                    if userToItems[user] != nil {
                        userToItems[user]?[itemName] = itemPrice
                    } else {
                        userToItems[user] = [itemName:itemPrice]
                    }
                    userTotal[user] = (userTotal[user] ?? 0.0) + itemPrice
                }
                itemIndex += 1
            }
            
            print(userTotal)
            
            // Text message call
            var userPhoneNumber = ""
            var item = ""
            var price = ""
            var totalAmt = 0.0
            for (key, value) in userToItems {
                var messageBody = ""
                userPhoneNumber = reverseParticipantMap[key] ?? ""
                totalAmt = userTotal[key] ?? 0.0
                for (innerKey, innerValue) in value {
                    item = innerKey
                    price = String(innerValue)
                    messageBody += item + " $" + price + " "
                    messageBody += "\n"
                }
                let data : [String: String] = [
                    "phoneNumber": String(userPhoneNumber ),
                    "messageBody": messageBody,
                    "isEqual": "false",
                    "isOwed" : "true",
                    "yourname": key,
                    "recieverName": User.current.name,
                    "totalAmt": String(totalAmt)
                ]
                Functions.functions().httpsCallable("textStatus").call(data) { (result, error) in
                           if let error = error {
                                // send alert - unable to send message
                                print(error.localizedDescription)
                                return
                            }
                            // sent message here!
                            print("ok")
                }
                
            }
            let amounttoBePaid = userTotal[User.current.name]
            // Create split creater message
            let data : [String: String] = [
                "phoneNumber": User.current.phoneNumber,
                "totalAmount": String(format: "", amounttoBePaid ?? "0"),
                "isEqual": "true",
                "isOwed" : "ture",
            ]
            // Send a message to the split creater for amount owed
            Functions.functions().httpsCallable("textStatus").call(data) { (result, error) in
                       if let error = error {
                            // send alert - unable to send message
                        print(error.localizedDescription)
                            return
                        }
                        // sent message here!
                        print("ok")
            }
            
            print(userToItems)
            print(userTotal)
        }
            
        // Update the current user with the new split
        UserService.updateCurrentUser(user: User.current) { (user) in
            print("Updating User after Split")
            if let user = user {
                print("User's Splits", user.splits)
                User.setCurrent(user, writeToUserDefaults: true)
            }
            return
        }
        
        self.displayViewController(storyboard: "Main", vcName: "homeView")
    }
}

// MARK: Custom Receipt Class
class ReceiptTableCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var userPickerView: UIPickerView!
    @IBOutlet weak var itemText: UILabel!
    @IBOutlet weak var priceText: UILabel!
    var itemIndex: Int = 0
    var users: [String] = []
    
    override func awakeFromNib() {
            self.userPickerView.delegate = self;
            self.userPickerView.dataSource = self;
            super.awakeFromNib()
        }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return users.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow pickerRow: Int, forComponent component: Int) -> String? {
        return users[pickerRow]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow pickerRow: Int, inComponent component: Int) {
        updateSelectedUser(itemIndex: itemIndex, user: users[pickerRow])
        return
    }
    
}


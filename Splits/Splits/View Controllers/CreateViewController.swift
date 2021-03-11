/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller from which to invoke the document scanner.
*/

import UIKit
import VisionKit
import Vision
import FirebaseFunctions

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
        
        // Equal Split
        splitNameLabel.text = splitName
        equalSplitAmount.text = "$"
        
        //initialize button states
        backButton.isEnabled = false
        periodButton.isEnabled = true
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.isEnabled = false
        plusButton.isHidden = true
        tempView.isHidden = false
        
        //initialize states
        tenthsPlace = false
        hundredthsPlace = false
        stopInput = false
        
        //View settings
        keyPad.isHidden = false
        itemTableView.isHidden = true
        
        // Selecter Settings
        pageSwitch.setTitleTextAttributes([.foregroundColor : UIColor.systemOrange], for: .normal)
        pageSwitch.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        
        //global variable
        itemIndexToUserArray.removeAll()
        itemIndexToUser.removeAll()
        
    }
    
    // MARK: Selector
    
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
    
    func updateTotalAmountLabel(buttonName: String) {
        guard let totalAmount = equalSplitAmount.text else {
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
                periodButton.isEnabled = true
                tenthsPlace = false
            }
            
            //remove the last character
            let updatedTotalAmount = totalAmount.dropLast()
            equalSplitAmount.text = String(updatedTotalAmount)
            
            //disable the back button if no amount is inputted
            if updatedTotalAmount == "$" {
                backButton.isEnabled = false
            }
        } else {
            //if back button wasn't pressed, add character
            let updatedTotalAmount = totalAmount + buttonName
            equalSplitAmount.text = updatedTotalAmount
            
            //enable back button if disabled
            if !backButton.isEnabled {
                backButton.isEnabled = true
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
    
    // MARK: Itemized Split and Camera View
    
    // Add Receipt Button
    @IBAction func scan(_ sender: UIButton) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
        pageSwitch.selectedSegmentIndex = 1
        switchedView(self)
    }
    
    // Back Button
    @IBAction func backButtonTapped(_ sender: Any) {
        displayViewController(storyboard: "Create", vcName: "addContactsVC")
    }

    // Add Item Button
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

            if let description = addAlert.textFields?.first?.text {
                if let price = addAlert.textFields?.last?.text {
                    self.tableContents.items.append((price, description))
                }
            }
            
            self.itemTableView.beginUpdates()
            var itemRowNum:Int = 0
            if self.tableContents.items.count != 0 {
                itemRowNum = self.tableContents.items.count-1
            } else {
                itemRowNum = 0
            }
            self.itemTableView.insertRows(at: [IndexPath(row: itemRowNum, section: 0)], with: .automatic)
            //updateSelectedUser(itemIndex: itemRowNum, user: self.participants[0])
            updateSelectedUser(user: self.participants[0])
            self.itemTableView.endUpdates()
        }))

        self.present(addAlert, animated: true)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
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

//        itemIndexToUser Int: String
//        itemIndexToName
//        itemToPrice: String:Double
        
        // Creates a transaction for the split
        if isEqualSplit {
            print("IS EQUAL")
            SplitService.createEqualSplit(totalAmount: totalAmount, evenSplitAmount: evenSplitAmount, splitUid: splitUid, recipient: User.current)
                    
        let totalAmountmessage = String(requestedAmount)
//        var isEqual = true
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
            // Send a message to the user for amount owed
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
            // Send the user a message too
            let data : [String: String] = [
                "phoneNumber": User.current.phoneNumber,
                "totalAmount": totalAmountmessage,
                "isEqual": "true",
                "isOwed" : String(isOwed),
            ]
            // Send a message to the user for amount owed
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
            print("IS ITEMIZED", itemToPriceMap, itemIndexToUser)
            
            var itemIndexToUser: [Int:String] = [:]
            var i:Int = 0
            while i < itemIndexToUserArray.count {
                itemIndexToUser[i] = itemIndexToUserArray[i]
                i += 1
            }
            
            print("Map count: \(itemToPriceMap.count)")
            print("Array count: \(itemIndexToUserArray.count)")
            print("ITEM INDEX ARRAY: \(itemIndexToUserArray)")
            print(itemIndexToUser)
            var userTotal: [String: Double] = [String:Double]()
            var userToItems:[String:[String:Double]] = [String:[String:Double]]()
            for(itemIndex, user) in itemIndexToUser {
                //print(itemIndex)
                let itemName = tableContents.items[itemIndex].description
                if let itemPrice = itemToPriceMap[itemName] {
                    if userToItems[user] != nil {
                        userToItems[user]?[itemName] = itemPrice
                    } else {
                        userToItems[user] = [itemName:itemPrice]
                    }
                    userTotal[user] = (userTotal[user] ?? 0.0) + itemPrice
                }
                
            }
            
            // Text message call
            
            var userPhoneNumber = ""
            var item = ""
            var price = ""
            
            for (key, value) in userToItems {
                var messageBody = ""
                userPhoneNumber = reverseParticipantMap[key] ?? ""
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
                    "recieverName": User.current.name
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
            // Send the user a message too
            let data : [String: String] = [
                "phoneNumber": User.current.phoneNumber,
                "totalAmount": String(format: "", amounttoBePaid ?? "0"),
                "isEqual": "true",
                "isOwed" : "ture",
            ]
            // Send a message to the user for amount owed
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

var itemIndexToUser: [Int:String] = [Int:String]()
var itemIndexToUserArray:[String] = [String]()

//func updateSelectedUser(itemIndex: Int, user: String){
//    itemIndexToUser[itemIndex] = user
//    print(itemIndexToUser)
//    return
//}

func updateSelectedUser(user:String) {
    itemIndexToUserArray.append(user)
    return
}

func updateSelectedUser(itemIndex: Int, user: String) {
    itemIndexToUserArray[itemIndex] = user
    return
}

func getSelectedUsers() -> [Int:String] {
    return itemIndexToUser
}

func deleteSelectedUser(itemIndex: Int) {
    itemIndexToUserArray.remove(at: itemIndex)
    return
}

// MARK: Custom Receipt Class
class ReceiptTableCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var userPickerView: UIPickerView!
    @IBOutlet weak var itemText: UILabel!
    @IBOutlet weak var priceText: UILabel!
    var itemIndex: Int = 0
    var users: [String] = []
//    var participantMap: [String:String] =
    
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
        //updateSelectedUser(itemIndex: itemIndex, user: users[pickerRow])
        updateSelectedUser(itemIndex: itemIndex, user: users[pickerRow])
        return
    }
    
}

// MARK: Camera Scan Complete
extension CreateViewController {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        controller.dismiss(animated: true) {
            DispatchQueue.global(qos: .userInitiated).async {
                for pageNumber in 0 ..< scan.pageCount {
                    let image = scan.imageOfPage(at: pageNumber)
                    self.processImage(image: image)
                }
            }
        }
    }
}

// MARK: Receipt Data
extension CreateViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tableContents.items)
        return tableContents.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "receiptTable", for: indexPath) as? ReceiptTableCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptTable", for: indexPath)
    
        let field = tableContents.items[indexPath.row]
        cell1?.priceText.text = field.price
        cell1?.itemText.text = field.description
        cell1?.users = participants
        cell1?.itemIndex = indexPath.row

        print("\(field.description)\t\(field.price)")
        itemToPriceMap[field.description] = Double(field.price)
        cell1?.userPickerView.reloadAllComponents()
        
        return cell1 ?? cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                print("deleted \(tableContents.items[indexPath.row].description)")
                tableContents.items.remove(at: indexPath.row)
                itemIndexToUserArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
}

    
    // MARK: RecognizedTextDataSource
extension CreateViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        // Create a full transcript to run analysis on.
        var currLabel: String?
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            let isLarge = (observation.boundingBox.height > CreateViewController.textHeightThreshold)
            var text = candidate.string
            // The value might be preceded by a qualifier (e.g A small '3x' preceding 'Additional shot'.)
            var valueQualifier: VNRecognizedTextObservation?
            
            if isLarge {
                if let label = currLabel {
                    if let qualifier = valueQualifier {
                        if abs(qualifier.boundingBox.minY - observation.boundingBox.minY) < 0.01 {
                            // The qualifier's baseline is within 1% of the current observation's baseline, it must belong to the current value.
                            let qualifierCandidate = qualifier.topCandidates(1)[0]
                            text = qualifierCandidate.string + " " + text
                        }
                        valueQualifier = nil
                    }
                    tableContents.items.append((label, text))
                    print(tableContents.items)
                    
                    var itemRowNum:Int = 0
                    if tableContents.items.count != 0 {
                        itemRowNum = self.tableContents.items.count-1
                    } else {
                        itemRowNum = 0
                    }
                    
                    //updateSelectedUser(itemIndex: itemRowNum, user: self.participants[0])
                    updateSelectedUser(user: self.participants[0])
                    
                    currLabel = nil
                } else if tableContents.storeName == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
                    // Name is located on the top-left of the receipt.
                    tableContents.storeName = text
                }
            } else {
                if text.starts(with: "#") {
                    // Order number is the only thing that starts with #.
                    tableContents.items.append(("Order", text))
                    var itemRowNum:Int = 0
                    if tableContents.items.count != 0 {
                        itemRowNum = self.tableContents.items.count-1
                    } else {
                        itemRowNum = 0
                    }
                    
                    //updateSelectedUser(itemIndex: itemRowNum, user: self.participants[0])
                    updateSelectedUser(user: self.participants[0])
                } else if currLabel == nil {
                    currLabel = text
                } else {
                    do {
                        // Create an NSDataDetector to detect whether there is a date in the string.
                        let types: NSTextCheckingResult.CheckingType = [.date]
                        let detector = try NSDataDetector(types: types.rawValue)
                        let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                        if !matches.isEmpty {
                            tableContents.items.append(("Date", text))
                            
                            var itemRowNum:Int = 0
                            if tableContents.items.count != 0 {
                                itemRowNum = self.tableContents.items.count-1
                            } else {
                                itemRowNum = 0
                            }
                            
                            //updateSelectedUser(itemIndex: itemRowNum, user: self.participants[0])
                            updateSelectedUser(user: self.participants[0])
                        } else {
                            // This observation is potentially a qualifier.
                            valueQualifier = observation
                        }
                    } catch {
                        print(error)
                    }

                }
            }
        }
        itemTableView.reloadData()
    }
}


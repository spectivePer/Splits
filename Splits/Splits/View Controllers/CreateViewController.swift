/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller from which to invoke the document scanner.
*/

import UIKit
import VisionKit
import Vision

class CreateViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    // Variables from previous view
    var participants = [String]()
    var participantMap: [String:String] = [:]
    var splitName = String()
    var splitUid: String = ""

    @IBOutlet weak var pageSwitch: UISegmentedControl!
    
    // MARK: Equal Split View Variables
    
    @IBOutlet weak var splitNameLabel: UILabel!
    @IBOutlet weak var equalSplitAmount: UILabel!
    @IBOutlet weak var keyPad: UIStackView!
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
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
    struct ReceiptContents {

        var storeName: String?
        var items = [ReceiptContentField]()
    }
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("splitUid uid: ", splitUid)
        print("participantMap: ", participantMap)
        self.itemTableView.dataSource = self
        self.itemTableView.delegate = self
        
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
        plusButton.isEnabled = false
        plusButton.setTitleColor(.white, for: .normal)
        
        //initialize states
        tenthsPlace = false
        hundredthsPlace = false
        stopInput = false
        
        // Selecter Settings
        pageSwitch.setTitleTextAttributes([.foregroundColor : UIColor.systemOrange], for: .normal)
        pageSwitch.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        
    }
    
    // MARK: Selector
    
    @IBAction func switchedView(_ sender: Any) {
        switch pageSwitch.selectedSegmentIndex {
        case 1: //unequal split
            equalSplitAmount.isHidden = true
            keyPad.isHidden = true
            itemTableView.isHidden = false
            plusButton.isHidden = false
            plusButton.isEnabled = true
            plusButton.setTitleColor(.black, for: .normal)
        case 0: //equal split
            equalSplitAmount.isHidden = false
            keyPad.isHidden = false
            itemTableView.isHidden = true
            plusButton.isHidden = true
            plusButton.isEnabled = false
            plusButton.setTitleColor(.white, for: .normal)
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
    }
    
    // Back Button
    @IBAction func backButtonTapped(_ sender: Any) {
        displayViewController(storyboard: "Create", vcName: "addContactsVC")
    }
    
    // Add Item Button
    @IBAction func addButtonTapped(_ sender: Any) {
        tableContents.items.append(("Item", "Price"))
        itemTableView.reloadData()
        
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
        
        let numberOfParticipants = participants.count + 1
        
        //remove dollar sign in front of the string
        totalAmountString = String(totalAmountString.dropFirst())
        
        //convert total amount string to double
        let totalAmount = Double(totalAmountString) ?? 0.0
        
        //ERROR: Displays one decimal place for whole numbers. ie: $10.0 instead of $10.00
        let evenSplitAmount = round(totalAmount/Double(numberOfParticipants)*100)/100.0
        print("Participants pay $\(evenSplitAmount) each")
        
        // Creates a transaction for the split
        SplitService.createEqualSplit(totalAmount: totalAmount, evenSplitAmount: evenSplitAmount, splitUid: splitUid, recipient: User.current)
            
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
class ReceiptTableCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var userPickerView: UIPickerView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var detailText: UITextField!
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return users[row]
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

        return tableContents.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "receiptTable", for: indexPath) as? ReceiptTableCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptTable", for: indexPath)
        
        let field = tableContents.items[indexPath.row]
        cell1?.detailText.text = field.price
        cell1?.titleText.text = field.description
        cell1?.users = participants
        print("\(field.description)\t\(field.price)")
        cell1?.userPickerView.reloadAllComponents()
        return cell1 ?? cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                print("deleted \(tableContents.items[indexPath.row].description)")
                tableContents.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
}

extension CreateViewController: UITableViewDelegate {

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
                    
                    currLabel = nil
                } else if tableContents.storeName == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
                    // Name is located on the top-left of the receipt.
                    tableContents.storeName = text
                }
            } else {
                if text.starts(with: "#") {
                    // Order number is the only thing that starts with #.
                    tableContents.items.append(("Order", text))
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


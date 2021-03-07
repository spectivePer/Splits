/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller from which to invoke the document scanner.
*/

import UIKit
import VisionKit
import Vision

class CreateViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet weak var itemTableView: UITableView!
    let receiptContentsIdentifier = "receiptContentsTable"
    var textRecognitionRequest = VNRecognizeTextRequest()
    var tableContents = ReceiptContents()
    var participants = [String]()
    
    static let textHeightThreshold: CGFloat = 0.025 //differentiate big/small labels
    
    //Receipt information
    typealias ReceiptContentField = (price: String, description: String)
    struct ReceiptContents {

        var storeName: String?
        var items = [ReceiptContentField]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemTableView.dataSource = self
        self.itemTableView.delegate = self
        
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in

            if let results = request.results, !results.isEmpty {
                print("We have results!")
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    DispatchQueue.main.async {
                        self.addRecognizedText(recognizedText: requestResults)
                    }
                }
            }
        })
    }
    
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
    
    func displayViewController(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
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


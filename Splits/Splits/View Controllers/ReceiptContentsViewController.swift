/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Viewcontroller for scanned receipts.
*/

import UIKit
import Vision

class ReceiptContentsViewController: UITableViewController {

    static let tableCellIdentifier = "receiptTable"
    static let textHeightThreshold: CGFloat = 0.025 //differentiate big/small labels
    
    //Receipt information
    typealias ReceiptContentField = (price: String, description: String)
    struct ReceiptContents {

        var storeName: String?
        var items = [ReceiptContentField]()
    }
    
    var tableContents = ReceiptContents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isEditing = false
    }
    
    //@IBOutlet weak var receiptTable: UITableViewCell!
    @IBAction func editReceiptContents(_ sender: UIBarButtonItem) {
        if !self.isEditing {
            self.isEditing = true
        } else {
            self.isEditing = false
        }
    }
}

// MARK: UITableViewDataSource
extension ReceiptContentsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContents.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = tableContents.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptContentsViewController.tableCellIdentifier, for: indexPath)
        cell.textLabel?.text = field.price
        cell.detailTextLabel?.text = field.description
        print("\(field.description)\t\(field.price)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                print("deleted \(tableContents.items[indexPath.row].description)")
                tableContents.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
}
    
    // MARK: RecognizedTextDataSource
extension ReceiptContentsViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        // Create a full transcript to run analysis on.
        var currLabel: String?
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            let isLarge = (observation.boundingBox.height > ReceiptContentsViewController.textHeightThreshold)
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
        tableView.reloadData()
        navigationItem.title = tableContents.storeName != nil ? tableContents.storeName : "Scanned Receipt"
    }
}

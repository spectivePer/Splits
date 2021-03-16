/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller from which to invoke the document scanner.
*/

import UIKit
import VisionKit
import Vision
import FirebaseFunctions

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
        cell1?.priceText.text = field.price
        cell1?.itemText.text = field.description
        cell1?.users = participants
        cell1?.itemIndex = indexPath.row

        print("cell: \(field.description)\t\(field.price)")
        itemToPriceMap[field.description] = Double(field.price)
        cell1?.userPickerView.reloadAllComponents()
        
        return cell1 ?? cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                print("deleted \(tableContents.items[indexPath.row].description)")
                itemIndexToUserArray.remove(at: indexPath.row)
                print(itemIndexToUserArray)
                tableContents.items.remove(at: indexPath.row)
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
                    print("append \(tableContents.items)")
                    updateSelectedUser(user: self.participants[0])
                    print(itemIndexToUserArray)
                    
                    currLabel = nil
                } else if tableContents.storeName == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
                    // Name is located on the top-left of the receipt.
                    tableContents.storeName = text
                }
            } else {
                if text.starts(with: "#") {
                    // Order number is the only thing that starts with #.
                    tableContents.items.append(("Order", text))
                    updateSelectedUser(user: self.participants[0])
                    print(itemIndexToUserArray)
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


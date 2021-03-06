//
//  UnevenSplitViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

/*
import Foundation
import UIKit
import VisionKit
import Vision

class UnevenSplitViewController: UIViewController {
    //Receipt characteristics
    struct items {
        //var participant: String
        var description: String
        var price: String
    }
    
    var receiptItemArray:[items] = []
    
    @IBOutlet weak var receiptTable: UITableView!
    
    //OCR variable
    var textRecognitionRequest = VNRecognizeTextRequest()
    static let textHeightThreshold: CGFloat = 0.025
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
    }
    
    // MARK: -ACTION
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        displayViewController(storyboard: "newSplit", vcName: "addItemView")
    }
    
    @IBAction func previousView(_ sender: Any) {
        displayViewController(storyboard: "newSplit", vcName: "addContactsView")
    }
    
    // MARK: -DISPLAY
    func displayViewController(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}

extension UnevenSplitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(receiptItemArray)
        return receiptItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = receiptItemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptContentsTable", for: indexPath)
        cell.textLabel?.text = item.description
        cell.detailTextLabel?.text = item.price
        return cell
    }
}

//MARK: -SCAN RECEIPT
extension UnevenSplitViewController {
    @IBAction func scanReceipt(_ sender: Any) {
        let textRecognitionRequest = VNRecognizeTextRequest()

        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
            
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
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
}
    
extension UnevenSplitViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        let resultsViewController = storyboard?.instantiateViewController(withIdentifier: "unevenSplitView") as? (UIViewController & RecognizedTextDataSource)
        
        controller.dismiss(animated: true) {
            DispatchQueue.global(qos: .userInitiated).async {
                for pageNumber in 0 ..< scan.pageCount {
                    let image = scan.imageOfPage(at: pageNumber)
                    self.processImage(image: image)
                }
                DispatchQueue.main.async {
                    if let resultsVC = resultsViewController {
                        self.navigationController?.pushViewController(resultsVC, animated: true)
                    }
                }
            }
        }
    }
}

// MARK: -IMPORT RECEIPT CONTENTS
extension UnevenSplitViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
                // Create a full transcript to run analysis on.
                var currLabel: String?
                let maximumCandidates = 1
                for observation in recognizedText {
                    guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    let isLarge = (observation.boundingBox.height > UnevenSplitViewController.textHeightThreshold)
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
                            receiptItemArray.append(items(description: label, price: text))
                            currLabel = nil
                    } else {
                        if text.starts(with: "#") {
                            // Order number is the only thing that starts with #.
                            receiptItemArray.append(items(description: "Order", price: text))
                        } else if currLabel == nil {
                            currLabel = text
                        } else {
                            do {
                                // Create an NSDataDetector to detect whether there is a date in the string.
                                let types: NSTextCheckingResult.CheckingType = [.date]
                                let detector = try NSDataDetector(types: types.rawValue)
                                let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                                if !matches.isEmpty {
                                    receiptItemArray.append(items(description: "Date", price: text))
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
                
                receiptTable.reloadData()
            }
        }
}
*/

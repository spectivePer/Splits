/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller from which to invoke the document scanner.
*/

import UIKit
import VisionKit
import Vision

class UnevenSplitViewController: UIViewController, UITableViewDataSource {
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let businessCardContentsIdentifier = "businessCardContentsVC"
    static let receiptContentsIdentifier = "unevenSplitView"
    static let otherContentsIdentifier = "otherContentsVC"

    enum ScanMode: Int {
        case receipts
        case businessCards
        case other
    }
    
    var scanMode: ScanMode = .receipts
    var resultsViewController: (UIViewController & RecognizedTextDataSource)?
    var textRecognitionRequest = VNRecognizeTextRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            guard let resultsViewController = self.resultsViewController else {
                print("resultsViewController is not set")
                return
            }
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    DispatchQueue.main.async {
                        resultsViewController.addRecognizedText(recognizedText: requestResults)
                    }
                }
            }
        })
        // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
        
        receiptTable.dataSource = self
    }

    @IBAction func scan(_ sender: Any) {
        guard let scanMode = ScanMode(rawValue: (sender as AnyObject).tag) else { return }
        self.scanMode = scanMode
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
    
    
    
    
    //import
    @IBOutlet weak var receiptTable: UITableView!
    static let tableCellIdentifier = "receiptContentCell"

    // Use this height value to differentiate between big labels and small labels in a receipt.
    static let textHeightThreshold: CGFloat = 0.025
    
    typealias ReceiptContentField = (name: String, value: String)

    // The information to fetch from a scanned receipt.
    struct ReceiptContents {

        var name: String?
        var items = [ReceiptContentField]()
    }
    
    var contents = ReceiptContents()
}



extension UnevenSplitViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let vcID: String? = UnevenSplitViewController.receiptContentsIdentifier
        
        if let vcID = vcID {
            resultsViewController = storyboard?.instantiateViewController(withIdentifier: vcID) as? (UIViewController & RecognizedTextDataSource)
        }
        
        //self.activityIndicator.startAnimating()
        controller.dismiss(animated: true) {
            DispatchQueue.global(qos: .userInitiated).async {
                for pageNumber in 0 ..< scan.pageCount {
                    let image = scan.imageOfPage(at: pageNumber)
                    self.processImage(image: image)
                }
                DispatchQueue.main.async {
                    if let resultsVC = self.resultsViewController {
                        self.navigationController?.pushViewController(resultsVC, animated: true)
                    }
                    //self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

//import

extension UnevenSplitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = contents.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UnevenSplitViewController.tableCellIdentifier, for: indexPath)
        cell.textLabel?.text = field.name
        cell.detailTextLabel?.text = field.value
        print("\(field.name)\t\(field.value)")
        return cell
    }
}
    
    // MARK: RecognizedTextDataSource
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
                    contents.items.append((label, text))
                    currLabel = nil
                } else if contents.name == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
                    // Name is located on the top-left of the receipt.
                    contents.name = text
                }
            } else {
                if text.starts(with: "#") {
                    // Order number is the only thing that starts with #.
                    contents.items.append(("Order", text))
                } else if currLabel == nil {
                    currLabel = text
                } else {
                    do {
                        // Create an NSDataDetector to detect whether there is a date in the string.
                        let types: NSTextCheckingResult.CheckingType = [.date]
                        let detector = try NSDataDetector(types: types.rawValue)
                        let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                        if !matches.isEmpty {
                            contents.items.append(("Date", text))
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
        guard let table = receiptTable else {
            return
        }
        table.reloadData()
        navigationItem.title = contents.name != nil ? contents.name : "Scanned Receipt"
    }
}

//
//  UnevenSplitViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit
import VisionKit
import Vision

class UnevenSplitViewController: UIViewController {
    //Receipt characteristics
    struct items {
        var participant: String
        var description: String
        var price: String
    }
    
    var receiptItemArray:[items] = []
    @IBOutlet weak var receiptTable: UITableView!
    
    //OCR variable
    var textRecognitionRequest = VNRecognizeTextRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

extension UnevenSplitViewController: VNDocumentCameraViewControllerDelegate {
    @IBAction func scanReceipt(_ sender: Any) {
        let textRecognitionRequest = VNRecognizeTextRequest()

        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
            
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
}

//
//  ScanReceiptViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 3/2/21.
//


import Foundation
import UIKit
import VisionKit
import Vision

class ScanReceiptViewController: UIViewController, VNDocumentCameraViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var textRecognitionRequest = VNRecognizeTextRequest()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
            super.viewDidLoad()

            imagePicker.delegate = self

            // Accurate OCR recognition
            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.usesLanguageCorrection = true
        
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
        }

    // MARK: -Action
    /*
    @IBAction func importFromGallery(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    } */
    
    // MARK: - Display Methods
    func displayView(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    
}

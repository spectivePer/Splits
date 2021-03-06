//
//  RecognizedTextDataSource.swift
//  Splits
//
//  Created by Jocelyn Park on 3/3/21.
//
// Abstract:
// The protocol that a class must conform to in order to receive recognized text information.

import UIKit
import Vision

protocol RecognizedTextDataSource: AnyObject {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
}

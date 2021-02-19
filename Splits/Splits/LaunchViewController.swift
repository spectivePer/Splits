//
//  LaunchViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setGradient()
    
    }
    
    func setGradient() {
        // Set up Gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [ #colorLiteral(red: 0.9504643083, green: 0.69449687, blue: 0.4051229954, alpha: 1).cgColor, #colorLiteral(red: 0.9473264813, green: 0.4891940951, blue: 0, alpha: 1).cgColor]
        // Rasterize this static layer to improve app performance.
        gradientLayer.shouldRasterize = true
        // Apply the gradient to the backgroundGradientView.
        gradientView.layer.addSublayer(gradientLayer)
    }

}

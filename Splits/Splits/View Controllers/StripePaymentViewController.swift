//
//  StripePaymentViewController.swift
//  Splits
//
//  Created by Shaumik Pathak on 2/28/21.
//

import UIKit
import Stripe

class StripePaymentViewController: UIViewController {
    
    
    // Variables
    
    var paymentContext: STPPaymentContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setUpStripeConfig(){
        
        let config = STPPaymentConfiguration.shared
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = []
        
        let customerContext = STPCustomerContext(keyProvider: stripeApi)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .defaultTheme)
        
        paymentContext.paymentAmount = 100
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        
    }

}

extension StripePaymentViewController: STPPaymentContextDelegate {
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    
}

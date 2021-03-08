//  StripePaymentViewController.swift
//  Splits
//
//  Created by Shaumik Pathak on 2/28/21.
//

import UIKit
import Stripe
import FirebaseFunctions

class StripePayViewController: UIViewController {

    // Variables
    
    @IBOutlet weak var paymentMethodBtn: UIButton!
    
    var paymentContext: STPPaymentContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpStripeConfig()
//        let cloudFunctions = _cloudFunctions()
        // Do any additional setup after loading the view.
    }

    func setUpStripeConfig(){

        let config = STPPaymentConfiguration.shared
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = []

        let customerContext = STPCustomerContext(keyProvider: stripeApi)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .defaultTheme)

        // Change this according to split amount

        paymentContext.paymentAmount = 100
        paymentContext.delegate = self
        paymentContext.hostViewController = self

    }
    @IBAction func paymentClicked(_ sender: Any) {
        paymentContext.requestPayment()
//      activityIndicator.startAnimating()
        
    }


    @IBAction func selectPaymentMethod(_ sender: Any) {
//        paymentContext.pushPaymentOptionsViewController()
        // handle new user
        let storyboard = UIStoryboard(name: "Create", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CKViewController")
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }


}


extension StripePayViewController: STPPaymentContextDelegate {


    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {

        // Updating the selected payment method
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodBtn.setTitle(paymentMethod.label, for: .normal)
        } else{
            paymentMethodBtn.setTitle("Select Payment Method", for:.normal)
        }

    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {

//        let alertController = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert)
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
//            self.navigationController?.popViewController(animated: true)
//        }
//        let retry = UIAlertAction(title: "Retry", style: .default) { (action) in
//            self.paymentContext.retryLoading()
//        }
//
//        alertController.addAction(cancel)
//        alertController.addAction(retry)
//
//        present(alertController, animated: true, completion: nil)

    }

    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {

        let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")

        let data : [String: Any] = [
            "total": 100,
            // change this later
            "customerId": "cus_J2S3peBo7dsXeA",
            // change to stripeId
            "idempotency": idempotency
        ]

        Functions.functions().httpsCallable("createCharge").call(data) { (result, error) in

            if let error = error {
                print(error.localizedDescription)
                // send alert - unable to make charge
//               completion(STPPaymentStatus, error)
                return
            }
            // made payment here!
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        let title : String
        let message : String

        switch status {
        case .error:
            //UIActivityIndicatorView
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            //UIActivityIndicatorView
            title = "sucess"
            message = " Thank you for your purchase"
        case .userCancellation:
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true) }

            alertController.addAction(action)

            self.present(alertController, animated: true, completion: nil)
        }

}
    

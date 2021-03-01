//
//  stripeApi.swift
//  Splits
//
//  Created by Shaumik Pathak on 2/28/21.
//

import Foundation
import Stripe
import FirebaseFunctions


class _stripeApi: NSObject, STPCustomerEphemeralKeyProvider{
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let data = [
            "stripe_version": apiVersion
        ]
        
        Functions.functions().httpsCallable("createEphemeralKey").call(<#T##data: Any?##Any?#>, completion: <#T##(HTTPSCallableResult?, Error?) -> Void#>)
    }
    
    
    
    
}

//
//  stripeApi.swift
//  Splits
//
//  Created by Shaumik Pathak on 2/28/21.
//

import Foundation
import Stripe
import FirebaseFunctions

let stripeApi = _stripeApi()

final class _stripeApi: NSObject, STPCustomerEphemeralKeyProvider{
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {

        let data = [
            "stripe_version": apiVersion,
            "customer_id": "cus_J2S3peBo7dsXeA"
        ]

        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in

            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            guard let key = result?.data as? [String: Any] else{
                completion(nil, nil)
                return
            }

            completion(key, nil)
        }
    }
}

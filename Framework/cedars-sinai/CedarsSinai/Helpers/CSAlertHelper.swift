//
//  CSAlertHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/2/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation
import UIKit

struct CSAlertHelper {
    public static func showAlertError(errorMessage: String) -> UIAlertController {
        let alertError = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let confirmationAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertError.addAction(confirmationAction)
        return alertError
    }
}

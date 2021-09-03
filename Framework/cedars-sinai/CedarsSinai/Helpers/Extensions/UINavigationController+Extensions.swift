//
//  UINavigationController+Extensions.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/28/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

extension UINavigationController {
    func popViewControllerAnimatedWithCompletion(_ completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }
}

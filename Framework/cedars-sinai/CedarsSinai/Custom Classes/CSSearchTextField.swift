//
//  CSSearchTextField.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/23/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class CSSearchTextField: UITextField {

    @IBInspectable var borderWidth: CGFloat = 1.5 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 7 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.csLightBlue {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpStyles()
    }
    
    private func setUpStyles() {
        tintColor = .csGrayText
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

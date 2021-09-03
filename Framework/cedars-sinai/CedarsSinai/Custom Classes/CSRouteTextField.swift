//
//  CSRouteTextField.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/28/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class CSRouteTextField: UITextField {
    //Variables separated in case the app is translated
    let startText = "  " + "Start" + ":"
    let endText = "  " + "End" + ":"
    let highlightedColor = UIColor.csRed
    let defaultColor = UIColor.csLightBlue
    
    @IBInspectable var isEndingPoint: Bool = false {
        didSet {
            setLeftTextLabel()
        }
    }

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

    @IBInspectable var highlightedBorderColor: UIColor = UIColor.lightGray

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpStyles()
    }
    
    private func setUpStyles() {
        tintColor = highlightedColor
        
        setLeftTextLabel()
        setDefaultBorder()
    }
    
    private func setLeftTextLabel() {
        let systemFontSemiBold = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        let stringToUse = isEndingPoint ? endText : startText
        let labelSize = stringToUse.size(withAttributes: [NSAttributedString.Key.font: systemFontSemiBold as Any])
        let locationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelSize.width, height: frame.height))
        locationLabel.font = systemFontSemiBold
        locationLabel.textColor = highlightedColor
        locationLabel.text = isEndingPoint ? endText : startText
        
        leftView = locationLabel
        leftViewMode = .always
    }
    
    public func setHighlightedBorder() {
        layer.borderWidth = 1.5
        layer.borderColor = highlightedBorderColor.cgColor
    }
    
    public func setDefaultBorder() {
        layer.borderWidth = 1.5
        layer.borderColor = defaultColor.cgColor
    }
}

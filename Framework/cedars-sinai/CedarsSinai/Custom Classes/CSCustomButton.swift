//
//  CSCustomButton.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/28/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSCustomButton: UIButton {
    
    //MARK: - IBInspectables
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor = .white

    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
    @IBInspectable
    var buttonBackgroundColor: UIColor = .clear {
        didSet {
            backgroundColor = buttonBackgroundColor
        }
    }
    
    @IBInspectable
    var useRoundedCorners: Bool = false
    
    @IBInspectable
    var useHighlightedState: Bool = false
    
    @IBInspectable
    var normalTextColor: UIColor = .black
    
    @IBInspectable
    var highlightedBackgroundColor: UIColor = .clear
    
    @IBInspectable
    var highlightedTextColor: UIColor = .black
    
    //MARK: - Functionality Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byClipping
        titleLabel?.textColor = normalTextColor
        
        layer.borderWidth = borderWidth
        if useRoundedCorners {
            layer.cornerRadius = frame.height / 2
        } else {
            layer.cornerRadius = cornerRadius
        }
        
        if useHighlightedState {
            setHighlightedState()
        } else {
            setDefaultState()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if useRoundedCorners {
            layer.cornerRadius = frame.height / 2
        } else {
            layer.cornerRadius = cornerRadius
        }
    }
    
    public func setDefaultState() {
        layer.borderColor = borderColor.cgColor
        backgroundColor = buttonBackgroundColor
        setTitleColor(normalTextColor, for: .normal)
    }
    
    public func setHighlightedState() {
        layer.borderColor = borderColor.cgColor
        backgroundColor = highlightedBackgroundColor
        setTitleColor(highlightedTextColor, for: .normal)
    }
}

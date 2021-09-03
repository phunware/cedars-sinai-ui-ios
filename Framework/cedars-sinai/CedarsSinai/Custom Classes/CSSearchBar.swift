//
//  CSSearchBar.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/21/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSSearchBar: UISearchBar {
    
    private let imageBarSize = CGSize(width: 30, height: 30)
    private let bezierPathRect = CGRect(x: 1.5, y: 1.5, width: 27, height: 27)

    public func setUpAppearance() {
        isTranslucent = false
        backgroundColor = .white
        setSearchFieldBackgroundImage(createSearchBarImage(), for: .normal)
        tintColor = .csGrayText
        searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
        
        customizeTextField()
    }
    
    private func customizeTextField() {
        for subview in self.subviews {
            for secondSubView in subview.subviews {
                if let searchField = secondSubView as? UITextField {
                    searchField.leftViewMode = .never
                    searchField.textColor = .csGrayText
                    break
                }
            }
        }
    }
    
    private func createSearchBarImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageBarSize, false, UIScreen.main.scale)
        
        let imagePath = UIBezierPath(roundedRect: bezierPathRect, cornerRadius: 2.5)
        imagePath.lineWidth = 3
        
        UIColor.white.setFill()
        UIColor.csLightBlue.setStroke()
        
        imagePath.stroke()
        imagePath.addClip()
        
        UIRectFill(CGRect(x: 0, y: 0, width: imageBarSize.width, height: imageBarSize.width))
        let searchBarImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return searchBarImage
    }
}

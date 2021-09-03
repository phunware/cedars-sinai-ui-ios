//
//  UIView+extensions.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/19/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

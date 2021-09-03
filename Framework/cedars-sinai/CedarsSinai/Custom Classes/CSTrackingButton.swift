//
//  CSTrackingButton.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/10/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit

class CSTrackingButton: UIButton {
    
    public var mapTrackingMode: PWTrackingMode = .none {
        didSet {
            setUpTrackingMode()
        }
    }
    
    convenience init(mapTrackingMode: PWTrackingMode) {
        self.init()
        self.mapTrackingMode = mapTrackingMode
    }
}

// MARK:- Functionality Methods
// CSTrackingButton will only switch between followWithHeading and None
extension CSTrackingButton {
    public func changeTrackingMode() {
        switch mapTrackingMode {
        case .none:
            mapTrackingMode = .followWithHeading
        case .follow:
            mapTrackingMode = .none
        case .followWithHeading:
            mapTrackingMode = .none
        }
    }
    
    fileprivate func setUpTrackingMode() {
        if mapTrackingMode == .followWithHeading {
            let image = UIImage(named: "ios_icon_heading", in: CSBundleHelper.bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            isSelected = true
        } else if mapTrackingMode == .follow {
            let image = UIImage(named: "ios_icon_follow", in: CSBundleHelper.bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            isSelected = true
        } else {
            let image = UIImage(named: "ios_icon_navigation", in: CSBundleHelper.bundle, compatibleWith: nil)
            setImage(image, for: .normal)
            isSelected = false
        }
    }
}

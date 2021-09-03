//
//  CSPOIBannerImageView.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/12/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSPOIBannerImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = CGFloat(7)
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }
}

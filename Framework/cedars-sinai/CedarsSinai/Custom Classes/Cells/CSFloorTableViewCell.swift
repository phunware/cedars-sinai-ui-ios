//
//  CSFloorTableViewCell.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/19/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSFloorTableViewCell: UITableViewCell {

    @IBOutlet weak var floorNumberLabel: UILabel!

    @IBInspectable var selectedColor: UIColor = .white
    @IBInspectable var selectedBackgroundColor: UIColor = .blue {
        didSet {
            selectedBackgroundView?.backgroundColor = selectedBackgroundColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSelectionView()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSelectionView()
    }

    private func setupSelectionView() {
        selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        floorNumberLabel.textColor = selected ? selectedColor : .lightGray
    }

}

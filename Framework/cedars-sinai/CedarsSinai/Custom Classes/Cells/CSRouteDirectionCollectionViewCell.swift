//
//  CSRouteDirectionCollectionViewCell.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/4/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit

class CSRouteDirectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainInstructionImageView: UIImageView!
    @IBOutlet weak var mainInstructionLabel: UILabel!

    private var instructionViewModel: RoutingInstructionViewModel?

    var routeInstruction: PWRouteInstruction? {
        didSet {
            guard let routeInstruction = routeInstruction else {
                return
            }
            
            instructionViewModel = RoutingInstructionViewModel(with: routeInstruction)
            updateInstructionTitle()
            updateInstructionImage()
        }
    }
    
    private func updateInstructionTitle() {
        guard let instructionViewModel = instructionViewModel else {
            return
        }
        
        mainInstructionLabel.text = instructionViewModel.titleText?.string
    }
    
    private func updateInstructionImage() {
        guard let instructionViewModel = instructionViewModel else {
            return
        }
        if let image = instructionViewModel.directionImage {
            mainInstructionImageView.image = image
        } else if let url = instructionViewModel.lastInstructionURL {
            mainInstructionImageView.kf.setImage(with: url)
        }
    }
}

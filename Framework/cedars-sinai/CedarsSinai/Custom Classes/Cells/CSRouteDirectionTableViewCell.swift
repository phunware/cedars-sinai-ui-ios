//
//  CSRouteDirectionTableViewCell.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/4/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit

class CSRouteDirectionTableViewCell: UITableViewCell {

    @IBOutlet weak var routeActionImageView: UIImageView!
    @IBOutlet weak var mainDirectionLabel: UILabel!
    
    private var instructionViewModel: RoutingInstructionViewModel?
    
    var routeInstruction: PWRouteInstruction? {
        didSet {
            guard let routeInstruction = routeInstruction else {
                return
            }
            
            instructionViewModel = RoutingInstructionViewModel(with: routeInstruction)
            updateMainDirectionLabel()
            updateRouteActionImageView()
        }
    }
    
    private func updateMainDirectionLabel() {
        guard let instructionViewModel = instructionViewModel else {
            return
        }
        
        mainDirectionLabel.text = instructionViewModel.titleText?.string
    }
    
    private func updateRouteActionImageView() {
        guard let instructionViewModel = instructionViewModel else {
            return
        }
        if let image = instructionViewModel.directionImage {
            routeActionImageView.image = image
        } else if let url = instructionViewModel.lastInstructionURL {
            routeActionImageView.kf.setImage(with: url)
        }
    }
}

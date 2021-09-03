//
//  CSRoutingHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/19/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

struct CSRoutingHelper {
    public static func getImageFromInstruction(_ instruction: PWRouteInstructionDirection) -> String {
        switch instruction {
        case .straight:
            return "ic_straight"
        case .stairsUp:
            return "ic_stairup"
        case .stairsDown:
            return "ic_stairdown"
        case .bearLeft:
            return "ic_slightleft"
        case .bearRight:
            return "ic_slightright"
        case .left:
            return "ic_sharpleft"
        case .right:
            return "ic_sharpright"
        case .elevatorUp:
            return "ic_elevatorup"
        case .elevatorDown:
            return "ic_elevatordown"
        case .floorChange:
            //Default images
            return "ic_straight"
        case .escalatorUp:
            return "ic_stairup"
        case .escalatorDown:
            return "ic_stairdown"
        }
    }
}

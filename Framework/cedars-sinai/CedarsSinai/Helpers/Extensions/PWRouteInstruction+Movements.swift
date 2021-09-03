//
//  PWRouteInstruction+Movements.swift
//  CedarsSinai
//
//  Created by tomas on 5/9/18.
//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

extension PWRouteInstructionDirection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .straight:
            return "PWRouteInstructionDirectionStraight"
        case .bearLeft:
            return "PWRouteInstructionDirectionBearLeft"
        case .bearRight:
            return "PWRouteInstructionDirectionBearRight"
        case .left:
            return "PWRouteInstructionDirectionLeft"
        case .right:
            return "PWRouteInstructionDirectionRight"
        case .elevatorUp:
            return "PWRouteInstructionDirectionElevatorUp"
        case .elevatorDown:
            return "PWRouteInstructionDirectionElevatorDown"
        default:
            return "\(rawValue)"
        }
    }
}

extension PWRouteInstruction {

    internal func movementString() -> String {
        return CSMapModule.localizedString(movementDirection.description) ?? ""
    }

    internal func turnString() -> String {
        return CSMapModule.localizedString(turnDirection.description) ?? ""
    }

    internal func movement(with distance: Double) -> String {
        let movement = movementString()

        let feet = String(format: "%.0f feet", distance*3.28)

        return String(format: movement, feet)
    }

    internal func movement(from originPOI: PWPointOfInterest?, to destinationPOI: PWPointOfInterest?) -> String? {

        switch movementDirection {
        case .elevatorUp, .elevatorDown:
            break
        default:
            return movement
        }

        let originTitle = originPOI?.metadataSubtitle ?? originPOI?.title ?? ""
        let destinationTitle = destinationPOI?.metadataSubtitle  ?? destinationPOI?.title ?? ""

        let mString = movementString()
        return String(format: mString, originTitle, destinationTitle)
    }

    internal func turn(from originPOI: PWPointOfInterest?, to destinationPOI: PWPointOfInterest?) -> String? {
        switch turnDirection {
        case .elevatorUp, .elevatorDown:
            break
        default:
            return turn
        }

        let originTitle = originPOI?.metadataSubtitle ?? originPOI?.title ?? ""
        let destinationTitle = destinationPOI?.metadataSubtitle  ?? destinationPOI?.title ?? ""

        let mString = turnString()
        return String(format: mString, originTitle, destinationTitle)
    }
    
    internal func isOnFloorChange() -> Bool {
        switch direction {
        case .floorChange, .elevatorUp, .elevatorDown, .escalatorUp, .escalatorDown, .stairsUp, .stairsDown:
            return true
        default:
            return false
        }
    }
}

//
//  InstructionViewModel.swift
//  CedarsSinai
//
//  Created by John Zhao on 2/3/20.
//  Copyright © 2020 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

protocol InstructionViewModel {
    var instruction: Instruction { get }
    var directionImage: UIImage? { get }
    var lastInstructionURL: URL? { get }
    var titleText: NSAttributedString? { get }
    var standardOptions: InstructionTextOptions { get }
    var highlightOptions: InstructionTextOptions { get }
}

// Default Implement
extension InstructionViewModel {
    
    var directionImage: UIImage? {
        guard !instruction.isLast else {
            return nil
        }
        
        return .image(for: instruction)
    }
    
    var lastInstructionURL: URL? {
        guard let endPoint = instruction.endPoint else {
            return nil
        }
        
        return endPoint.imageURL
    }
    
    var titleText: NSAttributedString? {
        
        let straightString = NSLocalizedString("Continue straight", comment: "")
        let attributed: NSMutableAttributedString
        switch instruction.instructionType {
        case .straight:
            if let landmark = instruction.routeInstruction.landmarks?.last {
                let templateString = NSLocalizedString("$0 for $1 towards $2", comment: "$0 = Continue straight, $1 = distance, $2 = landmark")
                attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                
                attributed.replace(substring: "$0", with: straightString, attributes: highlightOptions.attributes)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
                attributed.replace(substring: "$2", with: landmark.name, attributes: highlightOptions.attributes)
            } else {
                let templateString = NSLocalizedString("$0 for $1", comment: "$0 = Continue straight, $1 = distance")
                attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                
                attributed.replace(substring: "$0", with: straightString, attributes: highlightOptions.attributes)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
            }
            
        case .turn(let direction):
            if let landmark = instruction.routeInstruction.landmarks?.last {
                let templateString = NSLocalizedString("$0 in $1 $2 $3", comment: "$0 = direction, $1 = distance, $2 = at/after, $3 = landmark name")
                
                attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                
                let turnString = string(forTurn: direction) ?? ""
                attributed.replace(substring: "$0", with: turnString, attributes: highlightOptions.attributes)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
                
                let positionString = (landmark.position == .at)
                    ? NSLocalizedString("at", comment: "")
                    : NSLocalizedString("after", comment: "")
                
                attributed.replace(substring: "$2", with: positionString, attributes: standardOptions.attributes)
                attributed.replace(substring: "$3", with: landmark.name, attributes: highlightOptions.attributes)
            } else {
                let templateString = NSLocalizedString("$0 in $1", comment: "$0 = direction, $1 = distance")
                attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
                
                let turnString = string(forTurn: direction) ?? ""
                attributed.replace(substring: "$0", with: turnString, attributes: highlightOptions.attributes)
                
                let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
                attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
            }
            
        case .upcomingFloorChange(let floorChange):
            let templateString = NSLocalizedString("$0 $1 towards $2 to $3", comment: "$0 = Continue straight, $1 = distance, $2 floor change type, $3 = floor name")
            attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
            
            attributed.replace(substring: "$0", with: straightString, attributes: highlightOptions.attributes)
            
            let distanceString = instruction.routeInstruction.distance.localizedDistanceInSmallUnits
            attributed.replace(substring: "$1", with: distanceString, attributes: standardOptions.attributes)
            
            let floorChangeTypeString = string(for: floorChange.floorChangeType)
            attributed.replace(substring: "$2", with: floorChangeTypeString, attributes: highlightOptions.attributes)
            attributed.replace(substring: "$3", with: floorChange.floorName, attributes: highlightOptions.attributes)
            
        case .floorChange(let floorChange):
            let templateString = (floorChange.floorChangeDirection == .sameFloor)
                ? NSLocalizedString("Take the $0 to $2", comment: "$0 = floor change type, $2 = floor name")
                : NSLocalizedString("Take the $0 $1 to $2", comment: "$0 = floor change type, $1 = floor change direction, $2 = floor name")
            
            attributed = NSMutableAttributedString(string: templateString, attributes: standardOptions.attributes)
            
            let floorChangeTypeString = string(for: floorChange.floorChangeType)
            attributed.replace(substring: "$0", with: floorChangeTypeString, attributes: highlightOptions.attributes)
            
            let directionString = string(forFloorChangeDirection: floorChange.floorChangeDirection) ?? ""
            attributed.replace(substring: "$1", with: directionString, attributes: standardOptions.attributes)
            attributed.replace(substring: "$2", with: floorChange.floorName, attributes: highlightOptions.attributes)
        }
        
        if instruction.isLast {
            let arrivalDistance = NSMutableAttributedString(string: " to arrive at \(instruction.endPoint?.title ?? "")", attributes: standardOptions.attributes)
            attributed.append(arrivalDistance)
        }
        
        return attributed
    }
    
    var standardOptions: InstructionTextOptions {
        return InstructionTextOptions.defaultStandardOptions
    }
    
    var highlightOptions: InstructionTextOptions {
        return InstructionTextOptions.defaultHighlightOptions
    }
}

extension InstructionViewModel {
    
    func string(for floorChangeType: Instruction.FloorChangeType) -> String {
        switch floorChangeType {
        case .stairs:
            return NSLocalizedString("stairs", comment: "")
        case .escalator:
            return  NSLocalizedString("escalator", comment: "")
        case .elevator:
            return  NSLocalizedString("elevator", comment: "")
        case .other:
            return  NSLocalizedString("floor change", comment: "")
        }
    }
    
    func string(forTurn direction: PWRouteInstructionDirection) -> String? {
        switch direction {
        case .left:
            return NSLocalizedString("Turn left", comment: "")
        case .right:
            return NSLocalizedString("Turn right", comment: "")
        case .bearLeft:
            return NSLocalizedString("Bear left", comment: "")
        case .bearRight:
            return NSLocalizedString("Bear right", comment: "")
        default:
            return nil
        }
    }
    
    func string(forFloorChangeDirection direction: Instruction.FloorChangeDirection) -> String? {
        switch direction {
        case .up:
            return NSLocalizedString("up", comment: "")
        case .down:
            return NSLocalizedString("down", comment: "")
        case .sameFloor:
            return nil
        }
    }
}

struct RoutingInstructionViewModel: InstructionViewModel {
    private let currentInstruction: Instruction
    
    init(with routeInstruction: PWRouteInstruction ) {
        self.currentInstruction = Instruction(for: routeInstruction)
    }
    
    var instruction: Instruction {
        return currentInstruction
    }
}

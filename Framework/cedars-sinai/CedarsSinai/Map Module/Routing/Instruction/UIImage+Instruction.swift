//
//  UIImage+Instruction.swift
//  CedarsSinai
//
//  Created by John Zhao on 2/3/20.
//  Copyright © 2020 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

extension UIImage {
    static func image(for instruction: Instruction) -> UIImage {
        switch instruction.instructionType {
        case .straight, .upcomingFloorChange:
            return UIImage(named:"ic_straight_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            
        case .turn(let direction):
            switch direction {
            case .left:
                return UIImage(named:"ic_sharpleft_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case .right:
                return UIImage(named:"ic_sharpright_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case .bearLeft:
                return UIImage(named:"ic_slightleft_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case .bearRight:
                return UIImage(named:"ic_slightright_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            default:
                return UIImage(named:"ic_straight_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            }
            
        case .floorChange(let floorChange):
            switch (floorChange.floorChangeType, floorChange.floorChangeDirection) {
            case (.stairs, .up):
                return UIImage(named:"ic_stairup_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case (.stairs, .down):
                return UIImage(named:"ic_stairdown_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case (.elevator, .up):
                return UIImage(named:"ic_elevatorup_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case (.elevator, .down):
                return UIImage(named:"ic_elevatordown_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case (.escalator, .up):
                return UIImage(named:"ic_stairup_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            case (.escalator, .down):
                return UIImage(named:"ic_stairdown_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            default:
                return UIImage(named:"ic_straight_large", in: CSBundleHelper.bundle, compatibleWith: nil)!
            }
        }
    }
}

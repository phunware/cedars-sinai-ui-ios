//
//  CSMapTrackingModeHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/10/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

// We are supporting only 2 Tracking mode in this framework (followWithHeading and none)
struct CSMapTrackingModeHelper {
    public static func getMapViewTrackingState(currentState: PWTrackingMode) -> PWTrackingMode {
        switch currentState {
        case .none:
            return .followWithHeading
        case .follow:
            return .none
        case .followWithHeading:
            return .none
        }
    }
}

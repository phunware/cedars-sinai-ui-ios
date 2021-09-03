//
//  CLLocationDistance+Localization.swift
//  CedarsSinai
//
//  Created by John Zhao on 2/3/20.
//  Copyright © 2020 Phunware, Inc. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationDistance {
    var localizedDistanceInSmallUnits: String {
        let usesMetricSystem = NSLocale.current.usesMetricSystem
        
        let meters = Measurement(value: self, unit: UnitLength.meters)
        let feet = meters.converted(to: .feet).value
        
        let convertedDistance = usesMetricSystem
            ? self
            : feet
        
        let roundedDistance = Int(convertedDistance.rounded())
        
        let suffix: String
        
        if roundedDistance == 1 {
            suffix = usesMetricSystem ? NSLocalizedString("meter", comment: "") : NSLocalizedString("foot", comment: "")
        } else {
            suffix = usesMetricSystem ? NSLocalizedString("meters", comment: "") : NSLocalizedString("feet", comment: "")
        }
        
        return "\(roundedDistance) \(suffix)"
    }
}

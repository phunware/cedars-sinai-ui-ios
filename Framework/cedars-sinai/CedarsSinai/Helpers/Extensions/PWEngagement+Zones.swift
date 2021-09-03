//
//  PWEngagement+Zones.swift
//  CedarsSinai
//
//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import PWEngagement

extension PWEngagement {
    class func monitoredZones() -> [PWMEGeozone] {
        var monitoredZones = [PWMEZone]()

        if let zones = PWEngagement.geozones() {
            monitoredZones = zones.filter { (zone) -> Bool in
                return (zone).monitored
                } as [PWMEZone]
        }
        return monitoredZones as! [PWMEGeozone]
    }

    class func insideZones() -> [PWMEGeozone] {
        var insideZones = [PWMEZone]()

        if let zones = PWEngagement.geozones() {
            insideZones = zones.filter { (zone) -> Bool in
                return (zone).inside
                } as [PWMEZone]
        }

        return insideZones as! [PWMEGeozone]
    }
}

//
//  PWBuilding+Extensions.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/24/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

extension PWBuilding {
    var location: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var initialFloor: PWFloor? {
        return floors.first(where: { (floor) -> Bool in
            return (floor as? PWFloor)?.level == 0
        }) as? PWFloor
    }

    func close(to locationPoint: CLLocation) -> Bool {
        // 1609 is a rough estimate of 1 mile
        return locationPoint.distance(from: location) < 1609
    }

    func poiWith(identifier: Int) -> PWPointOfInterest? {
        return allPointOfinterest()?.first(where: {$0.identifier == identifier})
    }

    func poiWith(title: String) -> PWPointOfInterest? {
        return allPointOfinterest()?.first(where: {$0.title == name})
    }

    func allPointOfinterest() -> [PWPointOfInterest]? {
        if let allPOIs = self.pois as? [PWPointOfInterest] {
            return allPOIs
        }
        return nil
    }
    
    func allCurrentPointOfInterestType() -> [PWPointOfInterestType]? {
        guard let allBuildingPOIs = allPointOfinterest(), let allBuildingPOITypes = pointOfInterestTypes as? [PWPointOfInterestType] else {
            return nil
        }
        let buildingPOIsType = Array(Set(allBuildingPOIs.map { $0.pointOfInterestType })).compactMap { $0.identifier }
        return allBuildingPOITypes.filter { buildingPOIsType.contains($0.identifier) }.sorted { CSMapModule.localizedString($0.name)!.localizedCaseInsensitiveCompare(CSMapModule.localizedString($1.name)!) == ComparisonResult.orderedAscending }
    }
    
    func getPointOfInterestTypeImages() -> [CSPOITypeImageModel]? {
        guard let allPOIs = allPointOfinterest() else {
            return nil
        }
        
        var poiTypeImageModelArray: [CSPOITypeImageModel] = []
        for poi in allPOIs {
            let informationModel = CSPOITypeImageModel(poiTypeIdentifier: poi.pointOfInterestType.identifier, imageUrl: poi.imageURL)
            if !poiTypeImageModelArray.contains(informationModel) {
                poiTypeImageModelArray.append(informationModel)
            }
        }
        return poiTypeImageModelArray
    }
}

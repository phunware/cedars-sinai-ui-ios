//
//  PWPointOfInterest+Extensions.swift
//  CedarsSinai
//
//  Created by tomas on 4/27/18.
//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

extension PWPointOfInterest {
    var isElevator: Bool {
        return pointOfInterestType.name.localizedCaseInsensitiveContains("elevator")
    }

    var metadataKeyword: String? {
        return metadataValue(for: "keyword")
    }
    var metadataSubtitle: String? {
        return metadataValue(for: "subtitle")
    }
    var metadataImageUrl: URL? {
        guard let imageUrl = metadataValue(for: "imageurl") else {
            return nil
        }
        return URL(string: imageUrl)
    }

    fileprivate func metadataValue(for metadataKey: String) -> String? {
        guard let metaData = metaData else {
            return nil
        }
        return metaData.first(where: { (key, value) -> Bool in
            if let key = key as? String {
                return key.lowercased().contains(metadataKey)
            }
            return false
        })?.value as? String
    }
}

extension PWMapPoint {

    internal var location: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}


// MARK: PWPointOfInterest filtering
// MARK: PWCustomPointOfInterest filtering
extension Sequence where Element == PWMapPoint {
    func filterBy(keyword: String?) -> [Element] {
        guard let searchTerm = keyword else {
            return self as! [Element]
        }
        return filter({ (point) -> Bool in
            if let poi = point as? PWPointOfInterest {
                guard let poiName = poi.title else {
                    return false
                }

                let keywords = poi.metadataKeyword

                return poiName.localizedCaseInsensitiveContains(searchTerm) || (keywords?.localizedCaseInsensitiveContains(searchTerm) ?? false)

            } else if let poi = point as? PWCustomPointOfInterest {
                guard let poiName = poi.title else {
                    return false
                }
                return poiName.localizedCaseInsensitiveContains(searchTerm)

            }
            return false
        })
    }

    func filterBy(category: PWPointOfInterestType?) -> [Element] {
        guard let category = category else {
            return self as! [Element]
        }
        return filter({ (point) -> Bool in
            guard let poi = point as? PWPointOfInterest else {
                return false
            }

            return poi.pointOfInterestType.identifier == category.identifier
        })
    }

    func filterBy(floorID: NSInteger?) -> [Element] {
        guard let floorID = floorID else {
            return self as! [Element]
        }
        return filter({ (point) -> Bool in
            return point.floorID == floorID
        })
    }

    func sortBy(location: CLLocation?) -> [Element] {
        guard let location = location else {
            return self as! [Element]
        }
        return sorted(by: { (pointA, pointB) -> Bool in
            return location.distance(from: pointA.location) < location.distance(from: pointB.location)
        })
    }
}

extension CLLocationDistance {
    var feet: String {
        let feet = self * 3.28
        return String(format: "%.2f feet", feet)
    }
}


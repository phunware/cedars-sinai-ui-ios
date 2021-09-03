//
//  CSPOITypeImageModel.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 10/25/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

//Accessing the image property of a PWPointOfInterestType object is nil when the building is loaded for the first time.
import Foundation
import UIKit

struct CSPOITypeImageModel {
    let poiTypeIdentifier: Int
    let imageUrl: URL
}

extension CSPOITypeImageModel: Equatable {
    static func ==(lhs: CSPOITypeImageModel, rhs: CSPOITypeImageModel) -> Bool {
        return lhs.poiTypeIdentifier == rhs.poiTypeIdentifier
    }
}

extension CSPOITypeImageModel: Hashable {
    var hashValue: Int {
        return poiTypeIdentifier.hashValue ^ imageUrl.hashValue
    }
}

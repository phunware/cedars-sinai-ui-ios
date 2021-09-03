//
//  CSPointOfInterestsHelper.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/25/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation
import PWMapKit

struct CSPointOfInterestsHelper {
    public static func makePOIDirectoryListItems(poiArray: [PWPointOfInterest]) -> (sections: [String], itemList: [CSDirectorySectionModel]) {
        var sections = Array(Set(poiArray.map { $0.title }.flatMap { $0 }.map { String($0[$0.startIndex]) }))
        sections = sections.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        let numberSections = sections.filter { Int($0) != nil }
        if numberSections.count > 0 {
            sections = sections.filter { !numberSections.contains($0) }
        }
        
        var sortedPOIs: [CSDirectorySectionModel] = []
        for sectionLetter in sections {
            let sectionPOIs = poiArray.filter {
                guard let poiTitle = $0.title else {
                    return false
                }
                return String(poiTitle[poiTitle.startIndex]) == sectionLetter
            }
            sortedPOIs.append(CSDirectorySectionModel(sectionHeader: sectionLetter, poinOfInterests: sectionPOIs))
        }
        sortedPOIs = sortedPOIs.sorted { $0.sectionHeader.localizedCaseInsensitiveCompare($1.sectionHeader) == ComparisonResult.orderedAscending }
        
        let poisStartingWithNumbers = poiArray.filter {
            guard let poiTitle = $0.title else {
                return false
            }
            return Int(poiTitle) != nil
        }.sorted {
            guard let firstTitle = $0.title, let secondTitle = $1.title else {
                return false
            }
            return firstTitle.localizedCompare(secondTitle) == ComparisonResult.orderedAscending
        }
        if poisStartingWithNumbers.count > 0 {
            sortedPOIs.insert(CSDirectorySectionModel(sectionHeader: "#", poinOfInterests: poisStartingWithNumbers), at: 0)
            sections.insert("#", at: 0)
        }
        
        return (sections, sortedPOIs)
    }

    public static func poiListSections(_ list: [PWMapPoint]) -> (sections: [CSDirectorySectionModel], sectionTitles: [String]) {

        let collation = UILocalizedIndexedCollation.current()
        var sections: [[PWMapPoint]]

        var sectionList: [CSDirectorySectionModel] = [CSDirectorySectionModel]()

        sections = Array(repeating: [], count: collation.sectionIndexTitles.count)

        let selector: Selector = #selector(getter: PWMapPoint.title)
        let sortedObjects = collation.sortedArray(from: list, collationStringSelector: selector)

        sortedObjects.forEach { (point) in
            let index = collation.section(for: point, collationStringSelector: selector)

            if let poi = point as? PWMapPoint {
                sections[index].append(poi)
            }
        }

        for (index, section) in sections.enumerated() {
            let sectionTitle = collation.sectionTitles[index]
            let model = CSDirectorySectionModel(sectionHeader: sectionTitle, poinOfInterests: section)
            sectionList.append(model)
        }

        return (sectionList, collation.sectionTitles)

    }
}

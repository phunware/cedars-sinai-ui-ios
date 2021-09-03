//
//  CSPlistReader.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/11/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import Foundation

public class CSPlistReader {
    
    public static func dictionary(plistName: String, inBundle bundle: Bundle = CSBundleHelper.bundle) -> [String : Any]? {
        guard let plistURL = bundle.url(forResource: plistName, withExtension: "plist") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: plistURL)
            let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String : Any]
            return dictionary
        } catch {
            return nil
        }
    }
    
}

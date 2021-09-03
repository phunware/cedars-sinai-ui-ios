//
//  NSMutableAttributedString+Extension.swift
//  CedarsSinai
//
//  Created by John Zhao on 2/3/20.
//  Copyright © 2020 Phunware, Inc. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    func replace(substring: String, with replacement: String, attributes: [NSAttributedString.Key : Any]) {
        if let range = self.string.range(of: substring) {
            let nsRange = NSRange(range, in: self.string)
            let replacement = NSAttributedString(string: replacement, attributes: attributes)
            self.replaceCharacters(in: nsRange, with: replacement)
        }
    }
}

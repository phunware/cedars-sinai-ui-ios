//
//  InstructionTextOptions.swift
//  CedarsSinai
//
//  Created by John Zhao on 2/3/20.
//  Copyright © 2020 Phunware, Inc. All rights reserved.
//

import Foundation

struct InstructionTextOptions {
    let color: UIColor
    let font: UIFont
    
    var attributes: [NSAttributedString.Key : Any] {
        return [.foregroundColor: color, .font: font]
    }
}

extension InstructionTextOptions {
    static let defaultStandardOptions: InstructionTextOptions = {
        return InstructionTextOptions(color: UIColor.black,
                                      font: .systemFont(ofSize: 16.0, weight: .regular))
    }()
    
    static let defaultHighlightOptions = InstructionTextOptions(color: UIColor.black,
                                                                font: .systemFont(ofSize: 16.0, weight: .semibold))
}

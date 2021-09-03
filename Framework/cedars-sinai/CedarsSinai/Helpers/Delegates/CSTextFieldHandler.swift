//
//  CSTextFieldHandler.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/28/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSTextFieldHandler: NSObject, UITextFieldDelegate {

    public var textFieldShouldBeginAction: ((_ textField: UITextField) -> Bool)?
    public var textFieldDidBeginAction: ((_ textField: UITextField) -> Void)?
    public var textFieldEndEditingAction: ((_ textFieldTag: Int) -> Void)?
    public var textFieldClearAction: ((_ textFieldTag: Int) -> Void)?
    public var textFieldShouldReturn: ((_ textField: UITextField) -> Void)?


    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textFieldShouldBeginAction?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDidBeginAction?(textField)
        if let routeTextField = textField as? CSRouteTextField {
            routeTextField.setHighlightedBorder()
        }
    }
    
    weak var timer: Timer?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        timer?.invalidate()
        timer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(sendSearchAnalytics), userInfo: textField, repeats: false)
        return true
    }
    
    @objc func sendSearchAnalytics(_ sender: Timer) {
        guard let textField = sender.userInfo as? UITextField, let text = textField.text else {
            return
        }
        let parameters = ["Search Term" : text]
        CSMapModule.sendEvent(Event.Name.search.rawValue, paramaters: parameters)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldEndEditingAction?(textField.tag)
        if let routeTextField = textField as? CSRouteTextField {
            routeTextField.setDefaultBorder()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldClearAction?(textField.tag)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldShouldReturn?(textField)
        return true
    }
}

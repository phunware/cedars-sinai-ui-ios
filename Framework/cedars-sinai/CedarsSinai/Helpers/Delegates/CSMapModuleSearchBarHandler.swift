//
//  CSMapModuleSearchBarHandler.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/25/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSMapModuleSearchBarHandler: NSObject, UISearchBarDelegate {
    
    public var textDidChangeAction: ((_ text: String) -> Void)?
    public var cancelButtonAction: (() -> Void)?
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        textDidChangeAction?(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        cancelButtonAction?()
    }
}

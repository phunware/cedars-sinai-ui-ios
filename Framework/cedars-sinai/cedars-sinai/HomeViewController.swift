//
//  HomeViewController.swift
//  cedars-sinai
//
//  Created by tomas on 8/10/18.
//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit
import CedarsSinai
import SDCAlertView
import Kingfisher

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    // MARK: Actions

    @IBAction func didPressStartRoute(_ sender: UIButton) {
        showRouteBuilder(buildingID: 65635)
    }

    @IBAction func didPressRouteWithPOI(_ sender: UIButton) {
        showRouteBuilder(buildingID: 65635, poiID: 48827353)
    }
    
    @IBAction func showArrivalAlert(_ sender: UIButton) {
        showEndOfRouteAlert()
    }

    @IBAction func prefetchBuilding(_ sender: UIButton) {
        CSMapModule.loadBuilding(withBuildingID: 65635) { (error) in
            let alert = AlertController(title: "Building loaded successfully", message: nil, preferredStyle: .alert)
            let okAction = AlertAction(title: "OK", style: .preferred)
            alert.addAction(okAction)
            if error != nil {
                alert.title = "Building failed to load"
                alert.message = error?.localizedDescription
            }
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
    // Mark: Buidling
    func showRouteBuilder(buildingID: Int, poiID: Int? = nil) {
            let cedarsWayfindingViewController = CSMapModule.initialRouteBuilder(withBuildingID: buildingID, poiID: poiID)
            self.show(cedarsWayfindingViewController, sender: nil)
    }
    
    func showEndOfRouteAlert() {
        let alert = AlertController(title: "Destination",
                                    message: "You have arrived at your destination", preferredStyle: .alert)
        
        let okAction = AlertAction(title: "End Route", style: .preferred) { [weak self] (action) in
//            self?.cancelRouting()
        }
        
        let cancelAction = AlertAction(title: "Dismiss", style: .normal)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
//        if let destinationPOI = destinationPOI as? PWPointOfInterest {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            alert.contentView.addSubview(imageView)
            let views = ["imageView": imageView]
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(<=200)]|", options: .alignAllLeading, metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView(<=270)]|", options: .alignAllCenterX, metrics: nil, views: views)
            NSLayoutConstraint.activate(constraints)
            imageView.contentMode = .scaleAspectFit
//            imageView.kf.setImage(with: "destinationPOI.metadataImageUrl", placeholder: #imageLiteral(resourceName: "arrival_placeholder"))
        let imageURL = URL(string: "https://camo.githubusercontent.com/e21f8a5e63c92c5ce77d14488f7dba132a96aeca/68747470733a2f2f636c6475702e636f6d2f3342504c367a374149302e6e67")
        imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "arrival_placeholder"))
//        }
        
        
        present(alert, animated: true)
    }

}

//
//  CSPointOfInterestDetailViewController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/26/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit
import PWMapKit

protocol RouteSelectedPointOfInterestDelegate: class {
    func routeToPointOfInterest(_ poi: PWMapPoint)
}

class CSPointOfInterestDetailViewController: UIViewController {
    
    @IBOutlet weak var poiBannerImage: UIImageView!
    @IBOutlet weak var poiNameLabel: UILabel!
    @IBOutlet weak var poiFloorNumberLabel: UILabel!
    @IBOutlet weak var poiDescriptionTextView: UITextView!
    @IBOutlet weak var imageContainerReferenceView: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: RouteSelectedPointOfInterestDelegate?
    
    public var poiToDisplay: PWPointOfInterest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPointOfInterestDetails()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [Event.Parameter.screenName.rawValue : "POI Detail"]
        CSMapModule.sendEvent(Event.Name.screenView.rawValue, paramaters: parameters)
        CSMapModule.startEvent("POI Detail", parameters: nil)
        logger("Start timed event", data: parameters)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CSMapModule.endEvent("POI Detail", parameters: nil)
        logger("End timed event")
    }
    
    @IBAction func routeButtonAction(_ sender: UIButton) {
        navigationController?.popViewControllerAnimatedWithCompletion {
            self.delegate?.routeToPointOfInterest(self.poiToDisplay)
        }
        CSMapModule.sendEvent(Event.Name.buttonTapped.rawValue, paramaters: [Event.Parameter.buttonName.rawValue : "Dismiss POI Detail"])
    }
}

// MARK: - View Configuration
extension CSPointOfInterestDetailViewController {
    fileprivate func loadPointOfInterestDetails() {
        poiNameLabel.text = poiToDisplay.title
        poiFloorNumberLabel.text = poiToDisplay.floor?.name
        poiDescriptionTextView.text = poiToDisplay.summary
        
        poiBannerImage.kf.setImage(with: poiToDisplay.metadataImageUrl)
        if let imageURL = poiToDisplay.metadataImageUrl {
            imageViewHeightConstraint.constant = imageContainerReferenceView.frame.height
            poiBannerImage.kf.setImage(with: imageURL)
        } else {
            imageViewHeightConstraint.constant = 0
        }
    }
}

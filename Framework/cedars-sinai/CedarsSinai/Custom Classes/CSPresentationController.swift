//
//  CSPresentationController.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/19/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

class CSPresentationController: UIPresentationController {
    
    static let dimmingColor = UIColor(white: 0, alpha: 0.55)
    
    lazy var dimmingView: UIView = {
        let newDimmingView = UIView()
        newDimmingView.frame = self.containerView!.bounds
        newDimmingView.backgroundColor = CSPresentationController.dimmingColor
        return newDimmingView
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerFrame = containerView?.frame else {
            return .zero
        }
        let height = containerFrame.height * 0.75
        let frame: CGRect
        
        if presentedViewController is CSFloorSelectorViewController || presentedViewController is CSDirectoryFilterViewController {
            presentedViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            frame = CGRect(x: 0, y: containerFrame.height - height, width: containerFrame.width, height: height)
        } else {
            frame = CGRect(x: 0, y: 0, width: containerFrame.width, height: containerFrame.height)
        }
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView, let presentedView = presentedViewController.view else {
            return
        }
        presentedView.layer.shadowRadius = 10
        presentedView.layer.shadowOpacity = 0.5
        presentedView.layer.shadowColor = UIColor.black.cgColor
        presentedView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)
        
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        touchGesture.delegate = self
        dimmingView.addGestureRecognizer(touchGesture)
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            })
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            })
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        guard let containerViewBounds = containerView?.bounds else {
            return
        }
        dimmingView.frame = containerViewBounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

// MARK:- UIGestureRecognizerDelegate
extension CSPresentationController: UIGestureRecognizerDelegate {
    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

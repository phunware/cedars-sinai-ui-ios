//
//  CSSegmentedControl.swift
//  cedars-sinai
//
//  Created by Gabriel Enrique Echeverria Mira on 9/18/17.
//  Copyright © 2017 Phunware, Inc. All rights reserved.
//

import UIKit

protocol Segmentable {
    func switchSegment(index: Int)
}

@IBDesignable
class CSSegmentedControl: UIControl {

    var buttons: [UIButton] = []
    var selector: UIView!
    var selectedSegmentIndex = 0
    
    var delegate: Segmentable?

    var items: [String] = ["Item 1", "Item 2"] {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - IBInspectables
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .lightGray {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor = .white {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var selectorBackgroundColor: UIColor = .lightGray {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Functionality Methods
    override func draw(_ rect: CGRect) {
        updateViews()
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    func setSelectedSegment(index: Int) {
        let selectedButton = buttons[index]
        selectedSegmentIndex = index
        onSegmentButtonTapped(tappedButton: selectedButton)
    }
}

//MARK: - Views Handling
extension CSSegmentedControl {
    fileprivate func updateViews() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        for title in items {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.addTarget(self, action: #selector(onSegmentButtonTapped(tappedButton:)), for: .touchUpInside)
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectedTextColor, for: .normal)
        
        let selectorWidth: CGFloat = frame.width / CGFloat(items.count)
        selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        selector.backgroundColor = selectorBackgroundColor
        selector.layer.cornerRadius = cornerRadius
        addSubview(selector)
        
        let segmentStackView = UIStackView(arrangedSubviews: buttons)
        segmentStackView.axis = .horizontal
        segmentStackView.alignment = .fill
        segmentStackView.distribution = .fillEqually
        addSubview(segmentStackView)
        
        segmentStackView.translatesAutoresizingMaskIntoConstraints = false
        segmentStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        segmentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        segmentStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        segmentStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        clipsToBounds = true
    }
    
    public func changeSelectedSegmented(index: Int) {
        onSegmentButtonTapped(tappedButton: buttons[index])
    }
    
    @objc func onSegmentButtonTapped(tappedButton: UIButton) {
        for (buttonIndex, button) in buttons.enumerated() {
            button.setTitleColor(textColor, for: .normal)
            
            if button == tappedButton {
                selectedSegmentIndex = buttonIndex
                let startPosition:CGFloat = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
                    self.selector.frame.origin.x = startPosition
                })
                button.setTitleColor(selectedTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
}

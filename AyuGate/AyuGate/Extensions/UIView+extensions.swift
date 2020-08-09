//
//  UIView+extensions.swift
//  AyuGate
//
//  Created by Pedro Azevedo on 17/04/20.
//  Copyright © 2020 AyuGate. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func installChild(_ viewController: UIViewController) {
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

}

extension CALayer {
    func setupShadow(opacity: Float = 0.8) {
        masksToBounds = false
        shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        shadowOffset = CGSize(width: 5, height: 7)
        shadowOpacity = opacity
    }
}

extension UIView {
    typealias Constraints = (left: NSLayoutConstraint?, top: NSLayoutConstraint?, right: NSLayoutConstraint?, bottom: NSLayoutConstraint?)
    @discardableResult func add(view: UIView, margins: UIEdgeInsets = .zero, edges: UIRectEdge = .all, parentLayoutMargins: Bool = false) -> Constraints {
        self.addSubview(view)
        return view.constrainToParent(margins, edges: edges, parentLayoutMargins: parentLayoutMargins)
    }

    @discardableResult func constrainToParent(_ margins: UIEdgeInsets = .zero, edges: UIRectEdge = .all, parentLayoutMargins: Bool = false) -> Constraints {
        guard let superview = superview else {
            print("View has not yet been added to superview. Cant add constraints")
            return (left: nil, top: nil, right: nil, bottom: nil)
        }
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = Constraints(left: nil, top: nil, right: nil, bottom: nil)
        if edges.contains(.top) {
            let targetAnchor = parentLayoutMargins ? superview.layoutMarginsGuide.topAnchor : superview.topAnchor
            constraints.top = topAnchor.constraint(equalTo: targetAnchor, constant: margins.top)
            constraints.top!.isActive = true
        }
        if edges.contains(.bottom) {
            let targetAnchor = parentLayoutMargins ? superview.layoutMarginsGuide.bottomAnchor : superview.bottomAnchor
            constraints.bottom = bottomAnchor.constraint(equalTo: targetAnchor, constant: -margins.bottom)
            constraints.bottom!.isActive = true
        }

        if edges.contains(.left) {
            let targetAnchor = parentLayoutMargins ? superview.layoutMarginsGuide.leadingAnchor : superview.leadingAnchor
            constraints.left = leadingAnchor.constraint(equalTo: targetAnchor, constant: margins.left)
            constraints.left!.isActive = true
        }

        if edges.contains(.right) {
            let targetAnchor = parentLayoutMargins ? superview.layoutMarginsGuide.trailingAnchor : superview.trailingAnchor
            constraints.right = trailingAnchor.constraint(equalTo: targetAnchor, constant: -margins.right)
            constraints.right!.isActive = true
        }
        return constraints
    }

    @discardableResult func set(width: CGFloat?=nil, height: CGFloat?=nil) -> Self {
        if let width = width {
            let cW: NSLayoutConstraint = widthAnchor.constraint(equalToConstant: width)
            cW.isActive = true
        }
        if let height = height {
            let cH: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: height)
            cH.isActive = true
        }

        return self
    }

    @discardableResult func cornerRadius(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }

    @discardableResult func layoutMargins(_ insets: UIEdgeInsets) -> Self {
        layoutMargins = insets
        return self
    }

}

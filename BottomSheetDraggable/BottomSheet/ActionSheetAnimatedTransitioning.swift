//
//  ActionSheetAnimatedTransitioning.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 04/09/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class ActionSheetAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.5
    var dimmedView: UIView!
    
    init(dimmedView: UIView) {
        self.dimmedView = dimmedView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let viewToBePresented = transitionContext.view(forKey: .to) {
            animatePresentation(using: transitionContext, viewToBePresented: viewToBePresented)
        } else if let viewToBeDismissed = transitionContext.view(forKey: .from) {
            animateDismissal(using: transitionContext, viewToBeDismissed: viewToBeDismissed)
        }
    }
    
    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning, viewToBePresented: UIView) {
        let containerView = transitionContext.containerView
        containerView.addSubview(viewToBePresented)
        
        viewToBePresented.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y + containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)
        
        UIView.animate(withDuration: duration, animations: {
            viewToBePresented.frame = containerView.frame
            self.dimmedView.alpha = 0.5
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning, viewToBeDismissed: UIView) {
        let containerView = transitionContext.containerView
        containerView.addSubview(viewToBeDismissed)
        
        viewToBeDismissed.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: containerView.frame.height)
        
        UIView.animate(withDuration: duration, animations: {
            viewToBeDismissed.frame = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y + containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)
            self.dimmedView.alpha = 1.0
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}

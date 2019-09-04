//
//  ActionSheetViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 27/08/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

/// The possible positions for the actionSheet
///
/// - complete: Action sheet is smaller than the screen. All items are shown. This is used when there are just a few items
/// - partiallyRevealed: Action sheet is smaller than the screen. Not all items are shown. This is used when there are more items. It's the state that precedes scrolling, that is, it's the state that precedes the user action to scroll up to see all items
/// - fullScreen: Action sheet has the same size as the screen. If all items fit the screen, they'll all be shown. Otherwise, a scroll is suggested. This state is activated after scrolling up from the partiallyRevealed state.
enum ActionSheetPosition {
    case complete, partiallyRevealed, fullScreen
    
    var nextPosition: ActionSheetPosition {
        switch self {
        case .complete:
            return .complete
        case .partiallyRevealed:
            return .fullScreen
        case .fullScreen:
            return .partiallyRevealed
        }
    }
    
    var height: CGFloat {
        switch self {
        case .complete:
            return UIScreen.main.bounds.height * 0.4
        case .partiallyRevealed:
            return UIScreen.main.bounds.height * 0.3
        case .fullScreen:
            return UIScreen.main.bounds.height
        }
    }
}

class ActionSheetViewController: UIViewController {

    let actionSheetView = UIView()
    var currentActionSheetPosition: ActionSheetPosition = .partiallyRevealed
    
    var backgroundViewController: ActionSheetBackgroundViewController!
    var actionSheetHeightConstraint: NSLayoutConstraint!
    
    
    private var transitionAnimator: UIViewPropertyAnimator!
    private var animationProgress: CGFloat = 0
    
    required public init(backgroundViewController: ActionSheetBackgroundViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.backgroundViewController = backgroundViewController
        
        setupActionSheetView()
        
        self.modalPresentationStyle = .overFullScreen
        self.backgroundViewController.present(self, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ActionSheetViewController {
    func setupActionSheetView() {
        view.addSubview(actionSheetView)
        
        setupActionSheetGestureRecognizer()
        setupActionSheetConstraints()
        setupActionSheetLayout()
    }
    
    func setupActionSheetGestureRecognizer() {
        let tapOrPanRecognizer = InstantPanGestureRecognizer()
        tapOrPanRecognizer.addTarget(self, action: #selector(actionSheetViewTappedOrPanned(recognizer:)))
        actionSheetView.addGestureRecognizer(tapOrPanRecognizer)
    }
    
    func setupActionSheetConstraints() {
        actionSheetView.translatesAutoresizingMaskIntoConstraints = false
        actionSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        actionSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        actionSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        actionSheetHeightConstraint = actionSheetView.heightAnchor.constraint(equalToConstant: currentActionSheetPosition.height)
        actionSheetHeightConstraint.isActive = true
    }
    
    func setupActionSheetLayout() {
        actionSheetView.layer.cornerRadius = 15.0
        actionSheetView.clipsToBounds = true
        actionSheetView.backgroundColor = .white
    }
    
    @objc func actionSheetViewTappedOrPanned(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded()
            transitionAnimator.pauseAnimation()
            animationProgress = transitionAnimator.fractionComplete
        case .changed:
            let translation = recognizer.translation(in: actionSheetView)
            var fraction = -translation.y / 400
            if currentActionSheetPosition == .fullScreen { fraction *= -1 }
            transitionAnimator.fractionComplete = fraction + animationProgress
        case .ended:
            transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded() {
        let state = currentActionSheetPosition.nextPosition
        currentActionSheetPosition = state
        
        if state != .complete {
            transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.actionSheetHeightConstraint.constant = state.height
                self.view.layoutIfNeeded()
            })
            transitionAnimator.startAnimation()
        }
    }
}

/// A pan gesture that enters into the 'began' state on touch down instead of waiting for a touches moved event
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = UIGestureRecognizer.State.began
    }
}

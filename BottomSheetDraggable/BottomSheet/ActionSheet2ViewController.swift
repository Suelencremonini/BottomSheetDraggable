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
enum ActionSheetPosition2 {
    case complete, partiallyRevealed, fullScreen
    
    var nextPosition: ActionSheetPosition2 {
        switch self {
        case .complete:
            return .complete
        case .partiallyRevealed:
            return .fullScreen
        case .fullScreen:
            return .partiallyRevealed
        }
    }
}

class ActionSheet2ViewController: UIViewController {
    
    let innerView = UIView()
    
    let innerViewTapRecognizer = UITapGestureRecognizer()
    let innerViewPanRecognizer = UIPanGestureRecognizer()
    
    var backgroundViewController: ActionSheetBackgroundViewController!
    
    var currentActionSheetPosition: ActionSheetPosition2 = .partiallyRevealed
    
    private let dismissGesture = UITapGestureRecognizer()
    
    private let actionSheetView = UIView()
    private let topView = UIView()
    
    private var panGestureAnimator: UIViewPropertyAnimator!
    private var transition: ActionSheetAnimatedTransitioning!
    private var innerViewHeightConstraint: NSLayoutConstraint!
    
    /// called to start the action sheet component
    ///
    /// - Parameter backgroundViewController: the view controller where the action sheet will be presented
    func start(on backgroundViewController: ActionSheetBackgroundViewController) {
        self.backgroundViewController = backgroundViewController
        
        setupActionSheetView()
        setupTopView()
        setupInnerView()
        setupTransition()
        setupPresent()
        setupDismiss()
    }
    
    /// should be orridden to give the component a custom height based on the position of the action sheet. The default heights are:
    /// complete -> 40% of the total screen height
    /// partiallyRevealed -> 30% of the total screen height
    /// fullScreen -> the maximum possible height of the innerView (total screen height minus the status bar height minus the topView height)
    ///
    /// - Parameter position: the position of the action sheet: complete, partiallyRevealed, fullScreen
    /// - Returns: returns the height for the specified position
    func getInnerViewHeight(forPosition position: ActionSheetPosition2) -> CGFloat {
        switch position {
        case .complete:
            return UIScreen.main.bounds.height * 0.4
        case .partiallyRevealed:
            return UIScreen.main.bounds.height * 0.3
        case .fullScreen:
            return UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - topView.bounds.height
        }
    }
    
    /// if the height changes in the client of the component, calls this method to update the views with the new one
    func resizeInnerViewHeight() {
        innerViewHeightConstraint.constant = getInnerViewHeight(forPosition: currentActionSheetPosition)
        view.layoutIfNeeded()
    }
}

// MARK: - Deals with the setup of the views
private extension ActionSheet2ViewController {
    func setupPresent() {
        modalPresentationStyle = .overFullScreen
        backgroundViewController.present(self, animated: true, completion: nil)
    }
    
    func setupDismiss() {
        dismissGesture.delegate = self
        dismissGesture.addTarget(self, action: #selector(dismissActionSheet(recognizer:)))
        view.addGestureRecognizer(dismissGesture)
    }
    
    @objc func dismissActionSheet(recognizer: UIPanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupTransition() {
        transitioningDelegate = self
        transition = ActionSheetAnimatedTransitioning(dimmedView: backgroundViewController.view)
    }
    
    func setupActionSheetView() {
        view.addSubview(actionSheetView)
        setupActionSheetLayout()
        setupActionSheetConstraints()
    }
    
    func setupActionSheetLayout() {
        actionSheetView.clipsToBounds = true
        actionSheetView.backgroundColor = .white
        actionSheetView.layer.cornerRadius = 20.0
        actionSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupActionSheetConstraints() {
        actionSheetView.translatesAutoresizingMaskIntoConstraints = false
        actionSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        actionSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        actionSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupTopView() {
        actionSheetView.addSubview(topView)
        
        setupTopViewConstraints()
        setupTopGrayBarView()
        add(tapRecognizer: UITapGestureRecognizer(), panRecognizer: UIPanGestureRecognizer(), forView: topView)
    }
    
    func setupTopViewConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.leadingAnchor.constraint(equalTo: actionSheetView.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: actionSheetView.trailingAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: actionSheetView.topAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupTopGrayBarView() {
        let topGrayBarView = UIView()
        topGrayBarView.backgroundColor = .gray
        topGrayBarView.layer.cornerRadius = 5
        
        topView.addSubview(topGrayBarView)
        setupTopGrayBarConstraints(topGrayBarView)
    }
    
    func setupTopGrayBarConstraints(_ topGrayBarView: UIView) {
        topGrayBarView.translatesAutoresizingMaskIntoConstraints = false
        topGrayBarView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        topGrayBarView.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        topGrayBarView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        topGrayBarView.heightAnchor.constraint(equalToConstant: 3).isActive = true
    }
    
    func setupInnerView() {
        actionSheetView.addSubview(innerView)
        
        setupInnerViewConstraints()
        add(tapRecognizer: innerViewTapRecognizer, panRecognizer: innerViewPanRecognizer, forView: innerView)
    }
    
    func setupInnerViewConstraints() {
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.leadingAnchor.constraint(equalTo: actionSheetView.leadingAnchor).isActive = true
        innerView.trailingAnchor.constraint(equalTo: actionSheetView.trailingAnchor).isActive = true
        innerView.bottomAnchor.constraint(equalTo: actionSheetView.bottomAnchor).isActive = true
        innerView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        
        innerViewHeightConstraint = innerView.heightAnchor.constraint(equalToConstant: getInnerViewHeight(forPosition: currentActionSheetPosition))
        innerViewHeightConstraint.isActive = true
    }
    
    func add(tapRecognizer: UITapGestureRecognizer, panRecognizer: UIPanGestureRecognizer, forView view: UIView) {
        tapRecognizer.addTarget(self, action: #selector(tapGesture(recognizer:)))
        panRecognizer.addTarget(self, action: #selector(panGesture(recognizer:)))

        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(panRecognizer)
    }
}

// MARK: - Deals with the animation events
private extension ActionSheet2ViewController {
    func animateTransitionIfNeeded() {
        let state = currentActionSheetPosition.nextPosition
        
        panGestureAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
            //add animation based on the action sheet position. The targeted height is the height of the next position
            switch state {
            case .partiallyRevealed:
                self.innerViewHeightConstraint.constant = self.getInnerViewHeight(forPosition: .partiallyRevealed)
            case .fullScreen:
                self.innerViewHeightConstraint.constant = self.getInnerViewHeight(forPosition: .fullScreen)
            default:
                break
            }
            self.view.layoutIfNeeded()
        })
        
        panGestureAnimator.addCompletion { animationStatus in
            self.panGestureAnimatorCompletion(animationStatus: animationStatus, state: state)
        }
        panGestureAnimator.startAnimation()
    }
    
    func panGestureAnimatorCompletion(animationStatus: UIViewAnimatingPosition, state: ActionSheetPosition2) {
        //When the animation ends, sets the current position of the action sheet to the next state
        if animationStatus == .end {
            self.currentActionSheetPosition = state
        }
        //Reset the constraints. Necessary because when the user changes the direction of the pan gesture during the animation, the ending position won't be the expected one, it'll be the current one
        switch self.currentActionSheetPosition {
        case .partiallyRevealed:
            self.innerViewHeightConstraint.constant = self.getInnerViewHeight(forPosition: .partiallyRevealed)
        case .fullScreen:
            self.innerViewHeightConstraint.constant = self.getInnerViewHeight(forPosition: .fullScreen)
        default:
            break
        }
    }
    
    @objc func tapGesture(recognizer: UITapGestureRecognizer) {
        animateTransitionIfNeeded()
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded()
            // pause the animation, since the next event may be a pan changed
            panGestureAnimator.pauseAnimation()
        case .changed:
            panGestureChanged(translation: recognizer.translation(in: actionSheetView))
        case .ended:
            panGestureEnded(yVelocity: recognizer.velocity(in: actionSheetView).y)
        default:
            break
        }
    }
    
    func panGestureChanged(translation: CGPoint) {
        //gets how big the translation was
        let yTranslated = view.center.y + translation.y
        
        var progress: CGFloat = 0
        switch currentActionSheetPosition {
        case .partiallyRevealed:
            progress = 1 - (yTranslated / view.center.y)
        case .fullScreen:
            progress = (yTranslated / view.center.y) - 1
        default:
            break
        }
        
        //This is the progress based on the current state and the size of the translation. It should be bigger than 0 and smaller than 1 because when the progress hits those points, the animation will be considered completed and its state will change
        progress =  max(0.001, min(0.999, progress))
        panGestureAnimator.fractionComplete = progress
    }
    
    func panGestureEnded(yVelocity: CGFloat) {
        //the velocity is bigger than 0 when the user is dragging the view
        if yVelocity != 0 {
            let isDraggingDown = yVelocity > 0
            
            // reverse the animations based on the dragging direction
            switch currentActionSheetPosition {
            case .partiallyRevealed:
                panGestureAnimator.isReversed = isDraggingDown
            case .fullScreen:
                panGestureAnimator.isReversed = !isDraggingDown
            default:
                break
            }
        }
        
        panGestureAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
}

// MARK: - UIViewControllerTransitioningDelegate - Delegate responsible for calling the custom transitions to present and to dismiss the action sheet
extension ActionSheet2ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}

extension ActionSheet2ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isTouchInInnerView = touch.view?.isDescendant(of: innerView) ?? false
        let isTouchInTopView = touch.view?.isDescendant(of: topView) ?? false
        
        if  gestureRecognizer == dismissGesture && (isTouchInTopView || isTouchInInnerView) {
            return false
        }
        return true

    }
}

// MARK: - UIGestureRecognizerDelegate - refuse gestures when the action sheet position is complete and when shouldDisableTapGestureInInnerView or shouldDisablePanGestureInInnerView are true
//extension ActionSheet2ViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        let isTouchInInnerView = touch.view?.isDescendant(of: innerView) ?? false
//
//        let isPanGestureRecognizer = gestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
//        let isTapGestureRecognizer = gestureRecognizer.isKind(of: UITapGestureRecognizer.self)
//
//        let disablePanInInnerView = isPanGestureRecognizer && isTouchInInnerView && shouldDisablePanGestureInInnerView
//        let disableTapInInnerView = isTapGestureRecognizer && isTouchInInnerView && shouldDisableTapGestureInInnerView
//
//        let disableGestureForPositionComplete = currentActionSheetPosition == .complete
//
//        if  disablePanInInnerView || disableTapInInnerView || disableGestureForPositionComplete {
//            return false
//        }
//        return true
//    }
//}


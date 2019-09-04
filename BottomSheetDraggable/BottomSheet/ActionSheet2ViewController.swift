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

class ActionSheet2ViewController: UIViewController {
    
    let actionSheetView = UIView()

    var currentActionSheetPosition: ActionSheetPosition2 = .partiallyRevealed

    var actionSheetHeightConstraint: NSLayoutConstraint!
    
    private var panGestureAnimator: UIViewPropertyAnimator!
    private var backgroundViewController: UIViewController!
    private var transition: ActionSheetAnimatedTransitioning!
    
    required public init(backgroundViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.backgroundViewController = backgroundViewController
        
        setupActionSheetView()
        setupTransition()
        setupPresent()
        setupDismiss()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ActionSheet2ViewController {
    func setupPresent() {
        modalPresentationStyle = .overFullScreen
        backgroundViewController.present(self, animated: true, completion: nil)
    }
    
    func setupDismiss() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(dismissActionSheet(recognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupTransition() {
        transitioningDelegate = self
        transition = ActionSheetAnimatedTransitioning(dimmedView: backgroundViewController.view)
    }
    
    @objc func dismissActionSheet(recognizer: UIPanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupActionSheetView() {
        view.addSubview(actionSheetView)
        
        setupActionSheetGestureRecognizer()
        setupActionSheetConstraints()
        setupActionSheetLayout()
    }
    
    func setupActionSheetGestureRecognizer() {
        //there is no animation when the current position is "complete" because we assumed that the whole content fits the view
        if currentActionSheetPosition != .complete {
            let tapOrPanRecognizer = InstantPanGestureRecognizer2()
            tapOrPanRecognizer.addTarget(self, action: #selector(panGesture(recognizer:)))
            actionSheetView.addGestureRecognizer(tapOrPanRecognizer)
        }
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
        actionSheetView.clipsToBounds = true
        actionSheetView.backgroundColor = .white
        actionSheetView.layer.cornerRadius = 20.0
        actionSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addTopBar()
    }
    
    func addTopBar() {
        let topBar = UIView()
        topBar.backgroundColor = .gray
        topBar.layer.cornerRadius = 5
        
        actionSheetView.addSubview(topBar)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.centerXAnchor.constraint(equalTo: actionSheetView.centerXAnchor).isActive = true
        topBar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 3).isActive = true
        topBar.topAnchor.constraint(equalTo: actionSheetView.topAnchor, constant: 20).isActive = true
    }
    
    func animateTransitionIfNeeded() {
        let state = currentActionSheetPosition.nextPosition
        
        panGestureAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
            //add animation based on the action sheet position. The targeted height is the height of the next position
            switch state {
            case .partiallyRevealed:
                self.actionSheetHeightConstraint.constant = ActionSheetPosition2.partiallyRevealed.height
            case .fullScreen:
                self.actionSheetHeightConstraint.constant = ActionSheetPosition2.fullScreen.height
            default:
                break
            }
            self.view.layoutIfNeeded()
        })
        
        panGestureAnimator.addCompletion { animationStatus in
            //When the animation ends, sets the current position of the action sheet to the next state. The animation ends only when its direction IS NOT changed during the animation
            if animationStatus == .end {
                self.currentActionSheetPosition = state
            }
            //Reset the constraints. Necessary because when the user changes the direction of the pan gesture during the animation, the ending position won't be the expected one, it'll be the current one
            switch self.currentActionSheetPosition {
            case .partiallyRevealed:
                self.actionSheetHeightConstraint.constant = ActionSheetPosition2.partiallyRevealed.height
            case .fullScreen:
                self.actionSheetHeightConstraint.constant = ActionSheetPosition2.fullScreen.height
            default:
                break
            }
        }
        panGestureAnimator.startAnimation()
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

/// A pan gesture that enters into the 'began' state on touch down instead of waiting for a touches moved event
class InstantPanGestureRecognizer2: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = UIGestureRecognizer.State.began
    }
}


//
//  InstantPanGestureRecognizer.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 05/09/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

/// A pan gesture that enters into the 'began' state on touch down instead of waiting for a touches moved event
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = UIGestureRecognizer.State.began
    }
}

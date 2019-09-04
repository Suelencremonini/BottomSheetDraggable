//
//  ActionSheetBackgroundViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 30/08/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

protocol ActionSheetBackgroundDelegate: class {
    func actionSheetBackgroundRegisterCellsForTableView(_ tableView: UITableView)
}

class ActionSheetBackgroundViewController: UIViewController {
    weak var delegate: ActionSheetBackgroundDelegate?
}

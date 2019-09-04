//
//  TestActionSheetTableViewCell.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 27/08/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class TestActionSheetTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    func config(row: Int) {
        cellLabel.text = "Cell \(row)"
    }
}

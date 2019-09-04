//
//  ActionSheetTableClientViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 02/09/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class ActionSheetTableClientViewController: ActionSheet2ViewController {

    private var tableView = UITableView()
    
    private var numberOfCells = 0
    
    var heightForActionSheet: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewOnActionSheetView()
    }
    
    func setTableViewOnActionSheetView() {
        actionSheetView.addSubview(tableView)
        
        tableView.dataSource = backgroundViewController as? UITableViewDataSource
        tableView.delegate = self
        
//        backgroundViewController.delegate?.actionSheetBackgroundRegisterCellsForTableView(tableView)
        
        setTableViewConstraints()
    }
    
    func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: actionSheetView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: actionSheetView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: actionSheetView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: actionSheetView.bottomAnchor).isActive = true
    }
    
}

extension ActionSheetTableClientViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if heightForActionSheet == UIScreen.main.bounds.height {
            heightForActionSheet = 0
        }
        if tableView.numberOfRows(inSection: indexPath.section) > 3 {
            currentActionSheetPosition = .partiallyRevealed
            if indexPath.row < 3 {
                 heightForActionSheet += cell.bounds.height
            } else if indexPath.row == 3 {
                 heightForActionSheet += cell.bounds.height/2
            }
        } else {
            currentActionSheetPosition = .complete
             heightForActionSheet += cell.bounds.height
        }
    }
}

//
//  ActionSheetTableViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 02/09/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class ActionSheetTableViewController: ActionSheet2ViewController {

    private var tableView = UITableView()
    private var heightForActionSheet: CGFloat = 0
    private var reloadedSuperView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !reloadedSuperView && heightForActionSheet != 0 {
            reloadedSuperView = true
            resizeInnerViewHeight()
        }
    }
    
    override func getInnerViewHeight(forPosition position: ActionSheetPosition2) -> CGFloat {
        switch position {
        case .complete, .partiallyRevealed:
            return (!reloadedSuperView ? super.getInnerViewHeight(forPosition: position) : heightForActionSheet)
        case .fullScreen:
            return super.getInnerViewHeight(forPosition: position)
        }
    }
}

private extension ActionSheetTableViewController {
    func setupTableView() {
        innerView.addSubview(tableView)
        setTableViewConstraints()
        
        tableView.dataSource = backgroundViewController as? UITableViewDataSource
        tableView.delegate = self
        
        backgroundViewController.delegate?.actionSheetBackgroundRegisterCellsForTableView(tableView)
    }
    
    func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: innerView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: innerView.bottomAnchor).isActive = true
    }
}

extension ActionSheetTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.numberOfRows(inSection: indexPath.section) > 3 {
            currentActionSheetPosition = .partiallyRevealed
            if indexPath.row < 2 {
                 heightForActionSheet += cell.bounds.height
            } else if indexPath.row == 2 {
                 heightForActionSheet += cell.bounds.height/2
            }
        } else {
            currentActionSheetPosition = .complete
            heightForActionSheet += cell.bounds.height
        }
    }
}

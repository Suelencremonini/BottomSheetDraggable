//
//  ActionSheetTableViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 02/09/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

protocol ActionSheetTableViewControllerDelegate: AnyObject {
    func actionSheetTableViewControllerRegisterCellsForTableView(_ actionSheetTableViewController: UIViewController, tableView: UITableView)
    func actionSheetTableViewControllerGetNumberOfCells(_ actionSheetTableViewController: UIViewController) -> Int
}

class ActionSheetTableViewController: ActionSheet2ViewController {

    weak var delegate: ActionSheetTableViewControllerDelegate?
    
    private var tableView = UITableView()
    private var heightForActionSheet: CGFloat = 0
    private var numberOfCells = 0
    
    private let maximumNumberOfCellsForCompletePosition = 3
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        setupActionSheetTableViewControllerDelegate()
        
        actionSheetView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if numberOfCells > maximumNumberOfCellsForCompletePosition {
            currentActionSheetPosition = .partiallyRevealed
            heightForActionSheet = (tableView.contentSize.height/CGFloat(numberOfCells))*2.5
        } else {
            currentActionSheetPosition = .complete
            heightForActionSheet = tableView.contentSize.height
        }
        presentAnimateView()
    }
    
    override func getInnerViewHeight(forPosition position: ActionSheetPosition2) -> CGFloat {
        switch position {
        case .complete, .partiallyRevealed:
            return heightForActionSheet
        case .fullScreen:
            return super.getInnerViewHeight(forPosition: position)
        }
    }
}

private extension ActionSheetTableViewController {
    func setupTableView() {
        scrollView = tableView
        setupTableViewConstraints()
        
        tableView.dataSource = backgroundViewController as? UITableViewDataSource
        tableView.delegate = self
    }
    
    func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: innerView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: innerView.bottomAnchor).isActive = true
    }
    
    func presentAnimateView() {
        UIView.animate(withDuration: 0.2) {
            self.actionSheetView.alpha = 1.0
            self.resizeInnerViewHeight()
        }
    }
    
    func setupActionSheetTableViewControllerDelegate() {
        delegate?.actionSheetTableViewControllerRegisterCellsForTableView(self, tableView: tableView)
        numberOfCells = delegate?.actionSheetTableViewControllerGetNumberOfCells(self) ?? 0
    }
}

extension ActionSheetTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

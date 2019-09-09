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
    private var reloadedSuperView = false
    private var tableViewLoaded = false
    private var numberOfCells = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        setupActionSheetTableViewControllerDelegate()
        
        innerViewPanRecognizer.delegate = self
        
        currentActionSheetPosition = numberOfCells > 3 ? .partiallyRevealed : .complete
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !reloadedSuperView && heightForActionSheet != 0 {
            tableViewLoaded = true
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
    }
    
    func setupActionSheetTableViewControllerDelegate() {
        delegate?.actionSheetTableViewControllerRegisterCellsForTableView(self, tableView: tableView)
        numberOfCells = delegate?.actionSheetTableViewControllerGetNumberOfCells(self) ?? 0
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
        if !tableViewLoaded {
            if numberOfCells > 3 {
                if indexPath.row < 2 {
                     heightForActionSheet += cell.bounds.height
                } else if indexPath.row == 2 {
                     heightForActionSheet += cell.bounds.height/2
                }
            } else {
                heightForActionSheet += cell.bounds.height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

// MARK: - UIGestureRecognizerDelegate - refuse gestures when the action sheet position is complete or partially visible and the user is dragging the table down
extension ActionSheetTableViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let isDraggingDown = gesture.velocity(in: view).y > 0
            
            if currentActionSheetPosition == .partiallyRevealed || (currentActionSheetPosition == .fullScreen && isDraggingDown && tableView.contentOffset.y == 0) {
                tableView.isScrollEnabled = false
            } else {
                tableView.isScrollEnabled = true
            }
        }
        return false
    }
}

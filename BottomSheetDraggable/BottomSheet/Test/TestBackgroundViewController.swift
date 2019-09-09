//
//  TestBackgroundViewController.swift
//  BottomSheetDraggable
//
//  Created by Suelen on 27/08/19.
//  Copyright © 2019 orgTech. All rights reserved.
//

import UIKit

class TestBackgroundViewController: UIViewController {

    private var listCell: [TestActionSheetTableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        var i = 0
        listCell = []
        while i < 30 {
            let cell = TestActionSheetTableViewCell()
            listCell.append(cell)
            i += 1
        }
//        if let vc = ActionSheet2ViewController(on: self) {
////            vc.delegate = self
//            present(vc, animated: true, completion: nil)
//        }
        if let vc = ActionSheetTableViewController(on: self) {
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
}

extension TestBackgroundViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestActionSheetTableViewCell", for: indexPath) as? TestActionSheetTableViewCell
        cell?.config(row: indexPath.row)
        return cell ?? UITableViewCell()
    }
}

extension TestBackgroundViewController: ActionSheetTableViewControllerDelegate {
    func actionSheetTableViewControllerRegisterCellsForTableView(_ actionSheetTableViewController: UIViewController, tableView: UITableView) {
        tableView.register(UINib(nibName: "TestActionSheetTableViewCell", bundle: nil), forCellReuseIdentifier: "TestActionSheetTableViewCell")
    }
    
    func actionSheetTableViewControllerGetNumberOfCells(_ actionSheetTableViewController: UIViewController) -> Int {
        return listCell.count
    }
}
